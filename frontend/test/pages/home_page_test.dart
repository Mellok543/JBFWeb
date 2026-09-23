import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/pages/home_page.dart';
import 'package:jbforsaken_web/theme/jbf_theme.dart';

void main() {
  testWidgets('renders the JBForsaken hero and core actions', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(theme: jbfTheme, home: const HomePage()));
    await tester.pump();

    expect(find.text('JBFORSAKEN'), findsWidgets);
    expect(find.text('CS2 • JAILBREAK • COMMUNITY'), findsOneWidget);
    expect(find.text('ПОДКЛЮЧИТЬСЯ'), findsOneWidget);
    expect(find.text('Экосистема сервера'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
