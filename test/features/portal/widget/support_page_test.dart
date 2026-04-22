import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/support_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _FakeAppInfo extends AppInfo {
  _FakeAppInfo(this.value);

  final AppInfoEntity value;

  @override
  Future<AppInfoEntity> build() async => value;
}

void main() {
  testWidgets('shows in-app support composer and device context', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portalExperienceProvider.overrideWith((ref) async => _experience()),
          portalPublicConfigProvider.overrideWithValue(
            PortalPublicConfig.fromMap(const {
              'PORTAL_WEBAPP_URL': 'https://app.pokrov.space',
            }),
          ),
          appInfoProvider.overrideWith(
            () => _FakeAppInfo(
              const AppInfoEntity(
                name: 'POKROV',
                version: '2.4.0',
                buildNumber: '240',
                release: Release.general,
                operatingSystem: 'android',
                operatingSystemVersion: '14',
                environment: Environment.prod,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: SupportPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Get help fast'), findsOneWidget);
    expect(find.text('Android device\nAccount acc_1'), findsOneWidget);
    expect(find.text('Recent requests'), findsOneWidget);
    expect(find.text('Continue in web cabinet'), findsOneWidget);
    expect(find.text('Open Telegram support'), findsOneWidget);
    expect(find.text('Email support'), findsOneWidget);
    expect(find.text('Copy diagnostics'), findsOneWidget);
    expect(find.text('Chat with support now'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Billing issue'), findsOneWidget);
    expect(find.textContaining('App version: 2.4.0-beta'), findsOneWidget);
    expect(find.textContaining('Routing mode: all_except_ru'), findsOneWidget);
    expect(find.textContaining('Ruleset: 2026.04.13.rules'), findsOneWidget);
    expect(
      find.textContaining('Recovery order: app -> web -> telegram'),
      findsOneWidget,
    );
  });
}

PortalExperience _experience() {
  return const PortalExperience(
    isDemo: false,
    session: SessionSummary(
      tgId: 0,
      accountId: 'acc_1',
      deviceName: 'Android device',
      username: 'guest-acc_1',
      isAuthorized: true,
    ),
    dashboard: DashboardSummary(
      isActive: true,
      currentPlanLabel: 'Trial',
      statusHeadline: 'Ready to connect',
      statusBody: 'Your trial is active.',
      expiresAt: null,
      usedGb: 1,
      totalGb: 15,
      remainingGb: 14,
      activeSessions: 1,
      deviceLimit: 5,
      connectionKey: 'https://portal.example.test/sub/trial',
      healthyNodes: 2,
      totalNodes: 2,
    ),
    subscription: SubscriptionState(
      currentPlanCode: 'trial_5_days',
      currentPlanLabel: 'Trial',
      isTrialLike: true,
      checkoutEnabled: true,
      checkoutUrl: 'https://portal.example.test/checkout',
      payViaBotUrl: 'https://t.me/portal_service_bot',
      plans: [],
    ),
    checkout: null,
    usage: UsageStats(
      usedGb: 1,
      totalGb: 15,
      remainingGb: 14,
      activeSessions: 1,
      deviceLimit: 5,
      healthyNodes: 2,
      totalNodes: 2,
    ),
    supportThreads: [
      SupportThread(
        id: 1,
        subject: 'Billing issue',
        status: 'open',
        messages: [
          SupportMessage(
            id: 1,
            body: 'Need help with my renewal.',
            senderRole: 'user',
            createdAt: null,
          ),
        ],
      ),
    ],
    downloads: [],
    importPayload: ImportPayload(
      subscriptionUrl: 'https://portal.example.test/sub/trial',
      smartUrl: 'https://portal.example.test/sub/trial?format=smart',
      plainUrl: 'https://portal.example.test/sub/trial?format=plain',
      qrValue: 'https://portal.example.test/sub/trial',
      managedManifest: PortalManagedManifest(
        transportKind: 'managed-http',
        engineHint: 'sing-box',
        profileRevision: 'rev-7',
      ),
    ),
    connectionPolicy: PortalConnectionPolicy(
      routingModeDefault: 'all_except_ru',
      transportProfile: 'grpc_443_primary',
      dnsPolicy: 'ru_direct_split',
      packageCatalogVersion: '2026.04.13.1',
      rulesetVersion: '2026.04.13.rules',
      supportRecoveryOrder: ['app', 'web', 'telegram'],
      supportContext: PortalConnectionSupportContext(
        transport: 'grpc_443_primary',
        routingMode: 'all_except_ru',
        ipVersionPreference: 'ipv4_only',
      ),
    ),
  );
}
