import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/subscription_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows browser checkout entry as the primary purchase action', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portalExperienceProvider.overrideWith((ref) async => _experience()),
        ],
        child: const MaterialApp(home: SubscriptionPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Subscription'), findsOneWidget);
    expect(find.text('Open secure checkout'), findsOneWidget);
    expect(find.text('Continue in Telegram'), findsOneWidget);
    expect(find.text('Stay connected your way'), findsOneWidget);
    expect(find.text('Community +10 days'), findsOneWidget);
    expect(find.text('Redeem or add access key'), findsOneWidget);
    expect(find.text('Open channel'), findsOneWidget);
    expect(find.text('Open access flow'), findsOneWidget);
    expect(find.textContaining('NL-free'), findsOneWidget);
    expect(find.text('Choose 30 days'), findsOneWidget);
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
      payViaBotUrl: 'https://t.me/pokrov_vpnbot',
      plans: [
        PlanQuote(
          code: 'pro_30',
          label: '30 days',
          amountRub: 299,
          amountStars: 0,
          days: 30,
          deviceLimit: 5,
          nodePolicy: 'global',
          badge: 'Popular',
        ),
      ],
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
