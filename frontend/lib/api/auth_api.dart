import 'api_client.dart';

class AuthUser {
  final String steamId64;
  final String? nickname;
  final String? avatarUrl;

  AuthUser({required this.steamId64, required this.nickname, required this.avatarUrl});

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        steamId64: json['steamId64'] as String,
        nickname: json['nickname'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class ExchangeResult {
  final String token;
  final String expiresAt;

  ExchangeResult({required this.token, required this.expiresAt});

  factory ExchangeResult.fromJson(Map<String, dynamic> json) => ExchangeResult(
        token: json['token'] as String,
        expiresAt: json['expiresAt'] as String,
      );
}

Future<AuthUser?> fetchMe(ApiClient client) async {
  try {
    final json = await client.get('/api/auth/me');
    return AuthUser.fromJson(json);
  } on ApiException catch (e) {
    if (e.statusCode == 401) {
      return null;
    }
    rethrow;
  }
}

Future<ExchangeResult> exchangeCode(ApiClient client, String code) async {
  final json = await client.post('/api/auth/exchange', body: {'code': code});
  return ExchangeResult.fromJson(json);
}
