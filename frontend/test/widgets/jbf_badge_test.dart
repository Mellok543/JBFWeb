import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/theme/jbf_theme.dart';
import 'package:jbforsaken_web/widgets/jbf_badge.dart';

void main() {
  testWidgets('JbfBadge renders the label with the tone color', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: JbfBadge(label: 'ONLINE', tone: JbfBadgeTone.online),
    ));

    expect(find.text('ONLINE'), findsOneWidget);
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border!.top.color, JbfColors.success);
  });
}
