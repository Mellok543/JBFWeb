import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../api/api_client.dart';
import '../api/portal_api.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';
import '../widgets/server_status.dart';

const String _discordUrl = String.fromEnvironment('DISCORD_URL');
const String _telegramUrl = String.fromEnvironment('TELEGRAM_URL');

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 760;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(narrow ? 18 : 36, 48, narrow ? 18 : 36, 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hero(narrow: narrow),
              const SizedBox(height: 26),
              const ServerStatus(),
              const SizedBox(height: 56),
              const _SectionHeading(
                eyebrow: 'НОВОСТИ',
                title: 'Последние обновления',
                subtitle: 'Новости загружаются напрямую из Spring backend.',
              ),
              const SizedBox(height: 20),
              const _NewsSection(),
              const SizedBox(height: 56),
              const _SectionHeading(
                eyebrow: 'JBFORSAKEN',
                title: 'Экосистема сервера',
                subtitle: 'Сайт становится частью сервера: профиль, прогресс, магазин, пропуск, рейтинги и кланы.',
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  FeatureCard(
                    icon: Icons.storefront_outlined,
                    title: 'Магазин',
                    text: 'Привилегии, кредиты и косметические предметы.',
                    accent: JbfColors.accentLime,
                    footer: TextButton(
                      onPressed: () => context.go('/store'),
                      child: const Text('ОТКРЫТЬ →'),
                    ),
                  ),
                  FeatureCard(
                    icon: Icons.verified_outlined,
                    title: 'Battle Pass',
                    text: 'Сезонные задания, уровни и награды для Jailbreak.',
                    accent: JbfColors.accentPurple,
                    footer: TextButton(
                      onPressed: () => context.go('/battlepass'),
                      child: const Text('ПОДРОБНЕЕ →'),
                    ),
                  ),
                  FeatureCard(
                    icon: Icons.leaderboard_outlined,
                    title: 'Топы',
                    text: 'Рейтинги игроков, активность и будущие игровые рекорды.',
                    footer: TextButton(
                      onPressed: () => context.go('/stats'),
                      child: const Text('СМОТРЕТЬ →'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 56),
              const _SectionHeading(
                eyebrow: 'АКТИВНОСТЬ',
                title: 'Что происходит в проекте',
                subtitle: 'Эти блоки уже готовы под API событий и будут обновляться данными из backend.',
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth < 820
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 28) / 3;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: width,
                        child: const _FeedPanel(
                          title: 'Последние активности',
                          icon: Icons.bolt_rounded,
                          rows: [
                            ('Сайт JBFORSAKEN', 'Новая версия интерфейса'),
                            ('Steam авторизация', 'Подключена основа'),
                            ('Server Query', 'Онлайн обновляется автоматически'),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: const _FeedPanel(
                          title: 'Поддержавшие',
                          icon: Icons.favorite_outline_rounded,
                          rows: [
                            ('Магазин готовится', 'История покупок появится здесь'),
                            ('VIP / Premium', 'Подключение к игровой БД'),
                            ('Косметика', 'Инвентарь будет связан с профилем'),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: const _FeedPanel(
                          title: 'Кланы',
                          icon: Icons.groups_2_outlined,
                          rows: [
                            ('Клановый рейтинг', 'В разработке'),
                            ('Участники', 'SteamID64 как ключ аккаунта'),
                            ('Сезонные очки', 'Будут связаны с Battle Pass'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 56),
              const _SectionHeading(
                eyebrow: 'БЫСТРЫЙ ДОСТУП',
                title: 'Подключайся к сообществу',
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => launchUrl(Uri.parse('steam://connect/$connectHost:$connectPort')),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('ИГРАТЬ'),
                  ),
                  if (_discordUrl.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(_discordUrl)),
                      icon: const Icon(Icons.forum_outlined),
                      label: const Text('DISCORD'),
                    ),
                  if (_telegramUrl.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(_telegramUrl)),
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('TELEGRAM'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/rules'),
                    icon: const Icon(Icons.gavel_outlined),
                    label: const Text('ПРАВИЛА'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool narrow;
  const _Hero({required this.narrow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(narrow ? 24 : 42),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(JbfRadii.lg),
        border: Border.all(color: JbfColors.borderCyan),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1720), Color(0xFF071016), Color(0xFF0B1117)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Wrap(
        spacing: 36,
        runSpacing: 28,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: narrow ? double.infinity : 650,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CS2 • JAILBREAK • COMMUNITY',
                  style: TextStyle(
                    color: JbfColors.accentCyan,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'JBFORSAKEN',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: narrow ? 44 : 68,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Jailbreak, который развивается как полноценный проект: свои механики, события, '
                  'прогрессия, косметика и веб-кабинет игрока.',
                  style: TextStyle(
                    color: JbfColors.textSecondary,
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => launchUrl(Uri.parse('steam://connect/$connectHost:$connectPort')),
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: const Text('ПОДКЛЮЧИТЬСЯ'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/play'),
                      child: const Text('О СЕРВЕРЕ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 260,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(JbfRadii.md),
              border: Border.all(color: JbfColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.ac_unit_rounded, size: 46, color: JbfColors.accentCyan),
                SizedBox(height: 18),
                Text('FROZEN FORSAKEN', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text(
                  'Холодный визуальный стиль проекта без копирования чужого дизайна.',
                  style: TextStyle(color: JbfColors.textSecondary, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: JbfColors.accentCyan,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 7),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: const TextStyle(color: JbfColors.textSecondary)),
        ],
      ],
    );
  }
}

class _FeedPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  const _FeedPanel({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 250),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: JbfColors.panel0,
        borderRadius: BorderRadius.circular(JbfRadii.md),
        border: Border.all(color: JbfColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: JbfColors.accentLime),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 18),
          for (final row in rows) ...[
            Text(row.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(row.$2, style: const TextStyle(color: JbfColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 13),
          ],
        ],
      ),
    );
  }
}


class _NewsSection extends StatefulWidget {
  const _NewsSection();

  @override
  State<_NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<_NewsSection> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchNews(apiClient);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LinearProgressIndicator();
        }

        if (snapshot.hasError) {
          return const _FeedPanel(
            title: 'Новости временно недоступны',
            icon: Icons.cloud_off_outlined,
            rows: [('Backend', 'Остальная главная продолжает работать.')],
          );
        }

        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const _FeedPanel(
            title: 'Новостей пока нет',
            icon: Icons.article_outlined,
            rows: [('JBFORSAKEN', 'Первая публикация появится здесь.')],
          );
        }

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final item in items.take(3))
              SizedBox(
                width: 370,
                child: _FeedPanel(
                  title: item['title']?.toString() ?? 'JBFORSAKEN',
                  icon: item['pinned'] == true ? Icons.push_pin_outlined : Icons.article_outlined,
                  rows: [
                    (item['pinned'] == true ? 'Закреплено' : 'Новость', item['body']?.toString() ?? ''),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
