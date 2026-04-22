import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'public versioning and visible packaging metadata use the pokrov beta line',
      () async {
    final pubspec = await File('pubspec.yaml').readAsString();
    final readme = await File('README.md').readAsString();
    final appcast = await File('appcast.xml').readAsString();
    final exeConfig = await File(
      'windows/packaging/exe/make_config.yaml',
    ).readAsString();
    final msixConfig = await File(
      'windows/packaging/msix/make_config.yaml',
    ).readAsString();
    final runnerResource =
        await File('windows/runner/Runner.rc').readAsString();
    final runnerMain = await File('windows/runner/main.cpp').readAsString();

    expect(pubspec, contains('version: 0.9.0-beta+20508'));
    expect(pubspec, contains('description: POKROV for Windows and Android.'));
    expect(pubspec, contains('display_name: POKROV'));
    expect(pubspec, contains('publisher_display_name: POKROV'));
    expect(pubspec, contains('msix_version: 2.5.8.0'));
    expect(pubspec, contains('output_name: pokrov-windows-setup-x64'));

    expect(readme, contains('# POKROV'));
    expect(readme, contains('public beta line: `0.9.0-beta`'));
    expect(readme, isNot(contains('POKROV VPN')));

    expect(appcast, contains('<title>POKROV Release Feed</title>'));
    expect(appcast, isNot(contains('POKROV VPN Release Feed')));

    expect(exeConfig, contains('publisher: POKROV'));
    expect(exeConfig, contains('display_name: POKROV'));
    expect(
        exeConfig, contains('output_base_file_name: pokrov-windows-setup-x64'),);
    expect(exeConfig, contains('install_dir_name: "{autopf64}\\\\POKROV"'));

    expect(msixConfig, contains('display_name: POKROV'));
    expect(msixConfig, contains('publisher_display_name: POKROV'));
    expect(msixConfig, contains('identity_name: pokrov'));
    expect(msixConfig, contains('msix_version: 2.5.8.0'));
    expect(msixConfig, contains('protocol_activation: pokrov'));
    expect(msixConfig, contains('execution_alias: pokrov'));
    expect(msixConfig, contains('publisher: CN=POKROV'));

    expect(runnerResource, contains('VALUE "CompanyName", "POKROV"'));
    expect(runnerResource, contains('VALUE "FileDescription", "POKROV"'));
    expect(runnerResource, contains('VALUE "OriginalFilename", "POKROV.exe"'));
    expect(runnerResource, contains('VALUE "ProductName", "POKROV"'));

    expect(runnerMain, contains('FindWindowA(NULL, "POKROV")'));
    expect(runnerMain, contains('window.SendAppLinkToInstance(L"POKROV")'));
    expect(runnerMain, isNot(contains('POKROV VPN')));
    expect(runnerMain, contains('window.Create(L"POKROV"'));
  });
}
