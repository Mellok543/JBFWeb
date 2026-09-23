import 'package:flutter/material.dart';
import '../state/auth_notifier.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Профиль',
      title: 'Личный кабинет',
      subtitle: 'Steam-профиль, прогресс, покупки, привилегии и игровая статистика.',
      children: [
        ListenableBuilder(
          listenable: authNotifier,
          builder: (context, _) {
            final user = authNotifier.user;
            if (user == null) {
              return const InfoStrip(
                icon: Icons.login_rounded,
                title: 'Нужна авторизация',
                text: 'Войди через Steam в верхнем меню, чтобы открыть персональный кабинет.',
              );
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: JbfColors.panel0,
                borderRadius: BorderRadius.circular(JbfRadii.lg),
                border: Border.all(color: JbfColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: JbfColors.panel2,
                    backgroundImage: user.avatarUrl == null ? null : NetworkImage(user.avatarUrl!),
                    child: user.avatarUrl == null ? const Icon(Icons.person_rounded, size: 36) : null,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nickname ?? 'Игрок JBFORSAKEN',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.steamId64,
                          style: const TextStyle(color: JbfColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            FeatureCard(
              icon: Icons.query_stats_rounded,
              title: 'Статистика',
              text: 'Игровое время, показатели Jailbreak, достижения и место в рейтинге.',
            ),
            FeatureCard(
              icon: Icons.workspace_premium_outlined,
              title: 'Привилегии',
              text: 'Активные VIP/Premium-пакеты, сроки действия и история.',
              accent: JbfColors.accentLime,
            ),
            FeatureCard(
              icon: Icons.inventory_2_outlined,
              title: 'Инвентарь',
              text: 'Косметика, сезонные награды и приобретённые предметы.',
              accent: JbfColors.accentPurple,
            ),
          ],
        ),
      ],
    );
  }
}
