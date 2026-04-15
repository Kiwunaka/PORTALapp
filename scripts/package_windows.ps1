$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-ConfigScalar([string]$path, [string]$key) {
    $content = Get-Content -Path $path -Raw
    $match = [regex]::Match($content, "(?m)^\s*$([regex]::Escape($key)):\s*(.+?)\s*$")
    if (-not $match.Success) {
        throw "Missing '$key' in $path"
    }

    return $match.Groups[1].Value.Trim().Trim('"')
}

function Resolve-GlobalTool([string[]]$names) {
    foreach ($name in $names) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) {
            return $command.Source
        }
    }

    $pubCacheBin = Join-Path $env:LOCALAPPDATA "Pub\Cache\bin"
    foreach ($name in $names) {
        $candidate = Join-Path $pubCacheBin $name
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Replace-FirstMatch(
    [string]$text,
    [string]$pattern,
    [scriptblock]$replacement,
    [string]$description
) {
    $regex = [regex]$pattern
    if (-not $regex.IsMatch($text)) {
        throw "Unable to rewrite $description in MSIX manifest."
    }

    return $regex.Replace($text, $replacement, 1)
}

$repoRoot = (Get-Location).Path
$distDir = Join-Path $repoRoot "dist"
$outDir = Join-Path $repoRoot "out"
$releaseRunnerDir = Join-Path $repoRoot "build\windows\x64\runner\Release"
$msixConfigPath = Join-Path $repoRoot "windows\packaging\msix\make_config.yaml"
$exeConfigPath = Join-Path $repoRoot "windows\packaging\exe\make_config.yaml"

$appSlug = if ($env:APP_SLUG) { $env:APP_SLUG } else { Get-ConfigScalar -path $msixConfigPath -key "execution_alias" }
$outputBaseName = Get-ConfigScalar -path $exeConfigPath -key "output_base_file_name"
$runnerExeName = Get-ConfigScalar -path $exeConfigPath -key "executable_name"
$identityName = Get-ConfigScalar -path $msixConfigPath -key "identity_name"
$displayName = Get-ConfigScalar -path $msixConfigPath -key "display_name"
$publisherDisplayName = Get-ConfigScalar -path $msixConfigPath -key "publisher_display_name"
$publisher = Get-ConfigScalar -path $msixConfigPath -key "publisher"
$protocolName = Get-ConfigScalar -path $msixConfigPath -key "protocol_activation"
$executionAlias = Get-ConfigScalar -path $msixConfigPath -key "execution_alias"
$publisherUrl = Get-ConfigScalar -path $exeConfigPath -key "publisher_url"

$portableArchiveName = if ($outputBaseName -match "^(.*)-windows-setup-x64$") {
    "$($Matches[1])-windows-portable-x64.zip"
} else {
    "$appSlug-windows-portable-x64.zip"
}

$portableStageDir = Join-Path $distDir "tmp\$appSlug"
$runnerExePath = Join-Path $releaseRunnerDir $runnerExeName
$builtMsixPath = Join-Path $releaseRunnerDir "$outputBaseName.msix"
$canonicalExe = Join-Path $outDir "$outputBaseName.exe"
$canonicalMsix = Join-Path $outDir "$outputBaseName.msix"
$canonicalPortable = Join-Path $outDir $portableArchiveName
$brandingSourceIcon = (Resolve-Path (Join-Path $repoRoot "assets\images\source\ic_launcher_foreground.png")).Path
$brandingSyncScript = Join-Path $repoRoot "windows\sync_branding_assets.py"
$brandingAppIcon = Join-Path $repoRoot "windows\runner\resources\app_icon.ico"

function Assert-CanonicalConfig {
    $msixConfig = Get-Content -Path $msixConfigPath -Raw
    $exeConfig = Get-Content -Path $exeConfigPath -Raw

    if ($msixConfig -match 'certificate_password:\s*portalvpn-dev') {
        throw "windows/packaging/msix/make_config.yaml still contains the legacy dev signing password."
    }

    try {
        $publisherUri = [Uri]$publisherUrl
    } catch {
        throw "windows/packaging/exe/make_config.yaml publisher_url is not a valid URI."
    }

    if (-not $publisherUri.IsAbsoluteUri -or $publisherUri.Scheme -ne 'https') {
        throw "windows/packaging/exe/make_config.yaml publisher_url must be an absolute HTTPS URL."
    }

    if ($publisherUrl -match '^https://github\.com/') {
        throw "windows/packaging/exe/make_config.yaml must use the canonical public publisher URL before packaging."
    }

    if ($msixConfig -match 'Hiddify' -or $exeConfig -match 'Hiddify') {
        throw "Windows packaging config still contains legacy Hiddify branding."
    }

    if ($identityName -ne "pokrov") {
        throw "windows/packaging/msix/make_config.yaml identity_name must be 'pokrov'."
    }

    if ($publisher -ne "CN=POKROV") {
        throw "windows/packaging/msix/make_config.yaml publisher must be 'CN=POKROV'."
    }
}

function Find-ArtifactByExactName([string]$directory, [string]$name, [string]$description) {
    $candidate = Get-ChildItem -Recurse -File -Path $directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ieq $name } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $candidate) {
        throw "Unable to find $description artifact in $directory named '$name'."
    }

    return $candidate
}

function Find-Artifact([string[]]$patterns, [string]$description) {
    $candidate = Get-ChildItem -Recurse -File -Path $distDir -ErrorAction SilentlyContinue |
        Where-Object {
            foreach ($pattern in $patterns) {
                if ($_.Name -like $pattern) {
                    return $true
                }
            }
            return $false
        } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $candidate) {
        throw "Unable to find $description artifact in $distDir matching '$($patterns -join "', '")'."
    }

    return $candidate
}

function Sync-WindowsBrandingAssets {
    $pythonCommand = Get-Command python -ErrorAction Stop
    & $pythonCommand.Source $brandingSyncScript
    if ($LASTEXITCODE -ne 0) {
        throw "Windows branding asset sync failed."
    }
}

function Assert-ArtifactIsFresh([string]$artifactPath, [string]$description, [datetime]$referenceTimestampUtc) {
    if (-not (Test-Path $artifactPath)) {
        throw "$description artifact not found at $artifactPath"
    }

    $artifactTimestampUtc = (Get-Item $artifactPath).LastWriteTimeUtc
    if ($artifactTimestampUtc -lt $referenceTimestampUtc) {
        throw "$description artifact at $artifactPath is older than the refreshed Windows icon."
    }
}

function Invoke-WindowsSetupPackaging {
    # Use flutter_distributor package to refresh the setup installer when dist is stale.
    $command = Resolve-GlobalTool @("flutter_distributor", "flutter_distributor.bat")

    if ($command) {
        & $command package --flutter-build-args=verbose --platform windows --targets exe --skip-clean --build-target lib/main.dart
    } else {
        $dart = Resolve-GlobalTool @("dart.bat", "dart")
        if (-not $dart) {
            throw "Unable to find dart or flutter_distributor for Windows setup packaging."
        }
        & $dart pub global activate flutter_distributor
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to activate flutter_distributor."
        }
        $command = Resolve-GlobalTool @("flutter_distributor", "flutter_distributor.bat")
        if (-not $command) {
            throw "Unable to resolve flutter_distributor after activation."
        }
        & $command package --flutter-build-args=verbose --platform windows --targets exe --skip-clean --build-target lib/main.dart
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Windows setup packaging failed."
    }
}

function Resolve-MakeAppxPath {
    $tool = Get-Command MakeAppx.exe -ErrorAction SilentlyContinue
    if ($tool) {
        return $tool.Source
    }

    $sdkCandidates = @(
        "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\MakeAppx.exe",
        "C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe"
    )
    foreach ($candidate in $sdkCandidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $pubCacheRoot = Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev"
    $candidate = Get-ChildItem -Directory -Path $pubCacheRoot -Filter "msix-*" -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        ForEach-Object { Join-Path $_.FullName "lib\assets\MSIX-Toolkit\Redist.x64\MakeAppx.exe" } |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1

    if (-not $candidate) {
        throw "Unable to find MakeAppx.exe for MSIX canonicalization."
    }

    return $candidate
}

function Inspect-MsixManifest([string]$msixPath, [string]$workingName) {
    $zipPath = Join-Path $distDir "tmp\$workingName.zip"
    $extractDir = Join-Path $distDir "tmp\$workingName"
    if (Test-Path $zipPath) {
        Remove-Item -Path $zipPath -Force
    }
    if (Test-Path $extractDir) {
        Remove-Item -Path $extractDir -Recurse -Force
    }

    Copy-Item $msixPath -Destination $zipPath -Force
    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
    $manifestPath = Join-Path $extractDir "AppxManifest.xml"
    if (-not (Test-Path $manifestPath)) {
        throw "Packaged MSIX is missing AppxManifest.xml"
    }

    $manifestText = Get-Content -Path $manifestPath -Raw
    return @{
        ManifestText = $manifestText
        ExtractDir = $extractDir
        ZipPath = $zipPath
        ManifestPath = $manifestPath
    }
}

function Assert-CanonicalMsixManifest([string]$manifestText) {
    $requiredPatterns = @(
        "Identity Name=`"$identityName`"",
        "Publisher=`"$publisher`"",
        "Application Id=`"$appSlug`"",
        "Executable=`"$runnerExeName`"",
        "Alias=`"$executionAlias.exe`"",
        "Protocol Name=`"$protocolName`""
    )

    foreach ($pattern in $requiredPatterns) {
        if ($manifestText -notmatch [regex]::Escape($pattern)) {
            throw "Canonical MSIX manifest is missing expected value: $pattern"
        }
    }

    $legacyPatterns = @(
        'POKROV VPN',
        'Hiddify',
        'Id="hiddify"',
        'Identity Name="Pokrov\.Vpn"',
        'Publisher="CN=POKROV VPN"',
        'Alias="pokrovvpn\.exe"',
        'Protocol Name="pokrovvpn"'
    )

    if ($legacyPatterns | Where-Object { $manifestText -match $_ }) {
        throw "Legacy public Windows residue detected in MSIX manifest."
    }
}

function Rebuild-CanonicalMsix([string]$inputMsixPath, [string]$outputMsixPath) {
    $inspection = Inspect-MsixManifest -msixPath $inputMsixPath -workingName "msix-canonicalize"
    $manifestText = $inspection.ManifestText

    $manifestText = Replace-FirstMatch $manifestText '(<Identity Name=")([^"]+)(" Version=")' { param($m) "$($m.Groups[1].Value)$identityName$($m.Groups[3].Value)" } "identity name"
    $manifestText = Replace-FirstMatch $manifestText '(<Identity Name="[^"]+" Version="[^"]+"\s+Publisher=")([^"]+)(" ProcessorArchitecture=")' { param($m) "$($m.Groups[1].Value)$publisher$($m.Groups[3].Value)" } "publisher"
    $manifestText = Replace-FirstMatch $manifestText '(<Application Id=")([^"]+)(" Executable=")([^"]+)(" EntryPoint="Windows\.FullTrustApplication")' { param($m) "$($m.Groups[1].Value)$appSlug$($m.Groups[3].Value)$runnerExeName$($m.Groups[5].Value)" } "application identity"
    $manifestText = Replace-FirstMatch $manifestText '(<desktop:ExecutionAlias Alias=")([^"]+)(" />)' { param($m) "$($m.Groups[1].Value)$executionAlias.exe$($m.Groups[3].Value)" } "execution alias"
    $manifestText = Replace-FirstMatch $manifestText '(<uap:Protocol Name=")([^"]+)(">)' { param($m) "$($m.Groups[1].Value)$protocolName$($m.Groups[3].Value)" } "protocol name"
    $manifestText = Replace-FirstMatch $manifestText '(<uap:DisplayName>)([^<]+)( URI Scheme</uap:DisplayName>)' { param($m) "$($m.Groups[1].Value)$protocolName$($m.Groups[3].Value)" } "protocol display name"
    $manifestText = Replace-FirstMatch $manifestText '(<desktop:StartupTask TaskId=")([^"]+)(" Enabled=")' { param($m) "$($m.Groups[1].Value)$executionAlias$($m.Groups[3].Value)" } "startup task id"

    Assert-CanonicalMsixManifest -manifestText $manifestText
    Set-Content -Path $inspection.ManifestPath -Value $manifestText -Encoding utf8 -NoNewline

    foreach ($path in @(
        $inspection.ZipPath,
        (Join-Path $inspection.ExtractDir "AppxBlockMap.xml"),
        (Join-Path $inspection.ExtractDir "AppxSignature.p7x"),
        (Join-Path $inspection.ExtractDir "[Content_Types].xml")
    )) {
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Force
        }
    }

    $metadataDir = Join-Path $inspection.ExtractDir "AppxMetadata"
    if (Test-Path $metadataDir) {
        Remove-Item -Path $metadataDir -Recurse -Force
    }

    $makeAppxPath = Resolve-MakeAppxPath
    if (Test-Path $outputMsixPath) {
        Remove-Item -Path $outputMsixPath -Force
    }

    & $makeAppxPath pack /d $inspection.ExtractDir /p $outputMsixPath /o | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "MSIX canonicalization failed."
    }

    Remove-Item -Path $inspection.ExtractDir -Recurse -Force
}

Assert-CanonicalConfig
Sync-WindowsBrandingAssets

$brandingReferenceUtc = (Get-Item $brandingSourceIcon).LastWriteTimeUtc

New-Item -ItemType Directory -Force -Path (Join-Path $distDir "tmp") | Out-Null
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

if (Test-Path $portableStageDir) {
    Remove-Item -Path $portableStageDir -Recurse -Force
}

foreach ($artifact in @($canonicalExe, $canonicalMsix, $canonicalPortable)) {
    if (Test-Path $artifact) {
        Remove-Item -Path $artifact -Force
    }
}

$setupCandidate = Get-ChildItem -Recurse -File -Path $distDir -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -ieq "$outputBaseName.exe" -or
        $_.Name -like "*pokrov*setup*.exe" -or
        $_.Name -like "*hiddify*setup*.exe"
    } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $setupCandidate -or $setupCandidate.LastWriteTimeUtc -lt $brandingReferenceUtc) {
    Invoke-WindowsSetupPackaging
    $setupCandidate = Find-Artifact -patterns @("*pokrov*setup*.exe", "*hiddify*setup*.exe") -description "Windows setup"
}

Assert-ArtifactIsFresh -artifactPath $setupCandidate.FullName -description "Windows setup" -referenceTimestampUtc $brandingReferenceUtc
Copy-Item $setupCandidate.FullName -Destination $canonicalExe -Force

if (Test-Path $builtMsixPath) {
    Assert-ArtifactIsFresh -artifactPath $builtMsixPath -description "Windows MSIX" -referenceTimestampUtc $brandingReferenceUtc
    Rebuild-CanonicalMsix -inputMsixPath $builtMsixPath -outputMsixPath $canonicalMsix
} else {
    $msixCandidate = Find-Artifact -patterns @("*.msix") -description "Windows MSIX"
    Assert-ArtifactIsFresh -artifactPath $msixCandidate.FullName -description "Windows MSIX" -referenceTimestampUtc $brandingReferenceUtc
    Rebuild-CanonicalMsix -inputMsixPath $msixCandidate.FullName -outputMsixPath $canonicalMsix
}

$manifestInspection = Inspect-MsixManifest -msixPath $canonicalMsix -workingName "msix-verify"
Assert-CanonicalMsixManifest -manifestText $manifestInspection.ManifestText
Remove-Item -Path $manifestInspection.ExtractDir -Recurse -Force
Remove-Item -Path $manifestInspection.ZipPath -Force

if (-not (Test-Path $releaseRunnerDir)) {
    throw "Windows runner release directory not found at $releaseRunnerDir"
}
Assert-ArtifactIsFresh -artifactPath $runnerExePath -description "Windows runner executable" -referenceTimestampUtc $brandingReferenceUtc

xcopy $releaseRunnerDir $portableStageDir /E /H /C /I /Y | Out-Null
xcopy ".github\help\mac-windows\*.url" $portableStageDir /E /H /C /I /Y | Out-Null

$legacyResidue = Get-ChildItem -Path $portableStageDir -Recurse -File |
    Where-Object {
        $_.Name -like "*Hiddify*" -or $_.Name -like "*POKROVVPN*"
    }

if ($legacyResidue) {
    $legacyNames = $legacyResidue | ForEach-Object { $_.FullName }
    throw "Legacy Windows residue detected in portable package:`n$($legacyNames -join "`n")"
}

Compress-Archive -Force -Path $portableStageDir -DestinationPath $canonicalPortable

Write-Host "Windows packaging artifacts ready:"
Get-ChildItem -Path $outDir -File | Select-Object Name, Length
