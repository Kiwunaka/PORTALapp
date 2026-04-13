import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_api_client.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MemoryPortalSessionStore implements PortalSessionStore {
  _MemoryPortalSessionStore({
    this.installId = 'install-123',
    this.sessionToken = '',
  });

  final String installId;
  final String sessionToken;

  @override
  Future<void> clearSession() async {}

  @override
  Future<String> ensureInstallId() async => installId;

  @override
  bool get hasSessionAuth => sessionToken.isNotEmpty;

  @override
  String readInstallIdSync() => installId;

  @override
  String readSessionTokenSync() => sessionToken;

  @override
  Future<void> saveSessionToken(String value) async {}
}

void main() {
  test('resolves start-trial against the canonical API host when env is blank',
      () async {
    late Uri requestedUri;
    late Map<String, String> requestedHeaders;

    final client = HttpPortalApiClient(
      config: PortalPublicConfig.fromMap(const {
        'PORTAL_API_BASE_URL': '',
      }),
      sessionStore: _MemoryPortalSessionStore(sessionToken: 'runtime-token'),
      client: MockClient((request) async {
        requestedUri = request.url;
        requestedHeaders = request.headers;
        return http.Response(jsonEncode({'ok': true}), 200);
      }),
    );

    await client.postJson(
      '/api/client/session/start-trial',
      const {'install_id': 'install-123'},
    );

    expect(
      requestedUri.toString(),
      equals('https://api.pokrov.space/api/client/session/start-trial'),
    );
    expect(requestedHeaders['Authorization'], equals('Bearer runtime-token'));
    expect(requestedHeaders['X-App-Session-Token'], equals('runtime-token'));
    expect(requestedHeaders['X-Portal-Install-Id'], equals('install-123'));
  });

  test('fetches managed manifest text with runtime auth headers', () async {
    late Uri requestedUri;
    late Map<String, String> requestedHeaders;

    final client = HttpPortalApiClient(
      config: PortalPublicConfig.fromMap(const {
        'PORTAL_API_BASE_URL': '',
      }),
      sessionStore: _MemoryPortalSessionStore(sessionToken: 'runtime-token'),
      client: MockClient((request) async {
        requestedUri = request.url;
        requestedHeaders = request.headers;
        return http.Response('{"kind":"managed"}', 200);
      }),
    );

    final body = await client.getText('/api/client/managed-manifest');

    expect(body, equals('{"kind":"managed"}'));
    expect(
      requestedUri.toString(),
      equals('https://api.pokrov.space/api/client/managed-manifest'),
    );
    expect(requestedHeaders['Authorization'], equals('Bearer runtime-token'));
    expect(requestedHeaders['X-App-Session-Token'], equals('runtime-token'));
    expect(requestedHeaders['X-Portal-Install-Id'], equals('install-123'));
  });
}
