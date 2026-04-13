import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';

void main() {
  test('builds checkout url with selected plan', () {
    expect(
      buildPortalCheckoutUrl(
        'https://pay.pokrov.space/checkout',
        planCode: 'pro_30',
      ),
      equals('https://pay.pokrov.space/checkout?plan=pro_30'),
    );
  });

  test('preserves existing query params when building checkout url', () {
    expect(
      buildPortalCheckoutUrl(
        'https://pay.pokrov.space/checkout?source=app',
        planCode: 'pro_30',
      ),
      equals('https://pay.pokrov.space/checkout?source=app&plan=pro_30'),
    );
  });

  test('builds rich support diagnostics and email body', () {
    const diagnostics = PortalSupportDiagnostics(
      accountId: 'acc_1',
      deviceName: 'Android phone',
      planCode: 'trial_5_days',
      appVersion: '2.4.0',
      platform: 'android',
      operatingSystemVersion: '14',
      linkedTelegramId: 7001,
      linkedTelegramUsername: 'alice',
      routingMode: 'all_except_ru',
      dnsPolicy: 'ru_direct_split',
      transportProfile: 'grpc_443_primary',
      transportKind: 'managed-http',
      engineHint: 'sing-box',
      profileRevision: 'rev-7',
      packageCatalogVersion: '2026.04.13.1',
      rulesetVersion: '2026.04.13.rules',
      supportRecoveryOrder: ['app', 'web', 'telegram'],
      webappUrl: 'https://app.pokrov.space',
    );

    final text = buildPortalDiagnosticsText(diagnostics: diagnostics);
    final uri = buildPortalSupportEmailUri(
      contactEmail: 'support@pokrov.space',
      diagnostics: diagnostics,
      appLabel: 'POKROV VPN',
    );

    expect(uri.toString(), contains('mailto:support@pokrov.space'));
    expect(
        uri.queryParameters['subject'], equals('POKROV VPN support request'));
    expect(text, contains('Account: acc_1'));
    expect(text, contains('Device: Android phone'));
    expect(text, contains('App version: 2.4.0'));
    expect(text, contains('Linked Telegram: @alice (7001)'));
    expect(text, contains('Routing mode: all_except_ru'));
    expect(text, contains('DNS policy: ru_direct_split'));
    expect(text, contains('Transport profile: grpc_443_primary'));
    expect(text, contains('Transport kind: managed-http'));
    expect(text, contains('Engine hint: sing-box'));
    expect(text, contains('Profile revision: rev-7'));
    expect(text, contains('Package catalog: 2026.04.13.1'));
    expect(text, contains('Ruleset: 2026.04.13.rules'));
    expect(text, contains('Recovery order: app -> web -> telegram'));
    expect(text, contains('Web cabinet: https://app.pokrov.space'));
    expect(
      uri.queryParameters['body'],
      contains('Account: acc_1'),
    );
    expect(
      uri.queryParameters['body'],
      contains('Device: Android phone'),
    );
    expect(
      uri.queryParameters['body'],
      contains('Plan: trial_5_days'),
    );
    expect(
      uri.queryParameters['body'],
      contains('Ruleset: 2026.04.13.rules'),
    );
    expect(
      uri.queryParameters['body'],
      contains('Recovery order: app -> web -> telegram'),
    );
  });
}
