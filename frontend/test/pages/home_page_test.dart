import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/pages/home_page.dart';

void main() {
  testWidgets('renders the JBForsaken hero and core actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();

    expect(find.text('JBFORSAKEN'), findsOneWidget);
    expect(find.text('CS2 • JAILBREAK • COMMUNITY'), findsOneWidget);
    expect(find.text('ПОДКЛЮЧИТЬСЯ'), findsOneWidget);
    expect(find.text('Экосистема сервера'), findsOneWidget);

    // Dispose HomePage so the server-status polling timer is cancelled.
    await tester.pumpWidget(const SizedBox());
  });
}
