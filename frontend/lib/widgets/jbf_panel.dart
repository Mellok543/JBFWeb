import 'package:flutter/material.dart';
import '../theme/jbf_theme.dart';

class JbfPanel extends StatelessWidget {
  final Widget child;

  const JbfPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JbfColors.panel0,
        border: Border.all(color: JbfColors.borderCyan),
        borderRadius: BorderRadius.circular(JbfRadii.md),
      ),
      child: child,
    );
  }
}
