import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import '../state/auth_notifier.dart';
import '../theme/jbf_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  static const _nav = <(String, String)>[
    ('Играть', '/play'),
    ('Магазин', '/store'),
    ('Пропуск', '/battlepass'),
    ('Кланы', '/clans'),
    ('Топы', '/stats'),
    ('Правила', '/rules'),
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      backgroundColor: JbfColors.bg0,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(wide ? 76 : 68),
        child: Container(
          decoration: const BoxDecoration(
            color: JbfColors.bg0,
            border: Border(bottom: BorderSide(color: JbfColors.border)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: wide ? 36 : 16),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => context.go('/'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.ac_unit_rounded, color: JbfColors.accentCyan, size: 22),
                          SizedBox(width: 10),
                          Text('JBF', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          Text('ORSAKEN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: JbfColors.accentLime)),
                        ],
                      ),
                    ),
                  ),
                  if (wide) ...[
                    const SizedBox(width: 34),
                    for (final item in _nav)
                      _NavButton(
                        label: item.$1,
                        selected: path == item.$2,
                        onTap: () => context.go(item.$2),
                      ),
                  ] else ...[
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      tooltip: 'Навигация',
                      color: JbfColors.panel1,
                      icon: const Icon(Icons.menu_rounded, color: JbfColors.textPrimary),
                      onSelected: context.go,
                      itemBuilder: (_) => [
                        for (final item in _nav) PopupMenuItem(value: item.$2, child: Text(item.$1)),
                      ],
                    ),
                  ],
                  const Spacer(),
                  ListenableBuilder(
                    listenable: authNotifier,
                    builder: (context, _) {
                      final user = authNotifier.user;
                      if (user == null) {
                        return FilledButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse('$apiBaseUrl/api/auth/steam/login'),
                            webOnlyWindowName: '_self',
                          ),
                          icon: const Icon(Icons.login_rounded, size: 18),
                          label: Text(wide ? 'ВОЙТИ ЧЕРЕЗ STEAM' : 'STEAM'),
                        );
                      }
                      return PopupMenuButton<String>(
                        color: JbfColors.panel1,
                        onSelected: (value) {
                          if (value == 'profile') context.go('/profile');
                          if (value == 'logout') authNotifier.logout();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'profile', child: Text('Профиль')),
                          PopupMenuItem(value: 'logout', child: Text('Выйти')),
                        ],
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: JbfColors.panel2,
                              backgroundImage: user.avatarUrl == null ? null : NetworkImage(user.avatarUrl!),
                              child: user.avatarUrl == null ? const Icon(Icons.person_rounded, size: 18) : null,
                            ),
                            if (wide) ...[
                              const SizedBox(width: 10),
                              Text(user.nickname ?? user.steamId64, style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                            const SizedBox(width: 6),
                            const Icon(Icons.expand_more_rounded, size: 18),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: JbfColors.bg1,
          border: Border(top: BorderSide(color: JbfColors.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: const Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 8,
          children: [
            Text('JBFORSAKEN © 2026', style: TextStyle(color: JbfColors.textMuted, fontSize: 12)),
            Text('CS2 Jailbreak • Community project', style: TextStyle(color: JbfColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected ? JbfColors.accentLime : JbfColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      ),
      child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w900 : FontWeight.w700)),
    );
  }
}
