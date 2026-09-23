import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/widgets/jbf_button.dart';

void main() {
  testWidgets('JbfButton fires onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: JbfButton(
        label: 'Играть',
        variant: JbfButtonVariant.primary,
        onPressed: () => tapped = true,
      ),
    ));

    await tester.tap(find.text('ИГРАТЬ'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('JbfButton renders its label uppercased', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: JbfButton(label: 'Правила', variant: JbfButtonVariant.ghost),
    ));

    expect(find.text('ПРАВИЛА'), findsOneWidget);
  });
}
