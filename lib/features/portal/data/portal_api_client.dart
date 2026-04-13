import 'dart:convert';

import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:http/http.dart' as http;

abstract interface class PortalApiClient {
  Future<Map<String, dynamic>> getJson(String path);

  Future<String> getText(String path);

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  );
}

class HttpPortalApiClient implements PortalApiClient {
  HttpPortalApiClient({
    required this.config,
    this.sessionStore,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final PortalPublicConfig config;
  final PortalSessionStore? sessionStore;
  final http.Client _client;

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _client.get(
      _resolve(path),
      headers: _headers(),
    );
    return _decode(response);
  }

  @override
  Future<String> getText(String path) async {
    final response = await _client.get(
      _resolve(path),
      headers: _headers(),
    );
    return _decodeText(response);
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      _resolve(path),
      headers: _headers(contentType: true),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Uri _resolve(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    return Uri.parse('${config.apiBaseUrl}$path');
  }

  Map<String, String> _headers({bool contentType = false}) {
    final runtimeSessionToken = sessionStore?.readSessionTokenSync() ?? '';
    final authToken = runtimeSessionToken.isNotEmpty
        ? runtimeSessionToken
        : config.webSessionToken;
    final installId = sessionStore?.readInstallIdSync() ?? '';
    return {
      if (contentType) 'Content-Type': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
      if (authToken.isNotEmpty) 'X-Web-Auth-Token': authToken,
      if (runtimeSessionToken.isNotEmpty)
        'X-App-Session-Token': runtimeSessionToken,
      if (installId.isNotEmpty) 'X-Portal-Install-Id': installId,
      if (config.telegramInitData.isNotEmpty)
        'X-Telegram-Init-Data': config.telegramInitData,
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Portal API error ${response.statusCode}: ${response.body}',
      );
    }
    if (response.body.trim().isEmpty) return const {};
    final parsed = jsonDecode(response.body);
    if (parsed is Map<String, dynamic>) return parsed;
    throw const FormatException('Portal API payload is not an object');
  }

  String _decodeText(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Portal API error ${response.statusCode}: ${response.body}',
      );
    }
    return response.body;
  }
}
