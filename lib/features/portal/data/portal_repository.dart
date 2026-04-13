import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_api_client.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final portalPublicConfigProvider = Provider<PortalPublicConfig>(
  (ref) => PortalPublicConfig.environment(),
);

final portalApiClientProvider = Provider<PortalApiClient>(
  (ref) => HttpPortalApiClient(
    config: ref.watch(portalPublicConfigProvider),
    sessionStore: ref.watch(portalSessionStoreProvider),
  ),
);

final portalRepositoryProvider = Provider<PortalRepository>(
  (ref) => PortalRepositoryImpl(
    apiClient: ref.watch(portalApiClientProvider),
    config: ref.watch(portalPublicConfigProvider),
    sessionStore: ref.watch(portalSessionStoreProvider),
  ),
);

final portalExperienceProvider = FutureProvider.autoDispose<PortalExperience>(
  (ref) => ref.watch(portalRepositoryProvider).getExperience(),
);

abstract interface class PortalRepository {
  Future<PortalExperience> getExperience();

  Future<PortalExperience> startTrial(PortalStartTrialRequest request);

  Future<String> fetchManagedManifest(PortalManagedManifest manifest);

  Future<TelegramLinkSession> requestTelegramLink();

  Future<TelegramBonusClaimResult> claimTelegramBonus();
}

class PortalRepositoryImpl implements PortalRepository {
  PortalRepositoryImpl({
    required this.apiClient,
    required this.config,
    required this.sessionStore,
  });

  final PortalApiClient apiClient;
  final PortalPublicConfig config;
  final PortalSessionStore sessionStore;

  @override
  Future<PortalExperience> getExperience() async {
    if (config.isDemoMode && !sessionStore.hasSessionAuth) {
      return PortalExperience.demo(config);
    }

    try {
      final sessionJson = await apiClient.getJson('/api/auth/session');
      final sessionUser = _map(sessionJson['user']);
      final accountId = _asString(
        sessionUser['account_id'],
        fallback: _asString(sessionUser['id'], fallback: '0'),
      );
      final legacyId = _asInt(sessionUser['id']);

      final dashboardJson = await apiClient.getJson('/api/dashboard');
      final userJson = await apiClient.getJson('/api/user/$accountId');
      final publicPlansJson = await apiClient.getJson('/api/public/plans');
      final ticketsJson = await _safeGet('/api/tickets?limit=6');
      final appsJson = await _safeGet('/api/client/apps');
      final nodeStatusJson = await _safeGet('/api/nodes/status');

      return _buildExperience(
        sessionJson: {
          'user': {
            ...sessionUser,
            'account_id': accountId,
            'id': legacyId,
          },
        },
        dashboardJson: dashboardJson,
        userJson: userJson,
        publicPlansJson: publicPlansJson,
        ticketsJson: ticketsJson,
        appsJson: appsJson,
        nodeStatusJson: nodeStatusJson,
      );
    } catch (_) {
      return PortalExperience.demo(config);
    }
  }

  @override
  Future<PortalExperience> startTrial(PortalStartTrialRequest request) async {
    final payload = await apiClient.postJson(
      '/api/client/session/start-trial',
      request.toJson(),
    );
    final sessionToken = _asString(
      payload['session_token'],
      fallback: _asString(_map(payload['session'])['session_token']),
    );
    if (sessionToken.isNotEmpty) {
      await sessionStore.saveSessionToken(sessionToken);
    }

    final experiencePayload = _map(payload['experience']);
    if (experiencePayload.isNotEmpty) {
      return _buildExperience(
        sessionJson: _map(experiencePayload['session']),
        dashboardJson: _map(experiencePayload['dashboard']),
        userJson: _map(experiencePayload['user']),
        publicPlansJson: _map(experiencePayload['plans']),
        ticketsJson: _map(experiencePayload['tickets']),
        appsJson: _map(experiencePayload['apps']),
        nodeStatusJson: _map(experiencePayload['node_status']),
        provisioningJson: _map(experiencePayload['provisioning']),
      );
    }

    return getExperience();
  }

  @override
  Future<String> fetchManagedManifest(PortalManagedManifest manifest) async {
    final manifestUrl = manifest.url.trim();
    if (manifestUrl.isEmpty) return '';
    return apiClient.getText(manifestUrl);
  }

  @override
  Future<TelegramLinkSession> requestTelegramLink() async {
    final payload = await apiClient.postJson(
      '/api/client/telegram/link',
      const {},
    );
    return TelegramLinkSession(
      linked: _asBool(payload['linked']),
      linkedTelegramId: _asInt(payload['linked_telegram_id']),
      linkedTelegramUsername: _asString(payload['linked_telegram_username']),
      startCode: _asString(payload['start_code']),
      botUrl: _asString(payload['bot_url']),
      channelUrl: _asString(payload['channel_url']),
    );
  }

  @override
  Future<TelegramBonusClaimResult> claimTelegramBonus() async {
    final payload = await apiClient.postJson(
      '/api/bonuses/channel/claim',
      const {},
    );
    return TelegramBonusClaimResult(
      ok: _asBool(payload['ok'], fallback: true),
      alreadyClaimed: _asBool(payload['already_claimed']),
      premiumDays: _asInt(payload['premium_days']),
      linkedTelegramId: _asInt(payload['linked_telegram_id']),
      linkedTelegramUsername: _asString(payload['linked_telegram_username']),
    );
  }

  PortalExperience _buildExperience({
    required Map<String, dynamic> sessionJson,
    required Map<String, dynamic> dashboardJson,
    required Map<String, dynamic> userJson,
    required Map<String, dynamic> publicPlansJson,
    required Map<String, dynamic> ticketsJson,
    required Map<String, dynamic> appsJson,
    required Map<String, dynamic> nodeStatusJson,
    Map<String, dynamic> provisioningJson = const {},
  }) {
    final sessionUser = _sessionUser(sessionJson);
    final dashboard = _buildDashboardSummary(dashboardJson).copyWithNodeHealth(
      healthyNodes: _healthyNodes(nodeStatusJson),
      totalNodes: _totalNodes(nodeStatusJson),
    );
    final devices = _buildDevices(
      userJson,
      sessionDeviceName: _asString(
        sessionUser['device_name'],
        fallback:
            _asString(userJson['device_name'], fallback: 'Current device'),
      ),
    );
    final locations = _buildLocations(
      userPayload: userJson,
      nodeStatusPayload: nodeStatusJson,
    );
    final plans = _buildPlans(publicPlansJson);

    return PortalExperience(
      isDemo: false,
      session: SessionSummary(
        tgId: _asInt(sessionUser['id']),
        accountId: _asString(
          sessionUser['account_id'],
          fallback: _asString(sessionUser['id'], fallback: '0'),
        ),
        deviceName: _asString(
          sessionUser['device_name'],
          fallback:
              _asString(userJson['device_name'], fallback: 'Current device'),
        ),
        username: _asString(sessionUser['username'], fallback: 'user'),
        isAuthorized: _asBool(
          sessionUser['is_authorized'],
          fallback: true,
        ),
        linkedTelegramId: _asInt(sessionUser['linked_telegram_id']),
        linkedTelegramUsername: _asString(
          sessionUser['linked_telegram_username'],
        ),
      ),
      dashboard: dashboard,
      subscription: SubscriptionState(
        currentPlanCode: _asString(
          dashboardJson['current_plan_code'],
          fallback: _asString(dashboardJson['sub_type'], fallback: 'trial'),
        ),
        currentPlanLabel: dashboard.currentPlanLabel,
        isTrialLike: _isTrialLike(dashboardJson['sub_type']) ||
            _isTrialLike(dashboardJson['current_plan_code']),
        checkoutEnabled:
            _asBool(publicPlansJson['widget_enabled'], fallback: true),
        checkoutUrl: config.checkoutUrl,
        payViaBotUrl: _asString(
          _map(userJson['actions'])['pay_via_bot'],
          fallback: config.botUrl,
        ),
        plans: plans,
      ),
      checkout: plans.isEmpty
          ? null
          : CheckoutSession(
              planCode: plans.first.code,
              amountRub: plans.first.amountRub,
              paymentUrl: config.checkoutUrl,
              provider: 'portal',
              status: 'ready',
            ),
      devices: devices,
      locations: locations,
      usage: UsageStats(
        usedGb: dashboard.usedGb,
        totalGb: dashboard.totalGb,
        remainingGb: dashboard.remainingGb,
        activeSessions: dashboard.activeSessions,
        deviceLimit: dashboard.deviceLimit,
        healthyNodes: dashboard.healthyNodes,
        totalNodes: dashboard.totalNodes,
      ),
      supportThreads: _buildSupportThreads(ticketsJson),
      downloads: _buildDownloadTargets(appsJson),
      importPayload: _buildImportPayload(
        dashboard.connectionKey,
        provisioningJson: provisioningJson,
      ),
      connectionPolicy: _buildConnectionPolicy(
        sessionJson: sessionJson,
        dashboardJson: dashboardJson,
        userJson: userJson,
      ),
    );
  }

  Future<Map<String, dynamic>> _safeGet(String path) async {
    try {
      return await apiClient.getJson(path);
    } catch (_) {
      return const {};
    }
  }

  DashboardSummary _buildDashboardSummary(Map<String, dynamic> json) {
    final isActive = _asBool(json['is_active']);
    final subType = _asString(json['sub_type'], fallback: 'Trial');
    final planLabel = _asString(json['current_plan_code'], fallback: subType);
    return DashboardSummary(
      isActive: isActive,
      currentPlanLabel: planLabel,
      statusHeadline: isActive ? 'Connected and ready' : 'Action required',
      statusBody: isActive
          ? 'Manage subscription, locations, devices and support from one place.'
          : 'Import a profile or renew access to unlock the full service flow.',
      expiresAt: _asDateTime(json['expiry_at']),
      usedGb: _asDouble(json['used_gb']),
      totalGb: _asDouble(json['total_gb']),
      remainingGb: _asDouble(json['remaining_gb']),
      activeSessions: _asInt(json['active_sessions']),
      deviceLimit: _asInt(json['device_limit']),
      connectionKey: _asString(json['subscription_url']),
      healthyNodes: 0,
      totalNodes: 0,
    );
  }

  List<PlanQuote> _buildPlans(Map<String, dynamic> payload) {
    final rawPlans = _list(payload['plans']);
    final plans = rawPlans
        .where((row) => _asBool(_map(row)['is_active'], fallback: true))
        .map((row) {
      final data = _map(row);
      return PlanQuote(
        code: _asString(data['code']),
        label: _asString(data['label'], fallback: 'Plan'),
        amountRub: _asInt(data['amount_rub']),
        amountStars: _asInt(data['amount_stars']),
        days: _asInt(data['days']),
        deviceLimit: _asInt(data['device_limit'], fallback: 1),
        nodePolicy: _asString(data['node_policy'], fallback: 'pool'),
        badge: _asString(data['badge']),
      );
    }).toList();
    if (plans.isNotEmpty) return plans;
    return PortalExperience.demo(config).subscription.plans;
  }

  List<DeviceRecord> _buildDevices(
    Map<String, dynamic> payload, {
    required String sessionDeviceName,
  }) {
    final devices = _list(payload['devices']);
    if (devices.isNotEmpty) {
      return devices.map((row) {
        final data = _map(row);
        return DeviceRecord(
          id: _asString(data['id'], fallback: 'device'),
          title: _asString(data['name'], fallback: 'Current device'),
          subtitle: _asString(
            data['last_seen_at'],
            fallback:
                _asString(data['last_seen_label'], fallback: 'Recently active'),
          ),
          platform: _asString(data['platform'], fallback: 'Device'),
          isActive: _asBool(data['is_active'], fallback: true),
        );
      }).toList();
    }

    if (sessionDeviceName.isNotEmpty) {
      return [
        DeviceRecord(
          id: 'current-device',
          title: sessionDeviceName,
          subtitle: 'This device is ready for connection recovery and support.',
          platform: 'Device',
          isActive: true,
        ),
      ];
    }

    return PortalExperience.demo(config).devices;
  }

  List<LocationRecord> _buildLocations({
    required Map<String, dynamic> userPayload,
    required Map<String, dynamic> nodeStatusPayload,
  }) {
    final primaryNodes = _list(userPayload['nodes']);
    final fallbackNodes = _list(nodeStatusPayload['nodes']);
    final nodes = primaryNodes.isNotEmpty ? primaryNodes : fallbackNodes;
    if (nodes.isEmpty) return const [];
    return nodes.map((row) {
      final data = _map(row);
      return LocationRecord(
        id: _asString(data['code'], fallback: 'node'),
        title: _asString(
          data['name'],
          fallback: _asString(
            data['country'],
            fallback: _asString(data['code'], fallback: 'Access point'),
          ),
        ),
        subtitle:
            '${_asString(data['host'])}:${_asInt(data['port'], fallback: 443)}',
        regionLabel: 'Region',
        isActive: _asBool(data['enabled'], fallback: true),
      );
    }).toList();
  }

  List<SupportThread> _buildSupportThreads(Map<String, dynamic> payload) {
    final tickets = _list(payload['tickets']);
    if (tickets.isEmpty) return PortalExperience.demo(config).supportThreads;
    return tickets.map((row) {
      final data = _map(row);
      final messages = _list(data['messages']).map((message) {
        final raw = _map(message);
        return SupportMessage(
          id: _asInt(raw['id']),
          body: _asString(raw['body']),
          senderRole: _asString(raw['sender_role'], fallback: 'user'),
          createdAt: _asDateTime(raw['created_at']),
        );
      }).toList();
      return SupportThread(
        id: _asInt(data['id']),
        subject: _asString(data['subject'], fallback: 'Support thread'),
        status: _asString(data['status'], fallback: 'open'),
        messages: messages,
      );
    }).toList();
  }

  List<DownloadTarget> _buildDownloadTargets(Map<String, dynamic> payload) {
    final android = _map(payload['android']);
    final windows = _map(payload['windows']);
    final targets = <DownloadTarget>[
      DownloadTarget(
        platformLabel: 'Android',
        primaryUrl:
            _asString(android['apk_url'], fallback: config.androidApkUrl),
        mirrorUrl:
            _asString(android['mirror_url'], fallback: config.androidMirrorUrl),
        docsUrl: _asString(payload['docs_url'], fallback: config.docsUrl),
      ),
      DownloadTarget(
        platformLabel: 'Windows',
        primaryUrl:
            _asString(windows['exe_url'], fallback: config.windowsExeUrl),
        mirrorUrl:
            _asString(windows['mirror_url'], fallback: config.windowsMirrorUrl),
        docsUrl: _asString(payload['docs_url'], fallback: config.docsUrl),
      ),
    ]
        .where(
          (target) =>
              target.primaryUrl.isNotEmpty || target.mirrorUrl.isNotEmpty,
        )
        .toList();
    if (targets.isNotEmpty) return targets;
    return PortalExperience.demo(config).downloads;
  }

  ImportPayload _buildImportPayload(
    String subscriptionUrl, {
    Map<String, dynamic> provisioningJson = const {},
  }) {
    final managedManifest = _buildManagedManifest(
      _map(provisioningJson['managed_manifest']),
    );
    if (subscriptionUrl.isEmpty) {
      return ImportPayload(
        subscriptionUrl: '',
        smartUrl: '',
        plainUrl: '',
        qrValue: '',
        managedManifest: managedManifest,
      );
    }
    final smartUrl = subscriptionUrl.contains('?')
        ? '$subscriptionUrl&format=smart'
        : '$subscriptionUrl?format=smart';
    final plainUrl = subscriptionUrl.contains('?')
        ? '$subscriptionUrl&format=plain'
        : '$subscriptionUrl?format=plain';
    return ImportPayload(
      subscriptionUrl: subscriptionUrl,
      smartUrl: smartUrl,
      plainUrl: plainUrl,
      qrValue: subscriptionUrl,
      managedManifest: managedManifest,
    );
  }

  PortalManagedManifest _buildManagedManifest(Map<String, dynamic> payload) {
    return PortalManagedManifest(
      url: _asString(payload['url']),
      transportKind: _asString(payload['transport_kind']),
      engineHint: _asString(payload['engine_hint']),
      profileRevision: _asString(payload['profile_revision']),
    );
  }

  PortalConnectionPolicy _buildConnectionPolicy({
    required Map<String, dynamic> sessionJson,
    required Map<String, dynamic> dashboardJson,
    required Map<String, dynamic> userJson,
  }) {
    final sessionUser = _sessionUser(sessionJson);
    final policySources = <Map<String, dynamic>>[
      _map(userJson['client_policy']),
      _map(dashboardJson['client_policy']),
      _map(sessionUser['client_policy']),
      _map(sessionJson['client_policy']),
    ];
    final supportSources = [
      for (final source in policySources) _map(source['support_context']),
    ];

    return PortalConnectionPolicy(
      routingModeDefault: _firstPolicyString(
        policySources,
        'routing_mode_default',
      ),
      transportProfile: _firstPolicyString(policySources, 'transport_profile'),
      dnsPolicy: _firstPolicyString(policySources, 'dns_policy'),
      packageCatalogVersion: _firstPolicyString(
        policySources,
        'package_catalog_version',
      ),
      rulesetVersion: _firstPolicyString(policySources, 'ruleset_version'),
      supportRecoveryOrder: _firstPolicyStringList(
        policySources,
        'support_recovery_order',
      ),
      supportContext: PortalConnectionSupportContext(
        transport: _firstPolicyString(supportSources, 'transport'),
        routingMode: _firstPolicyString(supportSources, 'routing_mode'),
        ipVersionPreference: _firstPolicyString(
          supportSources,
          'ip_version_preference',
        ),
      ),
    );
  }

  int _healthyNodes(Map<String, dynamic> payload) {
    return _list(payload['nodes'])
        .where((row) => _asBool(_map(row)['is_healthy']))
        .length;
  }

  int _totalNodes(Map<String, dynamic> payload) =>
      _list(payload['nodes']).length;

  Map<String, dynamic> _sessionUser(Map<String, dynamic> payload) {
    final nestedUser = _map(payload['user']);
    if (nestedUser.isNotEmpty) return nestedUser;
    return payload;
  }
}

extension on DashboardSummary {
  DashboardSummary copyWithNodeHealth({
    required int healthyNodes,
    required int totalNodes,
  }) {
    return DashboardSummary(
      isActive: isActive,
      currentPlanLabel: currentPlanLabel,
      statusHeadline: statusHeadline,
      statusBody: statusBody,
      expiresAt: expiresAt,
      usedGb: usedGb,
      totalGb: totalGb,
      remainingGb: remainingGb,
      activeSessions: activeSessions,
      deviceLimit: deviceLimit,
      connectionKey: connectionKey,
      healthyNodes: healthyNodes,
      totalNodes: totalNodes,
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, raw) => MapEntry(key.toString(), raw));
  }
  return const {};
}

List<dynamic> _list(Object? value) {
  if (value is List) return value;
  return const [];
}

String _asString(Object? value, {String fallback = ''}) {
  final text = value == null ? fallback : value.toString().trim();
  return text.isEmpty ? fallback : text;
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(_asString(value)) ?? fallback;
}

double _asDouble(Object? value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(_asString(value)) ?? fallback;
}

bool _asBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  final normalized = _asString(value).toLowerCase();
  if (normalized == 'true') return true;
  if (normalized == 'false') return false;
  return fallback;
}

DateTime? _asDateTime(Object? value) {
  final text = _asString(value);
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

bool _isTrialLike(Object? value) {
  final normalized = _asString(value).toUpperCase();
  return normalized.contains('TRIAL') ||
      normalized.contains('FREE') ||
      normalized.contains('BONUS');
}

String _firstPolicyString(Iterable<Map<String, dynamic>> sources, String key) {
  for (final source in sources) {
    final value = _asString(source[key]);
    if (value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

List<String> _firstPolicyStringList(
  Iterable<Map<String, dynamic>> sources,
  String key,
) {
  for (final source in sources) {
    final values = _asStringList(source[key]);
    if (values.isNotEmpty) {
      return values;
    }
  }
  return const [];
}

List<String> _asStringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => _asString(item))
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
