import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/auth_callback_page.dart';
import 'pages/admin_page.dart';
import 'pages/battlepass_page.dart';
import 'pages/clans_page.dart';
import 'pages/home_page.dart';
import 'pages/play_page.dart';
import 'pages/profile_page.dart';
import 'pages/rules_page.dart';
import 'pages/stats_page.dart';
import 'pages/store_page.dart';
import 'widgets/main_layout.dart';

final GoRouter router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(path: '/play', builder: (context, state) => const PlayPage()),
        GoRoute(path: '/store', builder: (context, state) => const StorePage()),
        GoRoute(path: '/battlepass', builder: (context, state) => const BattlepassPage()),
        GoRoute(path: '/clans', builder: (context, state) => const ClansPage()),
        GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
        GoRoute(path: '/rules', builder: (context, state) => const RulesPage()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
        GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
      ],
    ),
    GoRoute(
      path: '/auth-callback',
      builder: (context, state) => AuthCallbackPage(code: state.uri.queryParameters['code']),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Страница не найдена: ${state.uri.path}')),
  ),
);
