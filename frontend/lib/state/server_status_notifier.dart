import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/server_api.dart';

class ServerStatusNotifier extends ChangeNotifier {
  final ApiClient _client;
  final Duration interval;
  Timer? _timer;

  ServerStatusResponse? status;
  String? error;

  ServerStatusNotifier({ApiClient? client, this.interval = const Duration(seconds: 15)})
      : _client = client ?? apiClient;

  void start() {
    pollOnce();
    _timer = Timer.periodic(interval, (_) => pollOnce());
  }

  Future<void> pollOnce() async {
    try {
      final result = await fetchServerStatus(_client);
      status = result;
      error = null;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
