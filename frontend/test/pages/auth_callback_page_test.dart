import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jbforsaken_web/api/api_client.dart';
import 'package:jbforsaken_web/pages/auth_callback_page.dart';
import 'package:jbforsaken_web/state/auth_notifier.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    currentAuthToken = null;
    authNotifier.user = null;
  });

  tearDown(() {
    currentAuthToken = null;
    authNotifier.user = null;
  });

  testWidgets('shows an error when no code is present in the link', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthCallbackPage(code: null)));
    await tester.pump();

    expect(find.text('Код входа отсутствует в ссылке.'), findsOneWidget);
  });

  testWidgets('shows an error when completeLogin fails', (tester) async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/auth/exchange') {
        return http.Response('exchange failed', 500);
      }
      return http.Response('not found', 404);
    });
    final notifier = AuthNotifier(client: ApiClient(client: mockClient));

    await tester.pumpWidget(MaterialApp(
      home: AuthCallbackPage(code: 'some-code', notifier: notifier),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Не удалось завершить вход'), findsOneWidget);
  });
}
