import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'router.dart';
import 'state/auth_notifier.dart';
import 'theme/jbf_theme.dart';

void main() {
  // Path-based URLs (not flutter's default hash routing) are required so the
  // backend's Steam callback redirect (`/auth-callback?code=...`) is actually
  // routed by go_router instead of falling through to HomePage. Not
  // meaningfully unit-testable: this is a platform browser API call, not
  // something flutter_test's in-memory environment exercises.
  // Deploy note: static hosting needs an SPA fallback (serve index.html for
  // any path) or a hard refresh on e.g. /rules will 404.
  usePathUrlStrategy();
  authNotifier.loadStoredToken().catchError((_) {});
  runApp(const JbForsakenApp());
}

class JbForsakenApp extends StatelessWidget {
  const JbForsakenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JBFORSAKEN',
      theme: jbfTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
