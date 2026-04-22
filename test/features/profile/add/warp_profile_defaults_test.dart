import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/profile/add/warp_profile_defaults.dart';

void main() {
  test('warp defaults use pokrov branding', () {
    expect(defaultWarpProfileName, equals('POKROV WARP'));
    expect(
        defaultCnWarpProfileContent, contains('#profile-title: POKROV WARP'),);
    expect(defaultCnWarpProfileContent, isNot(contains('Hiddify WARP')));
    expect(defaultWarpProfileUrl, isEmpty);
    expect(defaultWarpProfileContent,
        contains('//support-url: https://t.me/pokrov_supportbot'),);
    expect(defaultWarpProfileContent,
        contains('//profile-web-page-url: https://pokrov.space/'),);
    expect(
        defaultWarpProfileContent, isNot(contains('NikitaSH999/pokrov-vpn')),);
  });

  test('warp test config points to pokrov support surfaces', () async {
    final config = await File('test.configs/warp').readAsString();

    expect(config, contains('//support-url: https://t.me/pokrov_supportbot'));
    expect(config, contains('//profile-web-page-url: https://pokrov.space/'));
    expect(config, isNot(contains('https://t.me/hiddify')));
    expect(config, isNot(contains('https://hiddify.com')));
  });
}
