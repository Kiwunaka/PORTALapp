import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/config/portal_client_strategy.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';

void main() {
  test('defaults to four-platform target with key bridge and free-tier facts',
      () {
    const strategy = PortalClientStrategy();

    expect(
      strategy.publicTargetPlatforms,
      equals(<String>['Android', 'iOS', 'macOS', 'Windows']),
    );
    expect(
      strategy.automaticActivationPlatforms,
      equals(<String>['Android', 'Windows']),
    );
    expect(
      strategy.keyDeliveryPlatforms,
      equals(<String>['Android', 'iOS', 'macOS', 'Windows']),
    );
    expect(strategy.publicTargetBadgeLabel, equals('4-platform target'));
    expect(
      strategy.keyDeliveryPlatformLine,
      equals('Android / iOS / macOS / Windows'),
    );
    expect(strategy.freeTier.trafficGb, equals(5));
    expect(strategy.freeTier.periodDays, equals(30));
    expect(strategy.freeTier.deviceLimit, equals(1));
    expect(strategy.freeTier.nodePool, equals('NL-free'));
  });

  test('builds a consumer transport variant from managed and profile signals',
      () {
    const portal = PortalExperience(
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
        statusHeadline: 'Ready',
        statusBody: 'Ready',
        expiresAt: null,
        usedGb: 0,
        totalGb: 15,
        remainingGb: 15,
        activeSessions: 0,
        deviceLimit: 1,
        connectionKey: '',
        healthyNodes: 1,
        totalNodes: 1,
      ),
      subscription: SubscriptionState(
        currentPlanCode: 'trial',
        currentPlanLabel: 'Trial',
        isTrialLike: true,
        checkoutEnabled: true,
        checkoutUrl: '',
        payViaBotUrl: '',
        plans: [],
      ),
      checkout: null,
      usage: UsageStats(
        usedGb: 0,
        totalGb: 15,
        remainingGb: 15,
        activeSessions: 0,
        deviceLimit: 1,
        healthyNodes: 1,
        totalNodes: 1,
      ),
      supportThreads: [],
      downloads: [],
      importPayload: ImportPayload(
        subscriptionUrl: '',
        smartUrl: '',
        plainUrl: '',
        qrValue: '',
        managedManifest: PortalManagedManifest(
          transportKind: 'managed-http',
        ),
      ),
      connectionPolicy: PortalConnectionPolicy(
        transportProfile: 'grpc_443_primary',
        supportContext: PortalConnectionSupportContext(
          transport: 'grpc_443_primary',
        ),
      ),
    );

    final variant = resolvePortalTransportVariant(portal);

    expect(variant, isNotNull);
    expect(variant!.label, equals('Managed HTTP'));
    expect(variant.detail, equals('gRPC 443'));
    expect(variant.badgeLabel, equals('Managed HTTP · gRPC 443'));
  });
}
