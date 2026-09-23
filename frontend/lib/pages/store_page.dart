import 'package:flutter/material.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Магазин',
      title: 'Привилегии и косметика',
      subtitle: 'Структура магазина уже подготовлена. После подключения backend-каталога карточки будут загружаться из базы.',
      children: [
        const InfoStrip(
          icon: Icons.lock_clock_outlined,
          title: 'Покупки будут идемпотентными',
          text: 'Повторный запрос с тем же ключом не создаст вторую покупку и не выдаст товар повторно.',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            FeatureCard(
              icon: Icons.workspace_premium_outlined,
              title: 'VIP',
              text: 'Базовая привилегия сервера: дополнительные возможности, визуальные бонусы и удобства.',
              accent: JbfColors.accentLime,
              footer: OutlinedButton(onPressed: () {}, child: const Text('СКОРО')),
            ),
            FeatureCard(
              icon: Icons.diamond_outlined,
              title: 'PREMIUM',
              text: 'Расширенный пакет для активных игроков с дополнительными преимуществами.',
              accent: JbfColors.accentPurple,
              footer: OutlinedButton(onPressed: () {}, child: const Text('СКОРО')),
            ),
            FeatureCard(
              icon: Icons.style_outlined,
              title: 'Косметика',
              text: 'Короны, крылья, питомцы и другие визуальные предметы JBFORSAKEN.',
              accent: JbfColors.accentCyan,
              footer: OutlinedButton(onPressed: () {}, child: const Text('СКОРО')),
            ),
          ],
        ),
      ],
    );
  }
}
