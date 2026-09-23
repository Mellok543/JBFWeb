import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import '../state/auth_notifier.dart';
import '../theme/jbf_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          color: JbfColors.bg0,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/'),
                child: Row(
                  children: const [
                    Text('JB', style: TextStyle(fontWeight: FontWeight.bold, color: JbfColors.textPrimary)),
                    Text('FORSAKEN', style: TextStyle(fontWeight: FontWeight.bold, color: JbfColors.accentLime)),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Главная', style: TextStyle(color: JbfColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => context.go('/rules'),
                child: const Text('Правила', style: TextStyle(color: JbfColors.textSecondary)),
              ),
              const Spacer(),
              ListenableBuilder(
                listenable: authNotifier,
                builder: (context, _) {
                  final user = authNotifier.user;
                  if (user == null) {
                    return TextButton(
                      onPressed: () => launchUrl(
                        Uri.parse('$apiBaseUrl/api/auth/steam/login'),
                        webOnlyWindowName: '_self',
                      ),
                      child: const Text('ВОЙТИ ЧЕРЕЗ STEAM', style: TextStyle(color: JbfColors.accentLime)),
                    );
                  }
                  return Row(
                    children: [
                      Text(user.nickname ?? user.steamId64, style: const TextStyle(color: JbfColors.textPrimary)),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => authNotifier.logout(),
                        child: const Text('Выйти', style: TextStyle(color: JbfColors.textSecondary)),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
