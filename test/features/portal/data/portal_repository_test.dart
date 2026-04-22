import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_api_client.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';

class _FakePortalApiClient implements PortalApiClient {
  _FakePortalApiClient(
    this.responses, {
    this.textResponses = const {},
    this.onPost,
  });

  final Map<String, Map<String, dynamic>> responses;
  final Map<String, String> textResponses;
  final Future<Map<String, dynamic>> Function(
    String path,
    Map<String, dynamic> body,
  )? onPost;

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    final response = responses[path];
    if (response == null) {
      throw StateError('No fake response registered for $path');
    }
    return response;
  }

  @override
  Future<String> getText(String path) async {
    final response = textResponses[path];
    if (response == null) {
      throw StateError('No fake text response registered for $path');
    }
    return response;
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (onPost != null) {
      return onPost!(path, body);
    }
    return getJson(path);
  }
}

class _ThrowingPortalApiClient implements PortalApiClient {
  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    throw StateError('network unavailable');
  }

  @override
  Future<String> getText(String path) async {
    throw StateError('network unavailable');
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    throw StateError('network unavailable');
  }
}

class _MemoryPortalSessionStore implements PortalSessionStore {
  _MemoryPortalSessionStore({
    this.sessionToken = '',
  });

  final String installId = 'test-install-id';
  String sessionToken;

  @override
  Future<void> clearSession() async {
    sessionToken = '';
  }

  @override
  Future<String> ensureInstallId() async => installId;

  @override
  bool get hasSessionAuth => sessionToken.isNotEmpty;

  @override
  String readInstallIdSync() => installId;

  @override
  String readSessionTokenSync() => sessionToken;

  @override
  Future<void> saveSessionToken(String value) async {
    sessionToken = value;
  }
}

void main() {
  group('PortalRepositoryImpl.getExperience', () {
    test('builds a service-first overview from portal payloads', () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient({
          '/api/auth/session': {
            'ok': true,
            'user': {
              'id': 1001,
              'username': 'alice',
              'client_policy': {
                'routing_mode_default': 'all_except_ru',
                'support_context': {
                  'routing_mode': 'all_except_ru',
                },
                'support_recovery_order': ['app', 'web', 'telegram'],
              },
            },
          },
          '/api/dashboard': {
            'tg_id': 1001,
            'sub_type': 'PAID',
            'current_plan_code': '1_month',
            'is_active': true,
            'expiry_at': '2026-04-01T00:00:00Z',
            'used_gb': 18,
            'total_gb': 100,
            'remaining_gb': 82,
            'active_sessions': 2,
            'device_limit': 5,
            'subscription_url': 'https://portal.example.test/sub/abc',
            'client_policy': {
              'dns_policy': 'ru_direct_split',
              'package_catalog_version': '2026.04.13.1',
              'ruleset_version': '2026.04.13.rules',
              'support_context': {
                'ip_version_preference': 'ipv4_only',
              },
            },
            'features': {'haptic': true, 'lottie': false},
          },
          '/api/user/1001': {
            'tg_id': 1001,
            'username': 'alice',
            'subscription_url': 'https://portal.example.test/sub/abc',
            'is_active': true,
            'is_admin': false,
            'sub_type': 'PAID',
            'client_policy': {
              'transport_profile': 'grpc_443_primary',
              'support_context': {
                'transport': 'grpc_443_primary',
              },
            },
            'expiry_at': '2026-04-01T00:00:00Z',
            'devices': [
              {
                'id': 'device_1',
                'name': 'Android device',
                'platform': 'Android',
                'is_active': true,
                'last_seen_at': '2026-03-19T08:00:00Z',
              }
            ],
            'nodes': [
              {
                'code': 'nl',
                'name': 'Netherlands',
                'host': 'nl.example.test',
                'port': 443,
                'enabled': true,
              },
              {
                'code': 'pl',
                'name': 'Poland',
                'host': 'pl.example.test',
                'port': 443,
                'enabled': false,
              }
            ],
            'limits': {'device_limit': 5, 'total_gb': 100},
            'traffic': {'used_gb': 18, 'total_gb': 100, 'remaining_gb': 82},
            'support': {
              'username': 'portal_helpdesk',
              'link': 'https://t.me/portal_helpdesk',
              'new_ticket_link': 'https://t.me/portal_helpdesk?start=ticket',
            },
            'actions': {
              'open_helpbot': 'https://t.me/portal_helpdesk',
              'open_channel': 'https://t.me/portal_privacy',
              'pay_via_bot': 'https://t.me/portal_service_bot?start=pay',
            },
            'features': {'haptic': true, 'lottie': false},
          },
          '/api/public/plans': {
            'widget_enabled': true,
            'plans': [
              {
                'code': '1_month',
                'label': '1 Month',
                'amount_rub': 249,
                'amount_stars': 249,
                'days': 30,
                'device_limit': 5,
                'node_policy': 'paid_pool',
                'badge': 'Popular',
                'is_active': true,
                'sort_order': 1,
              }
            ],
          },
          '/api/tickets?limit=6': {
            'tickets': [
              {
                'id': 91,
                'user_tg_id': 1001,
                'status': 'open',
                'status_title': 'Open',
                'subject': 'Need help',
                'messages': [
                  {
                    'id': 900,
                    'ticket_id': 91,
                    'sender_tg_id': 1001,
                    'sender_role': 'user',
                    'body': 'Hello',
                    'created_at': '2026-03-18T10:00:00Z',
                  }
                ],
              }
            ],
          },
          '/api/client/apps': {
            'android': {
              'play_url':
                  'https://play.google.com/store/apps/details?id=portal',
              'apk_url': 'https://cdn.example.test/portal.apk',
              'mirror_url': 'https://mirror.example.test/portal.apk',
            },
            'windows': {
              'exe_url': 'https://cdn.example.test/portal.exe',
              'mirror_url': 'https://mirror.example.test/portal.exe',
            },
            'docs_url': 'https://docs.example.test/install',
            'updated_at': '2026-03-18T00:00:00Z',
          },
          '/api/nodes/status': {
            'nodes': [
              {
                'code': 'nl',
                'country': 'Netherlands',
                'host': 'nl.example.test',
                'port_open': true,
                'dns_sni_status': 'ok',
                'is_healthy': true,
              },
              {
                'code': 'pl',
                'country': 'Poland',
                'host': 'pl.example.test',
                'port_open': false,
                'dns_sni_status': 'degraded',
                'is_healthy': false,
              }
            ],
          },
        }),
        config: PortalPublicConfig.fromMap(const {
          'PORTAL_WEB_SESSION_TOKEN': 'test-token',
        }),
        sessionStore: _MemoryPortalSessionStore(),
      );

      final experience = await repository.getExperience();

      expect(experience.isDemo, isFalse);
      expect(experience.session.username, equals('alice'));
      expect(experience.dashboard.connectionPointsLabel, equals('1/2'));
      expect(experience.subscription.plans, hasLength(1));
      expect(experience.devices, hasLength(1));
      expect(experience.devices.single.platform, equals('Android'));
      expect(experience.locations, hasLength(2));
      expect(experience.locations.map((item) => item.title),
          containsAll(<String>['Netherlands', 'Poland']),);
      expect(experience.locations.first.subtitle, equals('Optimized route'));
      expect(experience.locations.last.subtitle, equals('Standby route'));
      expect(
        experience.locations.every(
          (item) => !item.subtitle.contains('.example.test'),
        ),
        isTrue,
      );
      expect(
        experience.locations.every((item) => !item.subtitle.contains(':443')),
        isTrue,
      );
      expect(experience.locations.every((item) => item.regionLabel == 'Region'),
          isTrue,);
      expect(experience.supportThreads.single.messages, hasLength(1));
      expect(experience.downloads.map((item) => item.platformLabel),
          containsAll(<String>['Android', 'Windows']),);
      expect(experience.importPayload.smartUrl, contains('format=smart'));
      expect(
          experience.subscription.payViaBotUrl, contains('portal_service_bot'),);
      expect(experience.connectionPolicy.routingModeDefault, 'all_except_ru');
      expect(experience.connectionPolicy.transportProfile, 'grpc_443_primary');
      expect(experience.connectionPolicy.dnsPolicy, 'ru_direct_split');
      expect(
        experience.connectionPolicy.packageCatalogVersion,
        '2026.04.13.1',
      );
      expect(
        experience.connectionPolicy.rulesetVersion,
        '2026.04.13.rules',
      );
      expect(
        experience.connectionPolicy.supportContext.transport,
        'grpc_443_primary',
      );
      expect(
        experience.connectionPolicy.supportContext.routingMode,
        'all_except_ru',
      );
      expect(
        experience.connectionPolicy.supportContext.ipVersionPreference,
        'ipv4_only',
      );
      expect(
        experience.connectionPolicy.supportRecoveryOrder,
        equals(<String>['app', 'web', 'telegram']),
      );
    });

    test('ignores malformed client policy payloads without breaking the portal',
        () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient({
          '/api/auth/session': {
            'ok': true,
            'user': {
              'id': 1002,
              'username': 'bob',
              'client_policy': 'unexpected',
            },
          },
          '/api/dashboard': {
            'tg_id': 1002,
            'sub_type': 'PAID',
            'current_plan_code': '1_month',
            'is_active': true,
            'subscription_url': 'https://portal.example.test/sub/bob',
            'client_policy': const ['unexpected'],
          },
          '/api/user/1002': {
            'tg_id': 1002,
            'username': 'bob',
            'client_policy': {
              'support_context': const ['unexpected'],
            },
          },
          '/api/public/plans': const {
            'plans': [],
          },
          '/api/tickets?limit=6': const {},
          '/api/client/apps': const {},
          '/api/nodes/status': const {},
        }),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore:
            _MemoryPortalSessionStore(sessionToken: 'runtime-session-123'),
      );

      final experience = await repository.getExperience();

      expect(experience.isDemo, isFalse);
      expect(experience.connectionPolicy.routingModeDefault, isEmpty);
      expect(experience.connectionPolicy.transportProfile, isEmpty);
      expect(experience.connectionPolicy.dnsPolicy, isEmpty);
      expect(experience.connectionPolicy.packageCatalogVersion, isEmpty);
      expect(experience.connectionPolicy.rulesetVersion, isEmpty);
      expect(experience.connectionPolicy.supportContext.transport, isEmpty);
      expect(experience.connectionPolicy.supportContext.routingMode, isEmpty);
      expect(
        experience.connectionPolicy.supportContext.ipVersionPreference,
        isEmpty,
      );
      expect(experience.connectionPolicy.supportRecoveryOrder, isEmpty);
      expect(experience.subscription.plans, isNotEmpty);
    });

    test('parses ordered location variants and keeps disabled xhttp gated',
        () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient({
          '/api/auth/session': {
            'ok': true,
            'user': {
              'id': 1003,
              'username': 'matrix_user',
            },
          },
          '/api/dashboard': {
            'tg_id': 1003,
            'sub_type': 'PAID',
            'current_plan_code': '1_month',
            'is_active': true,
            'subscription_url': 'https://portal.example.test/sub/matrix',
          },
          '/api/user/1003': {
            'tg_id': 1003,
            'username': 'matrix_user',
            'subscription_url': 'https://portal.example.test/sub/matrix',
            'is_active': true,
            'nodes': [
              {
                'code': 'nl',
                'name': 'Netherlands',
                'enabled': true,
                'location_variants': [
                  {'transport': 'trojan', 'enabled': true},
                  {'transport': 'xhttp', 'enabled': false},
                  {'transport': 'vmess', 'enabled': true},
                  {'transport': 'vless_reality', 'enabled': true},
                ],
              },
            ],
          },
          '/api/public/plans': const {
            'plans': [],
          },
          '/api/tickets?limit=6': const {},
          '/api/client/apps': const {},
          '/api/nodes/status': const {},
        }),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore:
            _MemoryPortalSessionStore(sessionToken: 'runtime-session-123'),
      );

      final experience = await repository.getExperience();
      final location = experience.locations.single;
      final variants = location.variants;

      expect(
        variants.map((variant) => variant.label),
        equals(<String>[
          'VLESS+REALITY',
          'VMess',
          'Trojan',
          'XHTTP',
        ]),
      );
      expect(variants.last.isEnabled, isFalse);
      expect(
        (variants.last as dynamic).isComingSoon,
        isTrue,
      );
    });

    test('falls back to demo experience when portal is unavailable', () async {
      final repository = PortalRepositoryImpl(
        apiClient: _ThrowingPortalApiClient(),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore: _MemoryPortalSessionStore(),
      );

      final experience = await repository.getExperience();

      expect(experience.isDemo, isTrue);
      expect(experience.session.isAuthorized, isFalse);
      expect(experience.subscription.plans, isNotEmpty);
      expect(experience.locations, isEmpty);
      expect(experience.downloads, isNotEmpty);
      expect(experience.supportThreads.single.subject, contains('Welcome'));
    });

    test(
        'startTrial persists runtime session token and returns a live experience',
        () async {
      final sessionStore = _MemoryPortalSessionStore();
      Map<String, dynamic>? capturedBody;
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient({
          '/api/client/session/start-trial': {
            'session_token': 'runtime-session-123',
            'experience': {
              'session': {
                'account_id': 'acc_1001',
                'device_name': 'Android device',
                'username': 'guest-acc_1001',
                'is_authorized': true,
              },
              'dashboard': {
                'sub_type': 'TRIAL',
                'current_plan_code': 'trial_5_days',
                'is_active': true,
                'expiry_at': '2026-03-24T00:00:00Z',
                'used_gb': 0,
                'total_gb': 15,
                'remaining_gb': 15,
                'active_sessions': 0,
                'device_limit': 1,
              },
              'user': {
                'account_id': 'acc_1001',
                'username': 'guest-acc_1001',
                'is_active': true,
                'sub_type': 'TRIAL',
                'client_policy': {
                  'routing_mode_default': 'all_except_ru',
                  'transport_profile': 'grpc_443_primary',
                  'dns_policy': 'ru_direct_split',
                  'package_catalog_version': '2026.04.13.1',
                  'ruleset_version': '2026.04.13.rules',
                  'support_context': {
                    'transport': 'grpc_443_primary',
                    'routing_mode': 'all_except_ru',
                    'ip_version_preference': 'ipv4_only',
                  },
                  'support_recovery_order': ['app', 'web', 'telegram'],
                },
                'expiry_at': '2026-03-24T00:00:00Z',
                'devices': [
                  {
                    'id': 'device_1',
                    'name': 'Android device',
                    'platform': 'Android',
                    'is_active': true,
                    'last_seen_at': '2026-03-19T08:00:00Z',
                  }
                ],
              },
              'plans': {
                'widget_enabled': true,
                'plans': [
                  {
                    'code': '1_month',
                    'label': '1 Month',
                    'amount_rub': 249,
                    'amount_stars': 249,
                    'days': 30,
                    'device_limit': 5,
                    'node_policy': 'paid_pool',
                    'badge': 'Popular',
                    'is_active': true,
                    'sort_order': 1,
                  }
                ],
              },
              'tickets': {
                'tickets': [],
              },
              'apps': {
                'android': {
                  'apk_url': 'https://cdn.example.test/portal.apk',
                },
              },
              'node_status': {
                'nodes': [
                  {
                    'code': 'nl',
                    'country': 'Netherlands',
                    'is_healthy': true,
                  }
                ],
              },
              'provisioning': {
                'status': 'ready',
                'managed_manifest': {
                  'url': '/api/client/managed-manifest/install-123',
                  'transport_kind': 'managed-http',
                  'engine_hint': 'sing-box',
                  'profile_revision': 'rev-7',
                },
              },
            },
          },
        }, onPost: (path, body) async {
          capturedBody = body;
          return {
            'session_token': 'runtime-session-123',
            'experience': {
              'session': {
                'account_id': 'acc_1001',
                'device_name': 'Android device',
                'username': 'guest-acc_1001',
                'is_authorized': true,
              },
              'dashboard': {
                'sub_type': 'TRIAL',
                'current_plan_code': 'trial_5_days',
                'is_active': true,
                'expiry_at': '2026-03-24T00:00:00Z',
                'used_gb': 0,
                'total_gb': 15,
                'remaining_gb': 15,
                'active_sessions': 0,
                'device_limit': 1,
              },
              'user': {
                'account_id': 'acc_1001',
                'username': 'guest-acc_1001',
                'is_active': true,
                'sub_type': 'TRIAL',
                'client_policy': {
                  'routing_mode_default': 'all_except_ru',
                  'transport_profile': 'grpc_443_primary',
                  'dns_policy': 'ru_direct_split',
                  'package_catalog_version': '2026.04.13.1',
                  'ruleset_version': '2026.04.13.rules',
                  'support_context': {
                    'transport': 'grpc_443_primary',
                    'routing_mode': 'all_except_ru',
                    'ip_version_preference': 'ipv4_only',
                  },
                  'support_recovery_order': ['app', 'web', 'telegram'],
                },
                'expiry_at': '2026-03-24T00:00:00Z',
                'devices': [
                  {
                    'id': 'device_1',
                    'name': 'Android device',
                    'platform': 'Android',
                    'is_active': true,
                    'last_seen_at': '2026-03-19T08:00:00Z',
                  }
                ],
              },
              'plans': {
                'widget_enabled': true,
                'plans': [
                  {
                    'code': '1_month',
                    'label': '1 Month',
                    'amount_rub': 249,
                    'amount_stars': 249,
                    'days': 30,
                    'device_limit': 5,
                    'node_policy': 'paid_pool',
                    'badge': 'Popular',
                    'is_active': true,
                    'sort_order': 1,
                  }
                ],
              },
              'tickets': {
                'tickets': [],
              },
              'apps': {
                'android': {
                  'apk_url': 'https://cdn.example.test/portal.apk',
                },
              },
              'node_status': {
                'nodes': [
                  {
                    'code': 'nl',
                    'country': 'Netherlands',
                    'is_healthy': true,
                  }
                ],
              },
              'provisioning': {
                'status': 'ready',
                'managed_manifest': {
                  'url': '/api/client/managed-manifest/install-123',
                  'transport_kind': 'managed-http',
                  'engine_hint': 'sing-box',
                  'profile_revision': 'rev-7',
                },
              },
            },
          };
        },),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore: sessionStore,
      );

      final experience = await repository.startTrial(
        const PortalStartTrialRequest(
          installId: 'install-123',
          deviceName: 'Android device',
          platform: 'android',
          operatingSystemVersion: '14',
          appVersion: '1.0.0',
          localeTag: 'ru',
          timeZone: 'MSK',
        ),
      );

      expect(
          sessionStore.readSessionTokenSync(), equals('runtime-session-123'),);
      expect(experience.isDemo, isFalse);
      expect(experience.session.isAuthorized, isTrue);
      expect(experience.importPayload.subscriptionUrl, isEmpty);
      expect(experience.devices.single.title, equals('Android device'));
      expect(experience.locations.single.title, equals('Netherlands'));
      expect(experience.connectionPolicy.routingModeDefault, 'all_except_ru');
      expect(experience.connectionPolicy.transportProfile, 'grpc_443_primary');
      expect(experience.connectionPolicy.dnsPolicy, 'ru_direct_split');
      expect(
        experience.connectionPolicy.packageCatalogVersion,
        '2026.04.13.1',
      );
      expect(
        experience.connectionPolicy.rulesetVersion,
        '2026.04.13.rules',
      );
      expect(
        experience.connectionPolicy.supportContext.transport,
        'grpc_443_primary',
      );
      expect(
        experience.connectionPolicy.supportContext.routingMode,
        'all_except_ru',
      );
      expect(
        experience.connectionPolicy.supportContext.ipVersionPreference,
        'ipv4_only',
      );
      expect(
        experience.connectionPolicy.supportRecoveryOrder,
        equals(<String>['app', 'web', 'telegram']),
      );
      expect(
        experience.importPayload.managedManifest.url,
        '/api/client/managed-manifest/install-123',
      );
      expect(
        experience.importPayload.managedManifest.transportKind,
        'managed-http',
      );
      expect(
        experience.importPayload.managedManifest.engineHint,
        'sing-box',
      );
      expect(
        experience.importPayload.managedManifest.profileRevision,
        'rev-7',
      );
      expect(capturedBody, isNotNull);
      expect(capturedBody!['install_id'], equals('install-123'));
      expect(capturedBody!.containsKey('trial_days'), isFalse);
      expect(capturedBody!['locale'], equals('ru'));
    });

    test(
        'startTrial reads the top-level app-first contract and prefers nested subscription urls',
        () async {
      final sessionStore = _MemoryPortalSessionStore();
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient(
          const {},
          onPost: (path, body) async {
            return {
              'session_token': 'runtime-session-456',
              'account_id': 'acc_2001',
              'subscription_url':
                  'https://portal.example.test/sub/top-level-fallback',
              'session': {
                'session_token': 'runtime-session-456',
                'account_id': 'acc_2001',
                'subscription_url':
                    'https://portal.example.test/sub/session-fallback',
                'linked_telegram_username': 'portal_user',
              },
              'client_policy': {
                'routing_mode_default': 'all_except_ru',
                'transport_profile': 'grpc_443_primary',
                'dns_policy': 'ru_direct_split',
                'support_context': {
                  'transport': 'grpc_443_primary',
                },
              },
              'access': {
                'sub_type': 'TRIAL',
                'current_plan_code': 'trial_5_days',
                'is_active': true,
                'expiry_at': '2026-03-24T00:00:00Z',
                'subscription_url':
                    'https://portal.example.test/sub/from-access',
                'trial_days': 5,
              },
              'provisioning': {
                'status': 'ready',
                'sync_ok': true,
                'subscription_url':
                    'https://portal.example.test/sub/from-provisioning',
                'managed_manifest': {
                  'url': '/api/client/profile/managed',
                  'transport_kind': 'managed-http',
                  'engine_hint': 'sing-box',
                  'profile_revision': 'rev-8',
                },
              },
            };
          },
        ),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore: sessionStore,
      );

      final experience = await repository.startTrial(
        const PortalStartTrialRequest(
          installId: 'install-456',
          deviceName: 'Android device',
          platform: 'android',
          operatingSystemVersion: '14',
          appVersion: '1.0.0',
          localeTag: 'ru',
          timeZone: 'MSK',
        ),
      );

      expect(
        sessionStore.readSessionTokenSync(),
        equals('runtime-session-456'),
      );
      expect(experience.isDemo, isFalse);
      expect(
        experience.importPayload.subscriptionUrl,
        equals('https://portal.example.test/sub/from-access'),
      );
      expect(
        experience.importPayload.managedManifest.url,
        equals('/api/client/profile/managed'),
      );
      expect(experience.connectionPolicy.transportProfile, 'grpc_443_primary');
    });

    test(
        'startTrial keeps the temporary top-level subscription fallback when app-first fields omit it',
        () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient(
          const {},
          onPost: (path, body) async {
            return {
              'session_token': 'runtime-session-789',
              'account_id': 'acc_3001',
              'subscription_url':
                  'https://portal.example.test/sub/top-level-fallback',
              'session': {
                'session_token': 'runtime-session-789',
                'account_id': 'acc_3001',
              },
              'client_policy': {
                'routing_mode_default': 'all_except_ru',
              },
              'access': {
                'sub_type': 'TRIAL',
                'current_plan_code': 'trial_5_days',
                'is_active': true,
              },
              'provisioning': {
                'status': 'pending_sync',
                'sync_ok': false,
                'managed_manifest': {
                  'url': '/api/client/profile/managed',
                },
              },
            };
          },
        ),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore: _MemoryPortalSessionStore(),
      );

      final experience = await repository.startTrial(
        const PortalStartTrialRequest(
          installId: 'install-789',
          deviceName: 'Android device',
          platform: 'android',
          operatingSystemVersion: '14',
          appVersion: '1.0.0',
          localeTag: 'ru',
          timeZone: 'MSK',
        ),
      );

      expect(
        experience.importPayload.subscriptionUrl,
        equals('https://portal.example.test/sub/top-level-fallback'),
      );
      expect(
        experience.importPayload.managedManifest.url,
        equals('/api/client/profile/managed'),
      );
    });

    test('requestTelegramLink returns deep link payload for app-first account',
        () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient(
          const {
            '/api/client/telegram/link': {
              'ok': true,
              'linked': false,
              'linked_telegram_id': null,
              'linked_telegram_username': null,
              'start_code': 'appabc123',
              'bot_url': 'https://t.me/portal_service_bot?start=appabc123',
              'channel_url': 'https://t.me/portal_privacy',
            },
          },
        ),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore:
            _MemoryPortalSessionStore(sessionToken: 'runtime-session-123'),
      );

      final link = await repository.requestTelegramLink();

      expect(link.linked, isFalse);
      expect(link.startCode, equals('appabc123'));
      expect(link.botUrl, contains('portal_service_bot'));
      expect(link.channelUrl, contains('portal_privacy'));
    });

    test('claimTelegramBonus returns successful bonus grant payload', () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient(
          const {
            '/api/bonuses/channel/claim': {
              'ok': true,
              'already_claimed': false,
              'premium_days': 10,
              'linked_telegram_id': 777001,
              'linked_telegram_username': 'portal_user',
            },
          },
        ),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore:
            _MemoryPortalSessionStore(sessionToken: 'runtime-session-123'),
      );

      final bonus = await repository.claimTelegramBonus();

      expect(bonus.ok, isTrue);
      expect(bonus.alreadyClaimed, isFalse);
      expect(bonus.premiumDays, equals(10));
      expect(bonus.linkedTelegramUsername, equals('portal_user'));
    });

    test('fetchManagedManifest returns raw manifest body from portal api',
        () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient(
          const {},
          textResponses: const {
            '/api/client/managed-manifest/install-123': '{"kind":"managed"}',
          },
        ),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore:
            _MemoryPortalSessionStore(sessionToken: 'runtime-session-123'),
      );

      final manifestBody = await repository.fetchManagedManifest(
        const PortalManagedManifest(
          url: '/api/client/managed-manifest/install-123',
          transportKind: 'managed-http',
          engineHint: 'sing-box',
          profileRevision: 'rev-7',
        ),
      );

      expect(manifestBody, equals('{"kind":"managed"}'));
    });
  });
}
