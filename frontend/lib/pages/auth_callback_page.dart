import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_notifier.dart';

class AuthCallbackPage extends StatefulWidget {
  final String? code;

  /// Overrides the global [authNotifier] singleton. Only meant for tests, so
  /// they can inject an [AuthNotifier] backed by a fake `ApiClient` instead
  /// of hitting the real network — mirrors the pattern `ServerStatus` uses
  /// for its own notifier.
  final AuthNotifier? notifier;

  const AuthCallbackPage({super.key, this.code, this.notifier});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _completeLogin();
  }

  Future<void> _completeLogin() async {
    final code = widget.code;
    if (code == null || code.isEmpty) {
      setState(() => _error = 'Код входа отсутствует в ссылке.');
      return;
    }

    final notifier = widget.notifier ?? authNotifier;
    try {
      await notifier.completeLogin(code);
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Не удалось завершить вход: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
