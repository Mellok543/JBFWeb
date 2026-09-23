import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/api/auth_api.dart';
import 'package:jbforsaken_web/state/auth_notifier.dart';
import 'package:jbforsaken_web/widgets/main_layout.dart';

void main() {
  setUp(() {
    authNotifier.user = null;
  });

  testWidgets('shows a Steam login link when logged out', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainLayout(child: Text('page content'))));
    await tester.pump();

    expect(find.text('page content'), findsOneWidget);
    expect(find.text('ВОЙТИ ЧЕРЕЗ STEAM'), findsOneWidget);
  });

  testWidgets('shows the nickname and a logout control when logged in', (tester) async {
    authNotifier.user = AuthUser(steamId64: '76561198000000000', nickname: 'Mell', avatarUrl: null);

    await tester.pumpWidget(const MaterialApp(home: MainLayout(child: Text('page content'))));
    authNotifier.notifyListeners();
    await tester.pump();

    expect(find.text('Mell'), findsOneWidget);
    expect(find.text('Выйти'), findsOneWidget);
  });
}
