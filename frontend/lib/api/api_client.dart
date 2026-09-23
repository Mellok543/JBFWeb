import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

const String apiBaseUrl =
    String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:5080');

/// Set by the auth layer (Task 11) once a JWT is available; read by every
/// request this client makes. `null` means "not logged in".
String? currentAuthToken;

class ApiException implements Exception {
  final int statusCode;
  final String body;

  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}

class ApiClient {
  final http.Client _client;
  static const _uuid = Uuid();

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(Uri.parse('$apiBaseUrl$path'), headers: _authHeaders());
    _throwIfNotOk(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final headers = _authHeaders();
    headers['Content-Type'] = 'application/json';
    headers['Idempotency-Key'] = _uuid.v4();

    final response = await _client.post(
      Uri.parse('$apiBaseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _throwIfNotOk(response);
    return response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
  }

  Map<String, String> _authHeaders() {
    final headers = <String, String>{};
    if (currentAuthToken != null) {
      headers['Authorization'] = 'Bearer $currentAuthToken';
    }
    return headers;
  }

  void _throwIfNotOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}

final apiClient = ApiClient();
