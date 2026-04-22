import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/profile_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows profile rewards and telegram bonus entry point', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portalExperienceProvider.overrideWith((ref) async => _experience()),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('POKROV account'), findsOneWidget);
    expect(find.text('+10 bonus days with Telegram'), findsOneWidget);
    expect(find.text('Link Telegram'), findsOneWidget);
    expect(find.text('Check bonus'), findsOneWidget);
    expect(find.text('Automatic activation and key delivery'), findsOneWidget);
    expect(find.text('Automatic activation first'), findsOneWidget);
    expect(find.textContaining('Android / Windows'), findsOneWidget);
    expect(
        find.textContaining('Android / iOS / macOS / Windows'), findsOneWidget,);
    expect(find.text('Redeem or add access key'), findsOneWidget);
    expect(find.textContaining('NL-free'), findsOneWidget);
    expect(find.text('Access stays ready'), findsOneWidget);
    expect(find.text('Apps and documents'), findsOneWidget);
    expect(find.text('Open advanced settings'), findsOneWidget);
    expect(find.text('Advanced recovery tools'), findsOneWidget);
    expect(find.text('Settings recovery'), findsNothing);
    expect(find.text('Manual recovery'), findsNothing);
    expect(find.textContaining('portal.example.test/sub/trial'), findsNothing);
    expect(find.textContaining('format=smart'), findsNothing);
    expect(find.text('Fallback connection link'), findsNothing);
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
    supportThreads: [],
    downloads: [],
    importPayload: ImportPayload(
      subscriptionUrl: 'https://portal.example.test/sub/trial',
      smartUrl: 'https://portal.example.test/sub/trial?format=smart',
      plainUrl: 'https://portal.example.test/sub/trial?format=plain',
      qrValue: 'https://portal.example.test/sub/trial',
    ),
  );
}
