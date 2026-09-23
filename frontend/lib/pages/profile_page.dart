import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/portal_api.dart';
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                            Text(user.steamId64, style: const TextStyle(color: JbfColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<Map<String, dynamic>>(
                  future: fetchMyStats(apiClient),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                      return const InfoStrip(
                        icon: Icons.query_stats_rounded,
                        title: 'Игровая статистика ещё не синхронизирована',
                        text: 'После подключения игровых плагинов здесь появятся время, убийства, кредиты и раунды командира.',
                      );
                    }
                    final stats = snapshot.data!;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        FeatureCard(
                          icon: Icons.schedule_rounded,
                          title: '${stats['playtimeMinutes']} мин',
                          text: 'Игровое время',
                        ),
                        FeatureCard(
                          icon: Icons.gps_fixed_rounded,
                          title: '${stats['kills']} / ${stats['deaths']}',
                          text: 'Убийства / смерти',
                          accent: JbfColors.accentLime,
                        ),
                        FeatureCard(
                          icon: Icons.account_balance_wallet_outlined,
                          title: '${stats['credits']} cr',
                          text: 'Баланс кредитов',
                          accent: JbfColors.accentPurple,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                Text('Последние заказы', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchMyOrders(apiClient),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final orders = snapshot.data ?? const [];
                    if (snapshot.hasError || orders.isEmpty) {
                      return const InfoStrip(
                        icon: Icons.receipt_long_outlined,
                        title: 'Заказов пока нет',
                        text: 'История покупок появится здесь после первого заказа.',
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
                          for (final order in orders)
                            ListTile(
                              leading: const Icon(Icons.receipt_outlined),
                              title: Text(order['productCode'].toString()),
                              subtitle: Text(order['status'].toString()),
                              trailing: Text('${((order['amountCents'] as num) / 100).toStringAsFixed(0)} ₽'),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
