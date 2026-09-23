import 'package:flutter/material.dart';
import '../theme/jbf_theme.dart';

enum JbfButtonVariant { primary, secondary, ghost }

class JbfButton extends StatelessWidget {
  final String label;
  final JbfButtonVariant variant;
  final VoidCallback? onPressed;

  const JbfButton({super.key, required this.label, required this.variant, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final Color background = switch (variant) {
      JbfButtonVariant.primary => JbfColors.accentLime,
      JbfButtonVariant.secondary => Colors.transparent,
      JbfButtonVariant.ghost => Colors.transparent,
    };
    final Color foreground = switch (variant) {
      JbfButtonVariant.primary => JbfColors.bg0,
      JbfButtonVariant.secondary => JbfColors.accentCyan,
      JbfButtonVariant.ghost => JbfColors.textSecondary,
    };
    final BorderSide border = switch (variant) {
      JbfButtonVariant.secondary => const BorderSide(color: JbfColors.borderCyan),
      _ => BorderSide.none,
    };

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        side: border,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(JbfRadii.sm)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }
}
