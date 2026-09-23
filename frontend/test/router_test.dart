import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/router.dart';

void main() {
  testWidgets('shows HomePage content plus the shared header at the root route', (tester) async {
    router.go('/');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('JBFORSAKEN'), findsOneWidget);
    expect(find.text('JB'), findsOneWidget);
    expect(find.text('FORSAKEN'), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Правила'), findsOneWidget);
  });

  testWidgets('shows RulesPage content inside the same shared header', (tester) async {
    router.go('/rules');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Правила скоро появятся здесь.'), findsOneWidget);
    expect(find.text('JB'), findsOneWidget);
  });
}
