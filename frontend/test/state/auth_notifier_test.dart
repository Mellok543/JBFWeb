import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jbforsaken_web/api/api_client.dart';
import 'package:jbforsaken_web/api/auth_api.dart';
import 'package:jbforsaken_web/state/auth_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    currentAuthToken = null;
  });

  test('completeLogin exchanges the code, stores the token, and populates the user', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/auth/exchange') {
        return http.Response('{"token":"jwt-123","expiresAt":"2026-01-01T00:00:00Z"}', 200);
      }
      if (request.url.path == '/api/auth/me') {
        return http.Response('{"steamId64":"76561198000000000","nickname":"Mell","avatarUrl":null}', 200);
      }
      if (request.url.path == '/api/admin/me') {
        return http.Response('{"admin":false}', 200);
      }
      return http.Response('not found', 404);
    });
    final notifier = AuthNotifier(client: ApiClient(client: mockClient));

    await notifier.completeLogin('some-code');

    expect(notifier.user?.steamId64, '76561198000000000');
    expect(notifier.user?.nickname, 'Mell');
    expect(currentAuthToken, 'jwt-123');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('jbf_auth_token'), 'jwt-123');
  });

  test('logout clears the user, the in-memory token, and the stored token', () async {
    final mockClient = MockClient((request) async => http.Response('{}', 200));
    final notifier = AuthNotifier(client: ApiClient(client: mockClient));
    currentAuthToken = 'jwt-123';
    notifier.user = AuthUser(steamId64: '1', nickname: null, avatarUrl: null);

    await notifier.logout();

    expect(notifier.user, isNull);
    expect(currentAuthToken, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('jbf_auth_token'), isNull);
  });

  test('loadStoredToken populates the user when a token was previously saved', () async {
    SharedPreferences.setMockInitialValues({'jbf_auth_token': 'stored-jwt'});
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/auth/me') {
        return http.Response('{"steamId64":"1","nickname":"Stored","avatarUrl":null}', 200);
      }
      if (request.url.path == '/api/admin/me') {
        return http.Response('{"admin":true}', 200);
      }
      return http.Response('not found', 404);
    });
    final notifier = AuthNotifier(client: ApiClient(client: mockClient));

    await notifier.loadStoredToken();

    expect(currentAuthToken, 'stored-jwt');
    expect(notifier.user?.nickname, 'Stored');
    expect(notifier.isAdmin, isTrue);
  });

  test('isLoading resets to false when /api/auth/me fails with a non-401 error', () async {
    SharedPreferences.setMockInitialValues({'jbf_auth_token': 'stored-jwt'});
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/auth/me') {
        return http.Response('server error', 500);
      }
      return http.Response('not found', 404);
    });
    final notifier = AuthNotifier(client: ApiClient(client: mockClient));

    await expectLater(notifier.loadStoredToken(), throwsA(isA<ApiException>()));

    expect(notifier.isLoading, isFalse);
  });
}
