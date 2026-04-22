import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';

void main() {
  group('PortalPublicConfig.fromMap', () {
    test('uses branded defaults when no overrides are provided', () {
      final config = PortalPublicConfig.fromMap(const {});

      expect(config.brandName, equals('POKROV'));
      expect(config.apiBaseUrl, equals('https://api.pokrov.space'));
      expect(config.webappUrl, equals('https://app.pokrov.space'));
      expect(config.checkoutUrl, equals('https://pay.pokrov.space/checkout'));
      expect(config.botUrl, equals('https://t.me/pokrov_vpnbot'));
      expect(
        config.supportTelegramUrl,
        equals('https://t.me/pokrov_supportbot'),
      );
      expect(config.contactEmail, equals('support@pokrov.space'));
      expect(config.hasRemoteSessionAuth, isFalse);
      expect(config.isDemoMode, isTrue);
    });

    test('normalizes overrides and turns off demo mode when auth is provided',
        () {
      final config = PortalPublicConfig.fromMap(const {
        'PORTAL_BRAND_NAME': 'Portal One',
        'PORTAL_API_BASE_URL': 'https://api.example.test/',
        'PORTAL_WEBAPP_URL': 'https://portal.example.test/webapp/',
        'PORTAL_CHECKOUT_URL': 'https://pay.example.test/checkout/',
        'PORTAL_BOT_URL': '@portal_one_bot',
        'PORTAL_SUPPORT_TG_URL': 'portal_helpdesk',
        'PORTAL_ANDROID_APK_URL': 'https://cdn.example.test/android.apk',
        'PORTAL_WINDOWS_EXE_URL': 'https://cdn.example.test/windows.exe',
        'PORTAL_DOCS_URL': 'https://docs.example.test/install',
        'PORTAL_WEB_SESSION_TOKEN': 'session-token',
      });

      expect(config.brandName, equals('Portal One'));
      expect(config.apiBaseUrl, equals('https://api.example.test'));
      expect(config.webappUrl, equals('https://portal.example.test/webapp'));
      expect(config.checkoutUrl, equals('https://pay.example.test/checkout'));
      expect(config.botUrl, equals('https://t.me/portal_one_bot'));
      expect(config.supportTelegramUrl, equals('https://t.me/portal_helpdesk'));
      expect(
        config.androidApkUrl,
        equals('https://cdn.example.test/android.apk'),
      );
      expect(
        config.windowsExeUrl,
        equals('https://cdn.example.test/windows.exe'),
      );
      expect(config.docsUrl, equals('https://docs.example.test/install'));
      expect(config.hasRemoteSessionAuth, isTrue);
      expect(config.isDemoMode, isFalse);
    });

    test('falls back to canonical hosts when environment values are blank', () {
      final config = PortalPublicConfig.fromMap(const {
        'PORTAL_API_BASE_URL': '',
        'PORTAL_WEBAPP_URL': '   ',
        'PORTAL_CHECKOUT_URL': '',
        'PORTAL_BOT_URL': '',
        'PORTAL_SUPPORT_TG_URL': '',
        'PORTAL_BRAND_NAME': '',
      });

      expect(config.brandName, equals('POKROV'));
      expect(config.apiBaseUrl, equals('https://api.pokrov.space'));
      expect(config.webappUrl, equals('https://app.pokrov.space'));
      expect(config.checkoutUrl, equals('https://pay.pokrov.space/checkout'));
      expect(config.botUrl, equals('https://t.me/pokrov_vpnbot'));
      expect(
        config.supportTelegramUrl,
        equals('https://t.me/pokrov_supportbot'),
      );
    });
  });
}
