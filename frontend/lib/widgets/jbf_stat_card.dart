import 'package:flutter/material.dart';
import '../theme/jbf_theme.dart';

class JbfStatCard extends StatelessWidget {
  final String label;
  final String value;

  const JbfStatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: JbfColors.panel1,
        border: Border.all(color: JbfColors.borderCyan),
        borderRadius: BorderRadius.circular(JbfRadii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: JbfColors.textSecondary, fontSize: 11, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: JbfColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
