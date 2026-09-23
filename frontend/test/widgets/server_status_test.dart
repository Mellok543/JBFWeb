import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jbforsaken_web/api/api_client.dart';
import 'package:jbforsaken_web/api/server_api.dart';
import 'package:jbforsaken_web/state/server_status_notifier.dart';
import 'package:jbforsaken_web/widgets/server_status.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

ServerStatusNotifier _notifierWithFixedStatus(ServerStatusResponse status) {
  final mockClient = MockClient((request) async => http.Response('{}', 200));
  final notifier = ServerStatusNotifier(client: ApiClient(client: mockClient));
  notifier.status = status;
  return notifier;
}

/// Records the URLs passed to url_launcher's launchUrl without doing any
/// real platform navigation, so the CONNECT button's steam:// URI can be
/// asserted on directly.
class _FakeUrlLauncher extends UrlLauncherPlatform {
  final List<String> launchedUrls = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }
}

void main() {
  testWidgets('shows online details when the server responds', (tester) async {
    final notifier = _notifierWithFixedStatus(ServerStatusResponse(
      online: true,
      name: 'JBFORSAKEN',
      map: 'jb_spy_vs_spy',
      game: 'Counter-Strike 2',
      players: 18,
      maxPlayers: 32,
      pingMs: 24,
      mapTimeSeconds: 300,
      lastUpdateUtc: DateTime.now().toIso8601String(),
      connectAddress: '185.154.195.198:27015',
    ));

    await tester.pumpWidget(MaterialApp(home: ServerStatus(notifier: notifier)));
    notifier.notifyListeners();
    await tester.pump();

    expect(find.text('ONLINE'), findsOneWidget);
    expect(find.text('jb_spy_vs_spy'), findsOneWidget);
    expect(find.text('18 / 32'), findsOneWidget);
    expect(find.text('24 ms'), findsOneWidget);
  });

  testWidgets('CONNECT button uses the backend-sourced connectAddress, not a hardcoded value', (tester) async {
    final fakeLauncher = _FakeUrlLauncher();
    final originalLauncher = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = fakeLauncher;
    addTearDown(() => UrlLauncherPlatform.instance = originalLauncher);

    final notifier = _notifierWithFixedStatus(ServerStatusResponse(
      online: true,
      name: 'JBFORSAKEN',
      map: 'jb_spy_vs_spy',
      game: 'Counter-Strike 2',
      players: 18,
      maxPlayers: 32,
      pingMs: 24,
      mapTimeSeconds: 300,
      lastUpdateUtc: DateTime.now().toIso8601String(),
      connectAddress: '203.0.113.42:27099',
    ));

    await tester.pumpWidget(MaterialApp(home: ServerStatus(notifier: notifier)));
    notifier.notifyListeners();
    await tester.pump();

    await tester.tap(find.text('CONNECT'));
    await tester.pump();

    expect(fakeLauncher.launchedUrls, ['steam://connect/203.0.113.42:27099']);
  });

  testWidgets('shows an offline state when the server is unreachable', (tester) async {
    final notifier = _notifierWithFixedStatus(ServerStatusResponse(
      online: false,
      name: null,
      map: null,
      game: null,
      players: 0,
      maxPlayers: 0,
      pingMs: 0,
      mapTimeSeconds: null,
      lastUpdateUtc: DateTime.now().toIso8601String(),
      connectAddress: '185.154.195.198:27015',
    ));

    await tester.pumpWidget(MaterialApp(home: ServerStatus(notifier: notifier)));
    notifier.notifyListeners();
    await tester.pump();

    expect(find.text('OFFLINE'), findsOneWidget);
  });

  testWidgets('shows an error state when polling fails and no status has ever loaded', (tester) async {
    final mockClient = MockClient((request) async => http.Response('{}', 200));
    final notifier = ServerStatusNotifier(client: ApiClient(client: mockClient));
    notifier.error = 'ApiException(500): server error';

    await tester.pumpWidget(MaterialApp(home: ServerStatus(notifier: notifier)));
    notifier.notifyListeners();
    await tester.pump();

    expect(find.text('Не удалось загрузить статус сервера'), findsOneWidget);
    expect(find.textContaining('ApiException(500): server error'), findsOneWidget);
    expect(find.text('Загрузка статуса сервера…'), findsNothing);
  });
}
