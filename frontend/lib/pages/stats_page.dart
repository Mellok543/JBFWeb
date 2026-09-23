import 'package:flutter/material.dart';
import '../state/auth_notifier.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Топы',
      title: 'Статистика игроков',
      subtitle: 'Будущая точка для рейтингов, рекордов и персональной статистики JBFORSAKEN.',
      children: [
        ListenableBuilder(
          listenable: authNotifier,
          builder: (context, _) {
            if (authNotifier.user == null) {
              return const InfoStrip(
                icon: Icons.lock_outline_rounded,
                title: 'Персональная статистика доступна после входа',
                text: 'Авторизация через Steam позволит связать сайт с игровым SteamID64.',
              );
            }
            return InfoStrip(
              icon: Icons.person_rounded,
              title: authNotifier.user!.nickname ?? authNotifier.user!.steamId64,
              text: 'Аккаунт авторизован. Здесь будут ранг, игровое время, победы, убийства, баланс и достижения.',
            );
          },
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            FeatureCard(
              icon: Icons.schedule_rounded,
              title: 'По времени',
              text: 'Самые активные игроки сервера за сезон и за всё время.',
            ),
            FeatureCard(
              icon: Icons.military_tech_outlined,
              title: 'По рейтингу',
              text: 'Общий рейтинг на основе игровой статистики и прогресса.',
              accent: JbfColors.accentLime,
            ),
            FeatureCard(
              icon: Icons.local_fire_department_outlined,
              title: 'Рекорды',
              text: 'Серии, достижения, победы в режимах и редкие игровые события.',
              accent: JbfColors.warning,
            ),
          ],
        ),
      ],
    );
  }
}
