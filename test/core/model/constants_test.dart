import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/model/constants.dart';

void main() {
  group('Constants', () {
    test('uses the final product name', () {
      expect(Constants.appName, 'POKROV');
    });

    test('uses branded support links', () {
      expect(
        Constants.githubUrl,
        anyOf(isEmpty, startsWith('https://')),
      );
      expect(
        Constants.githubReleasesApiUrl,
        anyOf(isEmpty, startsWith('https://')),
      );
      expect(
        Constants.githubLatestReleaseUrl,
        anyOf(isEmpty, startsWith('https://')),
      );
      expect(
        Constants.appCastUrl,
        anyOf(isEmpty, startsWith('https://')),
      );
      expect(Constants.githubUrl, isNot(contains('hiddify')));
      expect(
        Constants.githubUrl,
        isNot(contains('NikitaSH999/pokrov-vpn')),
      );
      expect(Constants.githubLatestReleaseUrl, isNot(contains('hiddify')));
      expect(
        Constants.githubLatestReleaseUrl,
        isNot(contains('NikitaSH999/pokrov-vpn')),
      );
      expect(Constants.appCastUrl, isNot(contains('hiddify')));
      expect(
        Constants.appCastUrl,
        isNot(contains('NikitaSH999/pokrov-vpn')),
      );
      expect(Constants.telegramChannelUrl, equals('https://t.me/pokrov_vpn'));
      expect(
          Constants.privacyPolicyUrl, equals('https://pokrov.space/privacy'),);
      expect(
        Constants.termsAndConditionsUrl,
        equals('https://pokrov.space/terms'),
      );
    });

    test('keeps release metadata opt-in outside signed release builds', () {
      expect(Constants.hasReleaseMetadata, isFalse);
    });
  });
}
