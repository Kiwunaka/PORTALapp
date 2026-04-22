import 'package:hiddify/features/portal/config/shared_surface_facts.dart';

class PortalPublicConfig {
  const PortalPublicConfig({
    required this.brandName,
    required this.apiBaseUrl,
    required this.webappUrl,
    required this.checkoutUrl,
    required this.botUrl,
    required this.helpbotUrl,
    required this.supportTelegramUrl,
    required this.contactEmail,
    required this.enterpriseEmail,
    required this.contactFormUrl,
    required this.newsChannelUrl,
    required this.androidPlayUrl,
    required this.androidApkUrl,
    required this.androidMirrorUrl,
    required this.windowsExeUrl,
    required this.windowsMirrorUrl,
    required this.docsUrl,
    required this.webSessionToken,
    required this.telegramInitData,
  });

  final String brandName;
  final String apiBaseUrl;
  final String webappUrl;
  final String checkoutUrl;
  final String botUrl;
  final String helpbotUrl;
  final String supportTelegramUrl;
  final String contactEmail;
  final String enterpriseEmail;
  final String contactFormUrl;
  final String newsChannelUrl;
  final String androidPlayUrl;
  final String androidApkUrl;
  final String androidMirrorUrl;
  final String windowsExeUrl;
  final String windowsMirrorUrl;
  final String docsUrl;
  final String webSessionToken;
  final String telegramInitData;

  bool get hasRemoteSessionAuth =>
      webSessionToken.isNotEmpty || telegramInitData.isNotEmpty;

  bool get isDemoMode => !hasRemoteSessionAuth;

  factory PortalPublicConfig.environment() {
    return PortalPublicConfig.fromMap({
      if (const String.fromEnvironment('PORTAL_BRAND_NAME').trim().isNotEmpty)
        'PORTAL_BRAND_NAME': const String.fromEnvironment('PORTAL_BRAND_NAME'),
      if (const String.fromEnvironment('PORTAL_API_BASE_URL').trim().isNotEmpty)
        'PORTAL_API_BASE_URL':
            const String.fromEnvironment('PORTAL_API_BASE_URL'),
      if (const String.fromEnvironment('PORTAL_WEBAPP_URL').trim().isNotEmpty)
        'PORTAL_WEBAPP_URL': const String.fromEnvironment('PORTAL_WEBAPP_URL'),
      if (const String.fromEnvironment('PORTAL_CHECKOUT_URL').trim().isNotEmpty)
        'PORTAL_CHECKOUT_URL':
            const String.fromEnvironment('PORTAL_CHECKOUT_URL'),
      if (const String.fromEnvironment('PORTAL_BOT_URL').trim().isNotEmpty)
        'PORTAL_BOT_URL': const String.fromEnvironment('PORTAL_BOT_URL'),
      if (const String.fromEnvironment('PORTAL_HELPBOT_URL').trim().isNotEmpty)
        'PORTAL_HELPBOT_URL':
            const String.fromEnvironment('PORTAL_HELPBOT_URL'),
      if (const String.fromEnvironment('PORTAL_SUPPORT_TG_URL')
          .trim()
          .isNotEmpty)
        'PORTAL_SUPPORT_TG_URL':
            const String.fromEnvironment('PORTAL_SUPPORT_TG_URL'),
      if (const String.fromEnvironment('PORTAL_CONTACT_EMAIL')
          .trim()
          .isNotEmpty)
        'PORTAL_CONTACT_EMAIL':
            const String.fromEnvironment('PORTAL_CONTACT_EMAIL'),
      if (const String.fromEnvironment('PORTAL_ENTERPRISE_EMAIL')
          .trim()
          .isNotEmpty)
        'PORTAL_ENTERPRISE_EMAIL':
            const String.fromEnvironment('PORTAL_ENTERPRISE_EMAIL'),
      if (const String.fromEnvironment('PORTAL_CONTACT_FORM_URL')
          .trim()
          .isNotEmpty)
        'PORTAL_CONTACT_FORM_URL':
            const String.fromEnvironment('PORTAL_CONTACT_FORM_URL'),
      if (const String.fromEnvironment('PORTAL_NEWS_CHANNEL_URL')
          .trim()
          .isNotEmpty)
        'PORTAL_NEWS_CHANNEL_URL':
            const String.fromEnvironment('PORTAL_NEWS_CHANNEL_URL'),
      if (const String.fromEnvironment('PORTAL_ANDROID_PLAY_URL')
          .trim()
          .isNotEmpty)
        'PORTAL_ANDROID_PLAY_URL':
            const String.fromEnvironment('PORTAL_ANDROID_PLAY_URL'),
      if (const String.fromEnvironment('PORTAL_ANDROID_APK_URL')
          .trim()
          .isNotEmpty)
        'PORTAL_ANDROID_APK_URL':
            const String.fromEnvironment('PORTAL_ANDROID_APK_URL'),
      if (const String.fromEnvironment('PORTAL_ANDROID_MIRROR_URL')
          .trim()
          .isNotEmpty)
        'PORTAL_ANDROID_MIRROR_URL':
            const String.fromEnvironment('PORTAL_ANDROID_MIRROR_URL'),
      if (const String.fromEnvironment('PORTAL_WINDOWS_EXE_URL')
          .trim()
          .isNotEmpty)
        'PORTAL_WINDOWS_EXE_URL':
            const String.fromEnvironment('PORTAL_WINDOWS_EXE_URL'),
      if (const String.fromEnvironment('PORTAL_WINDOWS_MIRROR_URL')
          .trim()
          .isNotEmpty)
        'PORTAL_WINDOWS_MIRROR_URL':
            const String.fromEnvironment('PORTAL_WINDOWS_MIRROR_URL'),
      if (const String.fromEnvironment('PORTAL_DOCS_URL').trim().isNotEmpty)
        'PORTAL_DOCS_URL': const String.fromEnvironment('PORTAL_DOCS_URL'),
      if (const String.fromEnvironment('PORTAL_WEB_SESSION_TOKEN')
          .trim()
          .isNotEmpty)
        'PORTAL_WEB_SESSION_TOKEN':
            const String.fromEnvironment('PORTAL_WEB_SESSION_TOKEN'),
      if (const String.fromEnvironment('PORTAL_TELEGRAM_INIT_DATA')
          .trim()
          .isNotEmpty)
        'PORTAL_TELEGRAM_INIT_DATA':
            const String.fromEnvironment('PORTAL_TELEGRAM_INIT_DATA'),
    });
  }

  factory PortalPublicConfig.fromMap(Map<String, String> raw) {
    final apiBaseUrl = _cleanUrl(
      raw['PORTAL_API_BASE_URL'],
      fallback: PortalSharedPublicUrls.api,
    );
    final webBase = _cleanUrl(
      raw['PORTAL_WEBAPP_URL'],
      fallback: PortalSharedPublicUrls.webapp,
    );
    final checkoutUrl = _normalizeCheckoutUrl(
      raw['PORTAL_CHECKOUT_URL'],
      fallbackHost: PortalSharedPublicUrls.checkout,
    );
    final helpbotUrl = _normalizeTelegramUrl(
      raw['PORTAL_HELPBOT_URL'] ?? raw['PORTAL_SUPPORT_TG_URL'],
      fallback: PortalSharedPublicUrls.supportBot,
    );

    return PortalPublicConfig(
      brandName: _trim(
        raw['PORTAL_BRAND_NAME'],
        fallback: PortalSharedProductFacts.clientBrand,
      ),
      apiBaseUrl: apiBaseUrl,
      webappUrl: webBase,
      checkoutUrl: checkoutUrl,
      botUrl: _normalizeTelegramUrl(
        raw['PORTAL_BOT_URL'],
        fallback: PortalSharedPublicUrls.bot,
      ),
      helpbotUrl: helpbotUrl,
      supportTelegramUrl: helpbotUrl,
      contactEmail: _trim(
        raw['PORTAL_CONTACT_EMAIL'],
        fallback: PortalSharedPublicUrls.supportEmail,
      ),
      enterpriseEmail: _trim(
        raw['PORTAL_ENTERPRISE_EMAIL'],
        fallback: PortalSharedPublicUrls.enterpriseEmail,
      ),
      contactFormUrl: _normalizeTelegramUrl(
        raw['PORTAL_CONTACT_FORM_URL'],
        fallback: helpbotUrl,
      ),
      newsChannelUrl: _normalizeTelegramUrl(
        raw['PORTAL_NEWS_CHANNEL_URL'],
        fallback: PortalSharedPublicUrls.newsChannel,
      ),
      androidPlayUrl: _trim(raw['PORTAL_ANDROID_PLAY_URL']),
      androidApkUrl: _trim(raw['PORTAL_ANDROID_APK_URL']),
      androidMirrorUrl: _trim(raw['PORTAL_ANDROID_MIRROR_URL']),
      windowsExeUrl: _trim(raw['PORTAL_WINDOWS_EXE_URL']),
      windowsMirrorUrl: _trim(raw['PORTAL_WINDOWS_MIRROR_URL']),
      docsUrl: _trim(raw['PORTAL_DOCS_URL']),
      webSessionToken: _trim(raw['PORTAL_WEB_SESSION_TOKEN']),
      telegramInitData: _trim(raw['PORTAL_TELEGRAM_INIT_DATA']),
    );
  }
}

String _trim(String? value, {String fallback = ''}) {
  final normalized = value?.trim() ?? '';
  if (normalized.isNotEmpty) return normalized;
  return fallback.trim();
}

String _cleanUrl(String? value, {String fallback = ''}) {
  final normalized = _trim(value, fallback: fallback);
  if (normalized.isEmpty) return normalized;
  return normalized.replaceFirst(RegExp(r'/+$'), '');
}

String _normalizeTelegramUrl(String? raw, {required String fallback}) {
  final value = _cleanUrl(raw, fallback: fallback);
  if (value.isEmpty) return fallback;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  return 'https://t.me/${value.replaceFirst(RegExp('^@+'), '')}';
}

String _normalizeCheckoutUrl(String? raw, {required String fallbackHost}) {
  final value = _cleanUrl(raw);
  if (value.isNotEmpty) return value;
  final canonicalCheckout = _cleanUrl(PortalSharedPublicUrls.checkout);
  if (_cleanUrl(fallbackHost) == canonicalCheckout) {
    return canonicalCheckout;
  }
  return '${_cleanUrl(fallbackHost)}/checkout';
}
