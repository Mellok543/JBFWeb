import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/auth_callback_page.dart';
import 'pages/home_page.dart';
import 'pages/rules_page.dart';
import 'widgets/main_layout.dart';

final GoRouter router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(path: '/rules', builder: (context, state) => const RulesPage()),
      ],
    ),
    GoRoute(
      path: '/auth-callback',
      builder: (context, state) => AuthCallbackPage(code: state.uri.queryParameters['code']),
    ),
  ],
);
