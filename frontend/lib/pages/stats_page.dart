import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/portal_api.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String metric = 'playtime';

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Топы',
      title: 'Статистика игроков',
      subtitle: 'Рейтинги читаются из jbf_web_player_stats. Следующий этап — синхронизация этой таблицы с игровыми плагинами.',
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final item in const [
              ('playtime', 'Время'),
              ('kills', 'Убийства'),
              ('credits', 'Кредиты'),
              ('warden', 'Командир'),
            ])
              ChoiceChip(
                label: Text(item.$2),
                selected: metric == item.$1,
                onSelected: (_) => setState(() => metric = item.$1),
              ),
          ],
        ),
        const SizedBox(height: 18),
        FutureBuilder<List<Map<String, dynamic>>>(
          key: ValueKey(metric),
          future: fetchTopStats(apiClient, metric: metric),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return InfoStrip(
                icon: Icons.error_outline_rounded,
                title: 'Рейтинг недоступен',
                text: snapshot.error.toString(),
              );
            }

            final rows = snapshot.data ?? const [];
            if (rows.isEmpty) {
              return const InfoStrip(
                icon: Icons.leaderboard_outlined,
                title: 'Статистики пока нет',
                text: 'Игровой сервер ещё не синхронизировал данные игроков.',
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: JbfColors.panel0,
                borderRadius: BorderRadius.circular(JbfRadii.md),
                border: Border.all(color: JbfColors.border),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < rows.length; i++)
                    ListTile(
                      leading: SizedBox(
                        width: 34,
                        child: Text(
                          '#${i + 1}',
                          style: TextStyle(
                            color: i < 3 ? JbfColors.accentLime : JbfColors.textSecondary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      title: Text(rows[i]['steamId64'].toString()),
                      subtitle: Text(
                        'Время: ${rows[i]['playtimeMinutes']} мин • K/D: ${rows[i]['kills']}/${rows[i]['deaths']}',
                      ),
                      trailing: Text(
                        metric == 'credits'
                            ? '${rows[i]['credits']} cr'
                            : metric == 'kills'
                                ? '${rows[i]['kills']} kills'
                                : metric == 'warden'
                                    ? '${rows[i]['wardenRounds']}'
                                    : '${rows[i]['playtimeMinutes']} мин',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
