import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';
import '../widgets/server_status.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Играть',
      title: 'Подключение к JBFORSAKEN',
      subtitle: 'Статус сервера, текущая карта и быстрый запуск CS2 в одном месте.',
      children: [
        const ServerStatus(),
        const SizedBox(height: 24),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            FeatureCard(
              icon: Icons.play_arrow_rounded,
              title: 'Быстрый вход',
              text: 'Запусти Counter-Strike 2 и подключись напрямую к серверу.',
              accent: JbfColors.accentLime,
              footer: FilledButton.icon(
                onPressed: () => launchUrl(Uri.parse('steam://connect/$connectHost:$connectPort')),
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text('ПОДКЛЮЧИТЬСЯ'),
              ),
            ),
            const FeatureCard(
              icon: Icons.shield_outlined,
              title: 'Jailbreak',
              text: 'Раунды заключённых и охраны, командир, игры, Special Days и LR.',
            ),
            const FeatureCard(
              icon: Icons.auto_awesome_outlined,
              title: 'Свои механики',
              text: 'События, косметика, прогрессия и серверные системы JBFORSAKEN.',
              accent: JbfColors.accentPurple,
            ),
          ],
        ),
      ],
    );
  }
}
