import 'package:flutter/material.dart';
import '../theme/jbf_theme.dart';

class PageShell extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const PageShell({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  color: JbfColors.accentCyan,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 42),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      color: JbfColors.textSecondary,
                      fontSize: 16,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color? accent;
  final Widget? footer;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.accent,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final c = accent ?? JbfColors.accentCyan;
    return Container(
      width: 345,
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: JbfColors.panel0,
        borderRadius: BorderRadius.circular(JbfRadii.md),
        border: Border.all(color: JbfColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: c),
          ),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: JbfColors.textSecondary, height: 1.5)),
          if (footer != null) ...[
            const Spacer(),
            const SizedBox(height: 18),
            footer!,
          ],
        ],
      ),
    );
  }
}

class InfoStrip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const InfoStrip({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: JbfColors.bg1,
        borderRadius: BorderRadius.circular(JbfRadii.md),
        border: Border.all(color: JbfColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: JbfColors.accentLime),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(color: JbfColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
