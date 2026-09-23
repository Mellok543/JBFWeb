import 'package:flutter/material.dart';
import '../theme/jbf_theme.dart';

enum JbfBadgeTone { online, offline, neutral }

class JbfBadge extends StatelessWidget {
  final String label;
  final JbfBadgeTone tone;

  const JbfBadge({super.key, required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    final Color color = switch (tone) {
      JbfBadgeTone.online => JbfColors.success,
      JbfBadgeTone.offline => JbfColors.error,
      JbfBadgeTone.neutral => JbfColors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(JbfRadii.sm),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, letterSpacing: 0.5)),
    );
  }
}
