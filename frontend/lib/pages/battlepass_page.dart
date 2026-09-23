import 'package:flutter/material.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class BattlepassPage extends StatelessWidget {
  const BattlepassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Пропуск',
      title: 'Jailbreak Battle Pass',
      subtitle: 'Сезонная система прогрессии: задания, уровни и награды, связанные именно с Jailbreak-геймплеем.',
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [JbfColors.panel1, JbfColors.bg1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(JbfRadii.lg),
            border: Border.all(color: JbfColors.borderLime),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_rounded, color: JbfColors.accentLime, size: 34),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('СЕЗОН 01', style: TextStyle(color: JbfColors.accentLime, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('Система готовится к подключению к игровой статистике и аккаунту Steam.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            FeatureCard(
              icon: Icons.task_alt_rounded,
              title: 'Ежедневные задания',
              text: 'Сыграть раунды, выполнить игровые условия, участвовать в Special Days и LR.',
            ),
            FeatureCard(
              icon: Icons.stars_rounded,
              title: 'Уровни',
              text: 'Опыт за активность на сервере и постепенное открытие сезонной линейки наград.',
              accent: JbfColors.accentLime,
            ),
            FeatureCard(
              icon: Icons.card_giftcard_rounded,
              title: 'Награды',
              text: 'Кредиты, косметика, значки профиля и ограниченные сезонные предметы.',
              accent: JbfColors.accentPurple,
            ),
          ],
        ),
      ],
    );
  }
}
