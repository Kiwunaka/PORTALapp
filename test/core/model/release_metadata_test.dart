import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'fork tag publishing is isolated to the android and windows release workflow',
      () async {
    final workflowDirectory = Directory('.github/workflows');
    final workflows = workflowDirectory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.yml'))
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path));

    final tagPublishingWorkflows = <String>[];
    for (final workflow in workflows) {
      final contents = await workflow.readAsString();
      if (contents.contains('push:') && contents.contains('tags:')) {
        tagPublishingWorkflows.add(workflow.uri.pathSegments.last);
      }
    }

    expect(tagPublishingWorkflows, ['fork-android-windows-release.yml']);
  });

  test('appcast points to pokrov release artifacts', () async {
    final xml = await File('appcast.xml').readAsString();

    expect(xml, contains('RELEASE_REPOSITORY'));
    expect(xml, contains('RELEASE_TAG'));
    expect(xml, contains('RELEASE_VERSION'));
    expect(xml, contains('RELEASE_PUB_DATE'));
    expect(xml, contains('pokrov-vpn-android-universal.apk'));
    expect(xml, contains('pokrov-vpn-windows-setup-x64.exe'));
    expect(xml, isNot(contains('hiddify-next')));
    expect(xml, isNot(contains('app.hiddify.com')));
    expect(xml, isNot(contains('NikitaSH999/pokrov-vpn')));
  });

  test('web manifest uses pokrov branding', () async {
    final manifest = await File('web/manifest.json').readAsString();

    expect(manifest, contains('"name": "POKROV VPN"'));
    expect(manifest, contains('"short_name": "POKROV"'));
    expect(manifest, isNot(contains('"name": "Hiddify"')));
  });

  test('store descriptions avoid hardcoded personal repository links',
      () async {
    final assetsDirectory = Directory('assets/translations');
    final translationFiles = assetsDirectory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.i18n.json'))
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path));
    final generatedTranslations = await File(
      'lib/gen/translations.g.dart',
    ).readAsString();

    expect(translationFiles, isNotEmpty);
    for (final file in translationFiles) {
      final contents = await file.readAsString();
      expect(
        contents,
        isNot(contains('https://github.com/hiddify/hiddify-next')),
        reason: 'legacy repository URL leaked into ${file.path}',
      );
      if (contents.contains('"full_description"')) {
        expect(
          contents,
          isNot(contains('https://github.com/NikitaSH999/pokrov-vpn')),
          reason: 'personal repository URL leaked into ${file.path}',
        );
      }
    }

    expect(
      generatedTranslations,
      isNot(contains('https://github.com/hiddify/hiddify-next')),
    );
    expect(
      generatedTranslations,
      isNot(contains('https://github.com/NikitaSH999/pokrov-vpn')),
    );
    expect(
      generatedTranslations,
      contains('open-source Sing-Box'),
    );
  });

  test('release URLs are provided through build-time defines', () async {
    final constants =
        await File('lib/core/model/constants.dart').readAsString();
    final warpDefaults = await File(
      'lib/features/profile/add/warp_profile_defaults.dart',
    ).readAsString();
    final makefile = await File('Makefile').readAsString();
    final workflow = await File(
      '.github/workflows/fork-android-windows-release.yml',
    ).readAsString();

    expect(constants, contains('PORTAL_RELEASE_REPOSITORY_URL'));
    expect(constants, contains('PORTAL_RELEASES_API_URL'));
    expect(constants, contains('PORTAL_RELEASES_LATEST_URL'));
    expect(constants, contains('PORTAL_RELEASES_APPCAST_URL'));
    expect(warpDefaults, contains('PORTAL_WARP_DEFAULTS_URL'));
    expect(makefile, contains('PORTAL_RELEASE_REPOSITORY_URL'));
    expect(makefile, contains('PORTAL_RELEASES_APPCAST_URL'));
    expect(workflow, contains('PORTAL_RELEASE_REPOSITORY_URL'));
    expect(workflow, contains('PORTAL_WARP_DEFAULTS_URL'));
  });

  test('localized branding uses pokrov naming in release metadata', () async {
    final arabic = jsonDecode(
      await File('assets/translations/strings_ar.i18n.json').readAsString(),
    ) as Map<String, dynamic>;
    final kurdish = jsonDecode(
      await File(
        'assets/translations/strings_ckb-KUR.i18n.json',
      ).readAsString(),
    ) as Map<String, dynamic>;
    final persian = jsonDecode(
      await File('assets/translations/strings_fa.i18n.json').readAsString(),
    ) as Map<String, dynamic>;

    expect(arabic['general']['appTitle'], 'POKROV Network');
    expect(kurdish['general']['appTitle'], 'POKROV Network');
    expect(persian['general']['appTitle'], 'POKROV Network');

    final kurdishText = kurdish['play']['full_description'] as String;
    final persianText = persian['play']['full_description'] as String;
    expect(kurdishText, isNot(contains('NikitaSH999/pokrov-vpn')));
    expect(persianText, isNot(contains('NikitaSH999/pokrov-vpn')));
    expect(persianText, contains('POKROV Network'));
  });
  test('release message and apple readiness metadata use pokrov branding',
      () async {
    final releaseMessage =
        await File('.github/release_message.md').readAsString();
    final iosInfoPlist = await File('ios/Runner/Info.plist').readAsString();
    final iosPackagingConfig = await File(
      'ios/packaging/ios/make_config.yaml',
    ).readAsString();

    expect(releaseMessage, contains('pokrov-vpn-android-universal.apk'));
    expect(releaseMessage, contains('pokrov-vpn-windows-setup-x64.exe'));
    expect(
      releaseMessage,
      isNot(contains('Hiddify-Windows-Setup-x64.exe')),
    );
    expect(releaseMessage, isNot(contains('github.com/hiddify/hiddify-next')));
    expect(releaseMessage, contains('RELEASE_REPOSITORY'));
    expect(releaseMessage, contains('RELEASE_HISTORY_URL'));
    expect(releaseMessage, isNot(contains('NikitaSH999/pokrov-vpn')));
    expect(releaseMessage, isNot(contains('macOS')));
    expect(releaseMessage, isNot(contains('Linux')));

    expect(iosInfoPlist, contains('<string>POKROV VPN</string>'));
    expect(iosInfoPlist, isNot(contains('<string>Hiddify</string>')));
    expect(iosPackagingConfig, contains('display_name: POKROV VPN'));
    expect(iosPackagingConfig, contains('generic_name: POKROV VPN'));
    expect(iosPackagingConfig, isNot(contains('display_name: Hiddify')));
  });

  test('windows packaging uses only pokrov helper binary names', () async {
    final windowsCmake = await File('windows/CMakeLists.txt').readAsString();
    final buildScript = await File('libcore/build_windows.bat').readAsString();
    final makefile = await File('libcore/Makefile').readAsString();

    expect(windowsCmake, contains('POKROVCli.exe'));
    expect(windowsCmake, isNot(contains('RENAME HiddifyCli.exe')));
    expect(buildScript, contains('POKROVCli.exe'));
    expect(buildScript, isNot(contains('bin\\HiddifyCli.exe')));
    expect(makefile, contains('CLINAME=POKROVCli'));
    expect(makefile, isNot(contains('CLINAME=HiddifyCli')));
  });

  test('release automation defaults use pokrov release identifiers', () async {
    final releaseSetup =
        await File('.github/FORK_RELEASE_SETUP.md').readAsString();
    final windowsStoreReleaseWorkflow = await File(
      '.github/workflows/add_signed_microsft.yml',
    ).readAsString();
    final wingetWorkflow = await File(
      '.github/workflows/winget.yml',
    ).readAsString();
    final legacyBuildWorkflow = await File(
      '.github/workflows/build.yml',
    ).readAsString();

    expect(releaseSetup, contains('space.pokrov.vpn'));
    expect(releaseSetup, isNot(contains('defaults to `app.hiddify.com`')));
    expect(
        windowsStoreReleaseWorkflow, contains('pokrov-vpn-windows-setup-x64'));
    expect(
      windowsStoreReleaseWorkflow,
      isNot(contains('asset-name-pattern: Hiddify-Windows-Setup-x64')),
    );
    expect(windowsStoreReleaseWorkflow, isNot(contains('schedule:')));
    expect(
      windowsStoreReleaseWorkflow,
      contains("startsWith(github.event.release.tag_name, 'v')"),
    );
    expect(wingetWorkflow, contains('Pokrov.Vpn'));
    expect(wingetWorkflow, isNot(contains('Hiddify.Next')));
    expect(
      legacyBuildWorkflow,
      contains(r'RELEASE_REPOSITORY: ${{ github.repository }}'),
    );
    expect(
      legacyBuildWorkflow,
      contains(
        "RELEASE_DEFAULT_BRANCH: \${{ github.event.repository.default_branch || 'main' }}",
      ),
    );
    expect(
      legacyBuildWorkflow,
      contains(
          'https://api.github.com/repos/\${RELEASE_REPOSITORY}/releases/latest'),
    );
    expect(
      legacyBuildWorkflow,
      contains(
        'https://github.com/\${RELEASE_REPOSITORY}/blob/\${RELEASE_DEFAULT_BRANCH}/HISTORY.md',
      ),
    );
    expect(
      legacyBuildWorkflow,
      isNot(
        contains(
            'https://api.github.com/repos/hiddify/hiddify-next/releases/latest'),
      ),
    );
  });

  test('fork release workflow is the only publish path and generates appcast',
      () async {
    final releaseWorkflow =
        await File('.github/workflows/release.yml').readAsString();
    final forkReleaseWorkflow = await File(
      '.github/workflows/fork-android-windows-release.yml',
    ).readAsString();
    final brandingScript = await File(
      '.github/scripts/apply_fork_branding.py',
    ).readAsString();

    expect(
        releaseWorkflow, contains('Legacy release.yml publishing is disabled'));
    expect(releaseWorkflow,
        isNot(contains('uses: ./.github/workflows/build.yml')));
    expect(forkReleaseWorkflow, contains('validate-release-inputs'));
    expect(forkReleaseWorkflow, contains('ANDROID_SIGNING_KEY'));
    expect(forkReleaseWorkflow, contains('WINDOWS_SIGNING_KEY'));
    expect(forkReleaseWorkflow, contains('sed \\'));
    expect(forkReleaseWorkflow,
        contains('appcast.xml > release-meta/appcast.xml'));
    expect(
      forkReleaseWorkflow,
      contains(r'TAG="${{ needs.prepare.outputs.tag }}"'),
    );
    expect(forkReleaseWorkflow, contains(r'VERSION="${TAG#v}"'));
    expect(
      forkReleaseWorkflow,
      contains(r'releases/download/${TAG}/${APP_SLUG}-android-universal.apk'),
    );
    expect(
      forkReleaseWorkflow,
      contains(r'releases/download/${TAG}/${APP_SLUG}-windows-setup-x64.exe'),
    );
    expect(forkReleaseWorkflow, contains('release-meta/appcast.xml'));
    expect(
      brandingScript,
      contains('releases/latest/download/appcast.xml'),
      reason:
          'fork branding should point updater checks at the latest release asset',
    );
    expect(brandingScript, isNot(contains('NikitaSH999/pokrov-vpn')));
    expect(
      brandingScript,
      contains('FORK_REPO_URL or GITHUB_REPOSITORY must be set'),
    );
    expect(
      forkReleaseWorkflow,
      isNot(contains(r"if: ${{ secrets.ANDROID_SIGNING_KEY != ''")),
    );
    expect(
      forkReleaseWorkflow,
      isNot(contains(r"if: ${{ secrets.WINDOWS_SIGNING_KEY != ''")),
    );
  });

  test(
      'windows packaging strips legacy release residue and dev signing defaults',
      () async {
    final msixConfig = await File(
      'windows/packaging/msix/make_config.yaml',
    ).readAsString();
    final exeConfig = await File(
      'windows/packaging/exe/make_config.yaml',
    ).readAsString();
    final innoTemplate = await File(
      'windows/packaging/exe/inno_setup.sas',
    ).readAsString();
    final packageScript =
        await File('scripts/package_windows.ps1').readAsString();

    expect(msixConfig, contains('certificate_password: ""'));
    expect(msixConfig, isNot(contains('portalvpn-dev')));
    expect(exeConfig, contains('publisher_url: https://pokrov.space/'));
    expect(exeConfig,
        contains('output_base_file_name: pokrov-vpn-windows-setup-x64'));
    expect(innoTemplate, isNot(contains('HiddifyTunnelService')));
    expect(packageScript, isNot(contains('HiddifyCli.exe')));
    expect(packageScript, contains('*pokrov*setup*.exe'));
    expect(packageScript, contains('Legacy Windows residue detected'));
  });

  test('libcore windows build script does not mutate module dependencies',
      () async {
    final buildScript = await File('libcore/build_windows.bat').readAsString();
    final goMod = await File('libcore/go.mod').readAsString();

    expect(buildScript, isNot(contains('go get github.com/akavel/rsrc')));
    expect(buildScript, contains('go install github.com/akavel/rsrc@v0.10.2'));
    expect(goMod, isNot(contains('github.com/akavel/rsrc')));
  });

  test('libcore release helpers use pokrov cli naming', () async {
    final dockerScript = await File('libcore/docker/hiddify.sh').readAsString();
    final legacyBuildWorkflow =
        await File('libcore/.github/workflows/build.yml').readAsString();

    expect(dockerScript, contains('/hiddify/POKROVCli run'));
    expect(dockerScript, isNot(contains('/hiddify/HiddifyCli run')));
    expect(legacyBuildWorkflow, contains('POKROVCli(\\.exe)?'));
    expect(legacyBuildWorkflow, isNot(contains('HiddifyCli(\\.exe)?')));
  });

  test('branding automation and test harness avoid legacy hiddify fallbacks',
      () async {
    final brandingScript = await File(
      '.github/scripts/apply_fork_branding.py',
    ).readAsString();
    final flutterTestConfig = await File(
      'test/flutter_test_config.dart',
    ).readAsString();

    expect(
      brandingScript,
      isNot(contains('NikitaSH999/pokrov-vpn')),
    );
    expect(
      brandingScript,
      contains(
          'FORK_REPO_URL or GITHUB_REPOSITORY must be set for release branding.'),
    );
    expect(brandingScript, contains('releases/latest/download/appcast.xml'));
    expect(flutterTestConfig, contains('dist/tmp/pokrov-vpn/sqlite3.dll'));
    expect(flutterTestConfig,
        isNot(contains('dist/tmp/hiddify-next/sqlite3.dll')));
  });
}
