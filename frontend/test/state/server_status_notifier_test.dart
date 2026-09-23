import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jbforsaken_web/api/api_client.dart';
import 'package:jbforsaken_web/state/server_status_notifier.dart';

void main() {
  test('pollOnce fetches status and notifies listeners', () async {
    final fakeJson = {
      'online': true,
      'name': 'JBFORSAKEN',
      'map': 'jb_spy_vs_spy',
      'game': 'Counter-Strike 2',
      'players': 18,
      'maxPlayers': 32,
      'pingMs': 24,
      'mapTimeSeconds': 300,
      'lastUpdateUtc': DateTime.now().toIso8601String(),
      'connectAddress': '185.154.195.198:27015',
    };
    final mockClient = MockClient((request) async => http.Response(jsonEncode(fakeJson), 200));
    final notifier = ServerStatusNotifier(client: ApiClient(client: mockClient));

    var notified = false;
    notifier.addListener(() => notified = true);

    await notifier.pollOnce();

    expect(notified, isTrue);
    expect(notifier.status?.online, isTrue);
    expect(notifier.status?.map, 'jb_spy_vs_spy');
    expect(notifier.error, isNull);
  });

  test('pollOnce records an error message when the request fails', () async {
    final mockClient = MockClient((request) async => http.Response('server error', 500));
    final notifier = ServerStatusNotifier(client: ApiClient(client: mockClient));

    await notifier.pollOnce();

    expect(notifier.error, isNotNull);
    expect(notifier.status, isNull);
  });
}
