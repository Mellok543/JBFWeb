import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../theme/jbf_theme.dart';
import '../widgets/jbf_button.dart';
import '../widgets/jbf_panel.dart';
import '../widgets/server_status.dart';

const String _discordUrl = String.fromEnvironment('DISCORD_URL');
const String _telegramUrl = String.fromEnvironment('TELEGRAM_URL');

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 32,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: 560,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JBFORSAKEN',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: JbfColors.textPrimary),
                        ),
                        const Text(
                          'CS2 JAILBREAK',
                          style: TextStyle(fontSize: 22, color: JbfColors.accentLime),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Тактический Jailbreak-сервер JBFORSAKEN: командиры, LR, Special Days, '
                          'Battle Pass и собственная система косметики.',
                          style: TextStyle(color: JbfColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            JbfButton(
                              label: 'ИГРАТЬ',
                              variant: JbfButtonVariant.primary,
                              // Static fallback default so this button works before the
                              // first status poll completes; unlike ServerStatus's own
                              // CONNECT button, HomePage has no live status object to read
                              // the backend-sourced connectAddress from.
                              onPressed: () => launchUrl(Uri.parse('steam://connect/$connectHost:$connectPort')),
                            ),
                            if (_discordUrl.isNotEmpty)
                              JbfButton(
                                label: 'Discord',
                                variant: JbfButtonVariant.secondary,
                                onPressed: () => launchUrl(Uri.parse(_discordUrl)),
                              ),
                            if (_telegramUrl.isNotEmpty)
                              JbfButton(
                                label: 'Telegram',
                                variant: JbfButtonVariant.secondary,
                                onPressed: () => launchUrl(Uri.parse(_telegramUrl)),
                              ),
                            JbfButton(
                              label: 'ПРАВИЛА',
                              variant: JbfButtonVariant.ghost,
                              onPressed: () => context.go('/rules'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const ServerStatus(),
                ],
              ),
              const SizedBox(height: 24),
              const JbfPanel(
                child: Row(
                  children: [
                    Text('Скоро', style: TextStyle(color: JbfColors.accentCyan, fontWeight: FontWeight.bold)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Новости, рейтинг игроков, Battle Pass и косметика появятся здесь после '
                        'подключения к игровой базе данных.',
                        style: TextStyle(color: JbfColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
