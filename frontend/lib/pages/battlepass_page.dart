import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/portal_api.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class BattlepassPage extends StatelessWidget {
  const BattlepassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Пропуск',
      title: 'Jailbreak Battle Pass',
      subtitle: 'Сезон, уровни и награды теперь приходят из backend.',
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: fetchBattlePass(apiClient),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return InfoStrip(
                icon: Icons.error_outline_rounded,
                title: 'Battle Pass недоступен',
                text: snapshot.error.toString(),
              );
            }

            final data = snapshot.data ?? const {};
            final season = data['season'] as Map<String, dynamic>?;
            final levels = (data['levels'] as List? ?? const [])
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
            final progress = data['progress'] as Map<String, dynamic>?;

            if (season == null) {
              return const InfoStrip(
                icon: Icons.event_busy_outlined,
                title: 'Активного сезона нет',
                text: 'Создайте сезон в jbf_web_battlepass_seasons.',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [JbfColors.panel1, JbfColors.bg1],
                    ),
                    borderRadius: BorderRadius.circular(JbfRadii.lg),
                    border: Border.all(color: JbfColors.borderLime),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: JbfColors.accentLime, size: 34),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              season['name']?.toString() ?? season['code'].toString(),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              progress == null
                                  ? 'Войдите через Steam, чтобы увидеть прогресс.'
                                  : 'XP: ${progress['xp']} • Premium: ${progress['premium'] == true ? 'да' : 'нет'}',
                              style: const TextStyle(color: JbfColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final level in levels)
                      FeatureCard(
                        icon: Icons.stars_rounded,
                        title: 'Уровень ${level['levelNumber']}',
                        text: 'XP: ${level['xpRequired']}\nНаграда: ${level['rewardTitle']}',
                        accent: JbfColors.accentPurple,
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
