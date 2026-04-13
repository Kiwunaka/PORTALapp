import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/locations_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows auto-select and available locations', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portalExperienceProvider.overrideWith(
            (ref) async => _experience(),
          ),
        ],
        child: const MaterialApp(
          home: LocationsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Locations'), findsOneWidget);
    expect(find.text('Auto-select'), findsOneWidget);
    expect(find.text('Best server right now'), findsOneWidget);
    expect(find.text('Active route'), findsOneWidget);
    expect(find.text('Use'), findsNothing);
    expect(find.text('Netherlands'), findsWidgets);
    expect(find.text('Germany'), findsOneWidget);
  });

  testWidgets('shows an activation gate before a real subscription exists',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portalExperienceProvider.overrideWith(
            (ref) async => PortalExperience.demo(
              PortalPublicConfig.fromMap(const {}),
            ),
          ),
        ],
        child: const MaterialApp(
          home: LocationsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Locations unlock after start'), findsOneWidget);
    expect(find.text('Return to app'), findsOneWidget);
    expect(find.text('Netherlands'), findsNothing);
    expect(find.text('Poland'), findsNothing);
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
      activeSessions: 0,
      deviceLimit: 1,
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
    devices: [],
    locations: [
      LocationRecord(
        id: 'nl',
        title: 'Netherlands',
        subtitle: 'Amsterdam',
        regionLabel: 'Location',
        isActive: true,
      ),
      LocationRecord(
        id: 'de',
        title: 'Germany',
        subtitle: 'Frankfurt',
        regionLabel: 'Location',
        isActive: false,
      ),
    ],
    usage: UsageStats(
      usedGb: 1,
      totalGb: 15,
      remainingGb: 14,
      activeSessions: 0,
      deviceLimit: 1,
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
