#!/usr/bin/env python3
from __future__ import annotations

import os
import re
import sys
from pathlib import Path
from urllib.parse import urlparse


def _read_env(name: str, default: str = "") -> str:
    return (os.getenv(name) or default).strip()


def _slugify(value: str) -> str:
    out = re.sub(r"[^a-zA-Z0-9]+", "", value)
    return out or "PortalApp"


def _replace(text: str, pattern: str, repl: str, *, count: int = 1) -> str:
    result, n = re.subn(pattern, repl, text, count=count, flags=re.MULTILINE)
    if n == 0:
        raise RuntimeError(f"pattern not found: {pattern}")
    return result


def _set_yaml_scalar(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf"^(?P<prefix>\s*{re.escape(key)}:\s*).*$", flags=re.MULTILINE)

    def repl(match: re.Match[str]) -> str:
        return f"{match.group('prefix')}{value}"

    out, n = pattern.subn(repl, text, count=1)
    if n == 0:
        raise RuntimeError(f"pattern not found: {key}:")
    return out


def _set_rc_value(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf'^(?P<prefix>\s*VALUE "{re.escape(key)}",\s*).*$', flags=re.MULTILINE)

    def repl(match: re.Match[str]) -> str:
        return f'{match.group("prefix")}"{value}" "\\0"'

    out, n = pattern.subn(repl, text, count=1)
    if n == 0:
        raise RuntimeError(f'pattern not found: VALUE "{key}",')
    return out


def _rewrite_constants(text: str, *, brand_name: str) -> str:
    return _replace(
        text,
        r'static const appName = ".*?";',
        f'static const appName = "{brand_name}";',
    )


def _rewrite_windows_exe_config(
    text: str,
    *,
    publisher_name: str,
    publisher_url: str,
    display_name: str,
    exe_name: str,
    output_base_file_name: str,
    install_dir_name: str,
) -> str:
    out = _set_yaml_scalar(text, "publisher", publisher_name)
    out = _set_yaml_scalar(out, "publisher_url", publisher_url)
    out = _set_yaml_scalar(out, "display_name", display_name)
    out = _set_yaml_scalar(out, "executable_name", exe_name)
    out = _set_yaml_scalar(out, "output_base_file_name", output_base_file_name)
    out = _set_yaml_scalar(out, "install_dir_name", install_dir_name)
    return out


def _repo_urls(repo_url: str) -> tuple[str, str, str]:
    parsed = urlparse(repo_url)
    host = parsed.netloc.lower()
    path = parsed.path.strip("/")
    if host != "github.com" or "/" not in path:
        base = repo_url.rstrip("/")
        return (
            repo_url,
            f"{base}/releases",
            f"{base}/releases/latest/download/appcast.xml",
        )
    owner, repo = path.split("/", 1)
    owner = owner.strip()
    repo = repo.strip()
    api = f"https://api.github.com/repos/{owner}/{repo}/releases"
    appcast = (
        f"https://github.com/{owner}/{repo}/releases/latest/download/appcast.xml"
    )
    return repo_url, api, appcast


def _patch_file(path: Path, fn) -> None:
    original = path.read_text(encoding="utf-8")
    updated = fn(original)
    if updated != original:
        path.write_text(updated, encoding="utf-8", newline="\n")
        print(f"[updated] {path}")
    else:
        print(f"[unchanged] {path}")


def _rewrite_android_manifest(text: str, brand_name: str, uri_scheme: str) -> str:
    out = _replace(
        text,
        r'android:label="[^"]+"',
        f'android:label="{brand_name}"',
    )

    def _rewrite_scheme_for_host(current: str, host: str) -> str:
        pattern = re.compile(
            rf'<data android:scheme="[^"]+" />\s*<data android:host="{re.escape(host)}" />',
            flags=re.MULTILINE,
        )
        replacement = (
            f'<data android:scheme="{uri_scheme}" />\n'
            f'                <data android:scheme="pokrovvpn" />\n'
            f'                <data android:host="{host}" />'
        )
        updated, n = pattern.subn(replacement, current, count=1)
        if n == 0:
            raise RuntimeError(f"pattern not found for Android manifest host: {host}")
        return updated

    out = _rewrite_scheme_for_host(out, "install-sub")
    out = _rewrite_scheme_for_host(out, "import")
    return out


def main() -> int:
    app_root = Path(__file__).resolve().parents[2]

    brand_name = _read_env("FORK_BRAND_NAME", "POKROV")
    repo_url = _read_env("FORK_REPO_URL", "")
    if not repo_url:
        gh_repo = _read_env("GITHUB_REPOSITORY", "")
        if not gh_repo:
            raise RuntimeError(
                "FORK_REPO_URL or GITHUB_REPOSITORY must be set for release branding."
            )
        repo_url = f"https://github.com/{gh_repo}"

    android_app_id = _read_env("FORK_ANDROID_APPLICATION_ID", "space.pokrov.vpn")
    # Keep the Android namespace aligned with the existing Kotlin package tree
    # unless the fork intentionally migrates source packages as well.
    android_namespace = _read_env("FORK_ANDROID_NAMESPACE", "com.hiddify.hiddify")
    android_test_namespace = _read_env(
        "FORK_ANDROID_TEST_NAMESPACE",
        "test.com.hiddify.hiddify",
    )
    uri_scheme = _read_env("FORK_URI_SCHEME", "pokrov")

    windows_identity_name = _read_env("FORK_WINDOWS_IDENTITY_NAME", "pokrov")
    windows_publisher_name = _read_env("FORK_WINDOWS_PUBLISHER_NAME", brand_name)
    windows_publisher_url = _read_env(
        "FORK_WINDOWS_PUBLISHER_URL",
        "https://pokrov.space/",
    )
    windows_install_dir = _read_env("FORK_WINDOWS_INSTALL_DIR", brand_name)
    exe_stem = _read_env("FORK_WINDOWS_EXE_STEM", "POKROV")
    windows_output_base_file_name = _read_env(
        "FORK_WINDOWS_OUTPUT_BASE_FILE_NAME",
        "pokrov-windows-setup-x64",
    )
    exe_name = f"{exe_stem}.exe"
    copyright_line = _read_env(
        "FORK_COPYRIGHT",
        f"Copyright (C) {windows_publisher_name}. All rights reserved.",
    )

    repo_url, releases_api_url, appcast_url = _repo_urls(repo_url)
    latest_release_url = f"{repo_url.rstrip('/')}/releases/latest"
    internal_name = _slugify(exe_stem).lower()
    mutex_name = f"{_slugify(exe_stem)}Mutex"

    print("[branding]")
    print(f"  brand_name={brand_name}")
    print(f"  repo_url={repo_url}")
    print(f"  android_app_id={android_app_id}")
    print(f"  android_namespace={android_namespace}")
    print(f"  windows_identity_name={windows_identity_name}")
    print(f"  windows_publisher_url={windows_publisher_url}")
    print(f"  windows_exe={exe_name}")
    print(f"  uri_scheme={uri_scheme}")

    _patch_file(
        app_root / "lib/core/model/constants.dart",
        lambda t: _rewrite_constants(t, brand_name=brand_name),
    )

    _patch_file(
        app_root / "android/app/build.gradle",
        lambda t: _replace(
            _replace(
                _replace(
                    t,
                    r"namespace\s+'[^']+'",
                    f"namespace '{android_namespace}'",
                ),
                r'testNamespace\s+"[^"]+"',
                f'testNamespace "{android_test_namespace}"',
            ),
            r'applicationId\s+"[^"]+"',
            f'applicationId "{android_app_id}"',
        ),
    )

    _patch_file(
        app_root / "android/app/src/main/AndroidManifest.xml",
        lambda t: _rewrite_android_manifest(t, brand_name, uri_scheme),
    )

    _patch_file(
        app_root / "windows/CMakeLists.txt",
        lambda t: _replace(
            _replace(
                t,
                r"^project\([^)]+\)$",
                f"project({internal_name} LANGUAGES CXX)",
            ),
            r'set\(BINARY_NAME\s+"[^"]+"\)',
            f'set(BINARY_NAME "{exe_stem}")',
        ),
    )

    _patch_file(
        app_root / "windows/runner/main.cpp",
        lambda t: _replace(
            _replace(
                _replace(
                    _replace(
                        t,
                        r'CreateMutex\(NULL,\s*TRUE,\s*L"[^"]+"\)',
                        f'CreateMutex(NULL, TRUE, L"{mutex_name}")',
                    ),
                    r'FindWindowA\(NULL,\s*"[^"]+"\)',
                    f'FindWindowA(NULL, "{brand_name}")',
                ),
                r'window\.SendAppLinkToInstance\(L"[^"]+"\)',
                f'window.SendAppLinkToInstance(L"{brand_name}")',
            ),
            r'window\.Create\(L"[^"]+",\s*origin,\s*size\)',
            f'window.Create(L"{brand_name}", origin, size)',
        ),
    )

    _patch_file(
        app_root / "windows/packaging/msix/make_config.yaml",
        lambda t: _set_yaml_scalar(
            _set_yaml_scalar(
                _set_yaml_scalar(
                    _set_yaml_scalar(
                        _set_yaml_scalar(
                            _set_yaml_scalar(
                                t,
                                "display_name",
                                brand_name,
                            ),
                            "publisher",
                            f"CN={windows_publisher_name}",
                        ),
                        "publisher_display_name",
                        windows_publisher_name,
                    ),
                    "identity_name",
                    windows_identity_name,
                ),
                "protocol_activation",
                uri_scheme,
            ),
            "execution_alias",
            internal_name,
        ),
    )

    _patch_file(
        app_root / "windows/packaging/exe/make_config.yaml",
        lambda t: _rewrite_windows_exe_config(
            t,
            publisher_name=windows_publisher_name,
            publisher_url=windows_publisher_url,
            display_name=brand_name,
            exe_name=exe_name,
            output_base_file_name=windows_output_base_file_name,
            install_dir_name=f'"{{autopf64}}\\\\{windows_install_dir}"',
        ),
    )

    _patch_file(
        app_root / "windows/runner/Runner.rc",
        lambda t: _set_rc_value(
            _set_rc_value(
                _set_rc_value(
                    _set_rc_value(
                        _set_rc_value(
                            _set_rc_value(
                                t,
                                "CompanyName",
                                windows_publisher_name,
                            ),
                            "FileDescription",
                            brand_name,
                        ),
                        "InternalName",
                        internal_name,
                    ),
                    "LegalCopyright",
                    copyright_line,
                ),
                "OriginalFilename",
                exe_name,
            ),
            "ProductName",
            brand_name,
        ),
    )

    _patch_file(
        app_root / "windows/packaging/exe/inno_setup.sas",
        lambda t: _replace(
            t,
            r"Exec\('taskkill', '/F /IM [^']+'",
            f"Exec('taskkill', '/F /IM {exe_name}'",
        ),
    )

    print("[done] branding overrides applied")
    return 0


if __name__ == "__main__":
    sys.exit(main())
