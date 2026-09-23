import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jbforsaken_web/api/auth_api.dart';
import 'package:jbforsaken_web/state/auth_notifier.dart';
import 'package:jbforsaken_web/widgets/main_layout.dart';

GoRouter _router() => GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('page content')),
        GoRoute(path: '/profile', builder: (context, state) => const Text('profile')),
        GoRoute(path: '/admin', builder: (context, state) => const Text('admin')),
      ],
    ),
  ],
);

void main() {
  setUp(() {
    authNotifier.user = null;
    authNotifier.isAdmin = false;
  });

  testWidgets('shows Steam login when logged out', (tester) async {
    final router = _router();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.text('page content'), findsOneWidget);
    expect(find.text('ВОЙТИ ЧЕРЕЗ STEAM'), findsOneWidget);
  });

  testWidgets('shows admin item for an authorized logged-in user', (tester) async {
    authNotifier.user = AuthUser(
      steamId64: '76561198000000000',
      nickname: 'Mell',
      avatarUrl: null,
    );
    authNotifier.isAdmin = true;

    final router = _router();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    authNotifier.notifyListeners();
    await tester.pump();

    expect(find.text('Mell'), findsOneWidget);
    await tester.tap(find.text('Mell'));
    await tester.pumpAndSettle();

    expect(find.text('Профиль'), findsOneWidget);
    expect(find.text('Админ-панель'), findsOneWidget);
    expect(find.text('Выйти'), findsOneWidget);
  });
}
