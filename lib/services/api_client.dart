import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl, this.accessToken})
    : _client = client ?? http.Client(),
      _baseUrl = _normaliseBaseUrl(baseUrl ?? AppConfig.apiBaseUrl);

  final http.Client _client;
  final Uri _baseUrl;
  String? accessToken;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);
  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);
  Future<dynamic> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);
  Future<dynamic> delete(String path) =>
    _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _baseUrl.resolve(path).replace(queryParameters: query);
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (accessToken?.isNotEmpty == true) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);
      final decoded = response.body.isEmpty ? null : _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _error(decoded, response.statusCode);
      }
      return decoded;
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Could not reach Yaku. Check your connection and API address.',
      );
    }
  }

  dynamic _decode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const ApiException(
        'Yaku returned an unreadable response. Please try again.',
      );
    }
  }

  ApiException _error(dynamic body, int statusCode) {
    final error = body is Map<String, dynamic> ? body['error'] : null;
    if (error is Map<String, dynamic>) {
      return ApiException(
        error['message'] is String
            ? error['message'] as String
            : 'Yaku could not complete that request.',
        statusCode: statusCode,
        code: error['code'] as String?,
      );
    }
    return ApiException(
      'Yaku could not complete that request.',
      statusCode: statusCode,
    );
  }

  void close() => _client.close();

  static Uri _normaliseBaseUrl(String value) {
    final parsed = Uri.parse(value);
    return parsed.path.endsWith('/')
        ? parsed
        : parsed.replace(path: '${parsed.path}/');
  }
}
