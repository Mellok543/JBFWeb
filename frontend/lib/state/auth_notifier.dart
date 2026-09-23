import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/auth_api.dart';

const String _tokenPrefsKey = 'jbf_auth_token';

class AuthNotifier extends ChangeNotifier {
  final ApiClient _client;

  AuthUser? user;
  bool isLoading = false;

  AuthNotifier({ApiClient? client}) : _client = client ?? apiClient;

  Future<void> loadStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenPrefsKey);
    if (token != null) {
      currentAuthToken = token;
      await _fetchMeAndUpdate();
    }
  }

  Future<void> completeLogin(String code) async {
    final result = await exchangeCode(_client, code);
    currentAuthToken = result.token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenPrefsKey, result.token);

    await _fetchMeAndUpdate();
  }

  Future<void> logout() async {
    currentAuthToken = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenPrefsKey);
    notifyListeners();
  }

  Future<void> _fetchMeAndUpdate() async {
    isLoading = true;
    notifyListeners();
    try {
      user = await fetchMe(_client);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final authNotifier = AuthNotifier();
