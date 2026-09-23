import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/pages/home_page.dart';

void main() {
  testWidgets('renders the hero, actions, and the coming-soon strip', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();

    expect(find.text('JBFORSAKEN'), findsOneWidget);
    expect(find.text('CS2 JAILBREAK'), findsOneWidget);
    expect(find.text('ИГРАТЬ'), findsOneWidget);
    expect(find.text('ПРАВИЛА'), findsOneWidget);
    expect(find.text('Скоро'), findsOneWidget);
  });
}
