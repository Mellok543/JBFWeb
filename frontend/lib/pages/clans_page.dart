import 'package:flutter/material.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class ClansPage extends StatelessWidget {
  const ClansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Кланы',
      title: 'Команды JBFORSAKEN',
      subtitle: 'Клановая система закладывается как отдельный модуль: создание команды, участники, рейтинг и общая статистика.',
      children: [
        const InfoStrip(
          icon: Icons.groups_rounded,
          title: 'Модуль пока без игровой интеграции',
          text: 'UI уже выделен отдельно, а данные будут поступать из backend после появления таблиц кланов.',
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            FeatureCard(
              icon: Icons.add_business_rounded,
              title: 'Создание клана',
              text: 'Название, тег, описание, владелец и система приглашений.',
            ),
            FeatureCard(
              icon: Icons.emoji_events_outlined,
              title: 'Рейтинг',
              text: 'Очки клана за активность участников, достижения и сезонные события.',
              accent: JbfColors.accentLime,
            ),
            FeatureCard(
              icon: Icons.manage_accounts_outlined,
              title: 'Управление',
              text: 'Роли участников, заявки, исключения и журнал важных действий.',
              accent: JbfColors.accentCyan,
            ),
          ],
        ),
      ],
    );
  }
}
