import 'package:hiddify/features/portal/config/portal_public_config.dart';

class SessionSummary {
  const SessionSummary({
    required this.tgId,
    required this.accountId,
    required this.deviceName,
    required this.username,
    required this.isAuthorized,
    this.linkedTelegramId = 0,
    this.linkedTelegramUsername = '',
  });

  final int tgId;
  final String accountId;
  final String deviceName;
  final String username;
  final bool isAuthorized;
  final int linkedTelegramId;
  final String linkedTelegramUsername;
}

class TelegramLinkSession {
  const TelegramLinkSession({
    required this.linked,
    required this.linkedTelegramId,
    required this.linkedTelegramUsername,
    required this.startCode,
    required this.botUrl,
    required this.channelUrl,
  });

  final bool linked;
  final int linkedTelegramId;
  final String linkedTelegramUsername;
  final String startCode;
  final String botUrl;
  final String channelUrl;
}

class TelegramBonusClaimResult {
  const TelegramBonusClaimResult({
    required this.ok,
    required this.alreadyClaimed,
    required this.premiumDays,
    required this.linkedTelegramId,
    required this.linkedTelegramUsername,
  });

  final bool ok;
  final bool alreadyClaimed;
  final int premiumDays;
  final int linkedTelegramId;
  final String linkedTelegramUsername;
}

class PortalStartTrialRequest {
  const PortalStartTrialRequest({
    required this.installId,
    required this.deviceName,
    required this.platform,
    required this.operatingSystemVersion,
    required this.appVersion,
    required this.localeTag,
    required this.timeZone,
  });

  final String installId;
  final String deviceName;
  final String platform;
  final String operatingSystemVersion;
  final String appVersion;
  final String localeTag;
  final String timeZone;

  Map<String, dynamic> toJson() {
    return {
      'install_id': installId,
      'device_name': deviceName,
      'platform': platform,
      'os_version': operatingSystemVersion,
      'app_version': appVersion,
      'locale': localeTag,
      'time_zone': timeZone,
    };
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.isActive,
    required this.currentPlanLabel,
    required this.statusHeadline,
    required this.statusBody,
    required this.expiresAt,
    required this.usedGb,
    required this.totalGb,
    required this.remainingGb,
    required this.activeSessions,
    required this.deviceLimit,
    required this.connectionKey,
    required this.healthyNodes,
    required this.totalNodes,
  });

  final bool isActive;
  final String currentPlanLabel;
  final String statusHeadline;
  final String statusBody;
  final DateTime? expiresAt;
  final double usedGb;
  final double totalGb;
  final double remainingGb;
  final int activeSessions;
  final int deviceLimit;
  final String connectionKey;
  final int healthyNodes;
  final int totalNodes;

  String get connectionPointsLabel {
    if (totalNodes <= 0) return '--';
    return '$healthyNodes/$totalNodes';
  }
}

class PlanQuote {
  const PlanQuote({
    required this.code,
    required this.label,
    required this.amountRub,
    required this.amountStars,
    required this.days,
    required this.deviceLimit,
    required this.nodePolicy,
    required this.badge,
  });

  final String code;
  final String label;
  final int amountRub;
  final int amountStars;
  final int days;
  final int deviceLimit;
  final String nodePolicy;
  final String badge;
}

class SubscriptionState {
  const SubscriptionState({
    required this.currentPlanCode,
    required this.currentPlanLabel,
    required this.isTrialLike,
    required this.checkoutEnabled,
    required this.checkoutUrl,
    required this.payViaBotUrl,
    required this.plans,
  });

  final String currentPlanCode;
  final String currentPlanLabel;
  final bool isTrialLike;
  final bool checkoutEnabled;
  final String checkoutUrl;
  final String payViaBotUrl;
  final List<PlanQuote> plans;
}

class CheckoutSession {
  const CheckoutSession({
    required this.planCode,
    required this.amountRub,
    required this.paymentUrl,
    required this.provider,
    required this.status,
  });

  final String planCode;
  final int amountRub;
  final String paymentUrl;
  final String provider;
  final String status;
}

class DeviceRecord {
  const DeviceRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.platform,
    required this.isActive,
  });

  final String id;
  final String title;
  final String subtitle;
  final String platform;
  final bool isActive;
}

class LocationRecord {
  const LocationRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.regionLabel,
    required this.isActive,
  });

  final String id;
  final String title;
  final String subtitle;
  final String regionLabel;
  final bool isActive;
}

class UsageStats {
  const UsageStats({
    required this.usedGb,
    required this.totalGb,
    required this.remainingGb,
    required this.activeSessions,
    required this.deviceLimit,
    required this.healthyNodes,
    required this.totalNodes,
  });

  final double usedGb;
  final double totalGb;
  final double remainingGb;
  final int activeSessions;
  final int deviceLimit;
  final int healthyNodes;
  final int totalNodes;
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.body,
    required this.senderRole,
    required this.createdAt,
  });

  final int id;
  final String body;
  final String senderRole;
  final DateTime? createdAt;
}

class SupportThread {
  const SupportThread({
    required this.id,
    required this.subject,
    required this.status,
    required this.messages,
  });

  final int id;
  final String subject;
  final String status;
  final List<SupportMessage> messages;
}

class DownloadTarget {
  const DownloadTarget({
    required this.platformLabel,
    required this.primaryUrl,
    required this.mirrorUrl,
    required this.docsUrl,
  });

  final String platformLabel;
  final String primaryUrl;
  final String mirrorUrl;
  final String docsUrl;
}

class PortalManagedManifest {
  const PortalManagedManifest({
    this.url = '',
    this.transportKind = '',
    this.engineHint = '',
    this.profileRevision = '',
  });

  final String url;
  final String transportKind;
  final String engineHint;
  final String profileRevision;

  bool get isConfigured => url.trim().isNotEmpty;
}

class PortalSupportDiagnostics {
  const PortalSupportDiagnostics({
    this.accountId = '',
    this.deviceName = '',
    this.planCode = '',
    this.appVersion = '',
    this.platform = '',
    this.operatingSystemVersion = '',
    this.linkedTelegramId = 0,
    this.linkedTelegramUsername = '',
    this.routingMode = '',
    this.dnsPolicy = '',
    this.transportProfile = '',
    this.transportKind = '',
    this.engineHint = '',
    this.profileRevision = '',
    this.packageCatalogVersion = '',
    this.rulesetVersion = '',
    this.supportRecoveryOrder = const [],
    this.webappUrl = '',
  });

  final String accountId;
  final String deviceName;
  final String planCode;
  final String appVersion;
  final String platform;
  final String operatingSystemVersion;
  final int linkedTelegramId;
  final String linkedTelegramUsername;
  final String routingMode;
  final String dnsPolicy;
  final String transportProfile;
  final String transportKind;
  final String engineHint;
  final String profileRevision;
  final String packageCatalogVersion;
  final String rulesetVersion;
  final List<String> supportRecoveryOrder;
  final String webappUrl;

  String linkedTelegramLabel(bool isRussian) {
    final username = linkedTelegramUsername.trim();
    if (username.isNotEmpty && linkedTelegramId > 0) {
      return '@$username ($linkedTelegramId)';
    }
    if (username.isNotEmpty) {
      return '@$username';
    }
    if (linkedTelegramId > 0) {
      return 'ID $linkedTelegramId';
    }
    return isRussian ? 'не привязан' : 'not linked';
  }

  String get recoveryOrderLabel {
    final normalized = supportRecoveryOrder
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (normalized.isEmpty) {
      return 'app -> web -> telegram';
    }
    return normalized.join(' -> ');
  }
}

class ImportPayload {
  const ImportPayload({
    required this.subscriptionUrl,
    required this.smartUrl,
    required this.plainUrl,
    required this.qrValue,
    this.managedManifest = const PortalManagedManifest(),
  });

  final String subscriptionUrl;
  final String smartUrl;
  final String plainUrl;
  final String qrValue;
  final PortalManagedManifest managedManifest;
}

class PortalConnectionSupportContext {
  const PortalConnectionSupportContext({
    this.transport = '',
    this.routingMode = '',
    this.ipVersionPreference = '',
  });

  final String transport;
  final String routingMode;
  final String ipVersionPreference;
}

class PortalConnectionPolicy {
  const PortalConnectionPolicy({
    this.routingModeDefault = '',
    this.transportProfile = '',
    this.dnsPolicy = '',
    this.packageCatalogVersion = '',
    this.rulesetVersion = '',
    this.supportRecoveryOrder = const [],
    this.supportContext = const PortalConnectionSupportContext(),
  });

  final String routingModeDefault;
  final String transportProfile;
  final String dnsPolicy;
  final String packageCatalogVersion;
  final String rulesetVersion;
  final List<String> supportRecoveryOrder;
  final PortalConnectionSupportContext supportContext;
}

class PortalExperience {
  const PortalExperience({
    required this.isDemo,
    required this.session,
    required this.dashboard,
    required this.subscription,
    required this.checkout,
    this.devices = const [],
    this.locations = const [],
    required this.usage,
    required this.supportThreads,
    required this.downloads,
    required this.importPayload,
    this.connectionPolicy = const PortalConnectionPolicy(),
  });

  final bool isDemo;
  final SessionSummary session;
  final DashboardSummary dashboard;
  final SubscriptionState subscription;
  final CheckoutSession? checkout;
  final List<DeviceRecord> devices;
  final List<LocationRecord> locations;
  final UsageStats usage;
  final List<SupportThread> supportThreads;
  final List<DownloadTarget> downloads;
  final ImportPayload importPayload;
  final PortalConnectionPolicy connectionPolicy;

  bool get hasProvisionedAccess =>
      session.isAuthorized || importPayload.subscriptionUrl.trim().isNotEmpty;

  factory PortalExperience.demo(PortalPublicConfig config) {
    const demoPlan = PlanQuote(
      code: '1_month',
      label: '1 Month',
      amountRub: 249,
      amountStars: 249,
      days: 30,
      deviceLimit: 5,
      nodePolicy: 'paid_pool',
      badge: 'Popular',
    );

    return PortalExperience(
      isDemo: true,
      session: const SessionSummary(
        tgId: 0,
        accountId: 'guest',
        deviceName: 'Current device',
        username: 'guest',
        isAuthorized: false,
        linkedTelegramId: 0,
        linkedTelegramUsername: '',
      ),
      dashboard: const DashboardSummary(
        isActive: false,
        currentPlanLabel: 'Trial',
        statusHeadline: 'Your service hub is ready',
        statusBody:
            'Connect a profile, then unlock subscription, locations, devices, support and downloads without leaving the app.',
        expiresAt: null,
        usedGb: 0,
        totalGb: 30,
        remainingGb: 30,
        activeSessions: 0,
        deviceLimit: 1,
        connectionKey: '',
        healthyNodes: 0,
        totalNodes: 0,
      ),
      subscription: SubscriptionState(
        currentPlanCode: 'trial',
        currentPlanLabel: 'Trial',
        isTrialLike: true,
        checkoutEnabled: true,
        checkoutUrl: config.checkoutUrl,
        payViaBotUrl: config.botUrl,
        plans: const [
          demoPlan,
          PlanQuote(
            code: '12_months',
            label: '12 Months',
            amountRub: 1644,
            amountStars: 1644,
            days: 365,
            deviceLimit: 5,
            nodePolicy: 'paid_pool',
            badge: '-45%',
          ),
        ],
      ),
      checkout: CheckoutSession(
        planCode: demoPlan.code,
        amountRub: demoPlan.amountRub,
        paymentUrl: config.checkoutUrl,
        provider: 'portal',
        status: 'demo',
      ),
      devices: const [
        DeviceRecord(
          id: 'device-demo',
          title: 'Current device',
          subtitle: 'Available after activation',
          platform: 'Device',
          isActive: true,
        ),
      ],
      locations: const [],
      usage: const UsageStats(
        usedGb: 0,
        totalGb: 30,
        remainingGb: 30,
        activeSessions: 0,
        deviceLimit: 1,
        healthyNodes: 0,
        totalNodes: 0,
      ),
      supportThreads: const [
        SupportThread(
          id: 1,
          subject: 'Welcome to POKROV VPN',
          status: 'demo',
          messages: [
            SupportMessage(
              id: 1,
              body:
                  'Support and account data will appear here after trial activation.',
              senderRole: 'system',
              createdAt: null,
            ),
          ],
        ),
      ],
      downloads: [
        DownloadTarget(
          platformLabel: 'Android',
          primaryUrl: config.androidApkUrl,
          mirrorUrl: config.androidMirrorUrl,
          docsUrl: config.docsUrl,
        ),
        DownloadTarget(
          platformLabel: 'Windows',
          primaryUrl: config.windowsExeUrl,
          mirrorUrl: config.windowsMirrorUrl,
          docsUrl: config.docsUrl,
        ),
      ],
      importPayload: const ImportPayload(
        subscriptionUrl: '',
        smartUrl: '',
        plainUrl: '',
        qrValue: '',
      ),
    );
  }
}
