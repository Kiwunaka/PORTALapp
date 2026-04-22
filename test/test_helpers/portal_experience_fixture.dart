import 'package:hiddify/features/portal/model/portal_models.dart';

PortalExperience buildPortalExperienceFixture({
  bool isTrialLike = true,
  String primaryLocation = 'Netherlands',
  String primaryLocationSubtitle = 'Amsterdam',
}) {
  return PortalExperience(
    isDemo: false,
    session: const SessionSummary(
      tgId: 0,
      accountId: 'acc_1',
      deviceName: 'Android device',
      username: 'guest-acc_1',
      isAuthorized: true,
    ),
    dashboard: DashboardSummary(
      isActive: true,
      currentPlanLabel: isTrialLike ? 'Trial' : 'Premium',
      statusHeadline: isTrialLike ? 'Ready to connect' : 'Protected',
      statusBody: isTrialLike
          ? 'Your trial is active and ready on this device.'
          : 'Your subscription is active and synced across devices.',
      expiresAt: DateTime(2026, 5, 14),
      usedGb: 1,
      totalGb: 15,
      remainingGb: 14,
      activeSessions: 1,
      deviceLimit: 5,
      connectionKey: 'https://portal.example.test/sub/trial',
      healthyNodes: 5,
      totalNodes: 6,
    ),
    subscription: SubscriptionState(
      currentPlanCode: isTrialLike ? 'trial_5_days' : 'premium_30',
      currentPlanLabel: isTrialLike ? 'Trial' : 'Premium',
      isTrialLike: isTrialLike,
      checkoutEnabled: true,
      checkoutUrl: 'https://portal.example.test/checkout',
      payViaBotUrl: 'https://t.me/portal_service_bot',
      plans: const [],
    ),
    checkout: null,
    devices: [
      const DeviceRecord(
        id: 'device_1',
        title: 'Android device',
        subtitle: 'Last active just now',
        platform: 'Android',
        isActive: true,
      ),
      const DeviceRecord(
        id: 'device_2',
        title: 'MacBook Pro',
        subtitle: 'Last active 10 minutes ago',
        platform: 'macOS',
        isActive: false,
      ),
    ],
    locations: [
      LocationRecord(
        id: 'nl',
        title: primaryLocation,
        subtitle: primaryLocationSubtitle,
        regionLabel: 'Location',
        isActive: true,
      ),
      const LocationRecord(
        id: 'de',
        title: 'Germany',
        subtitle: 'Frankfurt',
        regionLabel: 'Location',
        isActive: false,
      ),
    ],
    usage: const UsageStats(
      usedGb: 1,
      totalGb: 15,
      remainingGb: 14,
      activeSessions: 1,
      deviceLimit: 5,
      healthyNodes: 5,
      totalNodes: 6,
    ),
    supportThreads: const [
      SupportThread(
        id: 1,
        subject: 'Welcome to POKROV',
        status: 'open',
        messages: [
          SupportMessage(
            id: 1,
            body: 'Support replies will appear here with your device context.',
            senderRole: 'system',
            createdAt: null,
          ),
        ],
      ),
    ],
    downloads: const [
      DownloadTarget(
        platformLabel: 'Android',
        primaryUrl: 'https://downloads.example.test/android.apk',
        mirrorUrl: 'https://mirror.example.test/android.apk',
        docsUrl: 'https://docs.example.test/android',
      ),
      DownloadTarget(
        platformLabel: 'Windows',
        primaryUrl: 'https://downloads.example.test/windows.exe',
        mirrorUrl: 'https://mirror.example.test/windows.exe',
        docsUrl: 'https://docs.example.test/windows',
      ),
    ],
    importPayload: const ImportPayload(
      subscriptionUrl: 'https://portal.example.test/sub/trial',
      smartUrl: 'https://portal.example.test/sub/trial?format=smart',
      plainUrl: 'https://portal.example.test/sub/trial?format=plain',
      qrValue: 'https://portal.example.test/sub/trial',
      managedManifest: PortalManagedManifest(
        transportKind: 'managed-http',
      ),
    ),
    connectionPolicy: const PortalConnectionPolicy(
      transportProfile: 'grpc_443_primary',
      supportContext: PortalConnectionSupportContext(
        transport: 'grpc_443_primary',
      ),
    ),
  );
}
