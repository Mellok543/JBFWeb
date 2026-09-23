import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/widgets/jbf_stat_card.dart';

void main() {
  testWidgets('JbfStatCard renders label and value', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: JbfStatCard(label: 'PING', value: '24 ms'),
    ));

    expect(find.text('PING'), findsOneWidget);
    expect(find.text('24 ms'), findsOneWidget);
  });
}
