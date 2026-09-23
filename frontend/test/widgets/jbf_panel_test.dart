import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/widgets/jbf_panel.dart';

void main() {
  testWidgets('JbfPanel renders its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: JbfPanel(child: Text('panel content'))),
    );

    expect(find.text('panel content'), findsOneWidget);
  });
}
