import 'api_client.dart';

Future<bool> fetchIsAdmin(ApiClient client) async {
  try {
    final json = await client.get('/api/admin/me');
    return json['admin'] == true;
  } on ApiException catch (e) {
    if (e.statusCode == 401 || e.statusCode == 403) return false;
    rethrow;
  }
}

Future<Map<String, dynamic>> fetchAdminDashboard(ApiClient client) {
  return client.get('/api/admin/dashboard');
}

Future<List<Map<String, dynamic>>> fetchAdminUsers(ApiClient client) async {
  final raw = await client.getList('/api/admin/users');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<List<Map<String, dynamic>>> fetchAdminNews(ApiClient client) async {
  final raw = await client.getList('/api/admin/news');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<Map<String, dynamic>> createAdminNews(
  ApiClient client, {
  required String title,
  required String body,
  required bool pinned,
}) {
  return client.post('/api/admin/news', body: {
    'title': title,
    'body': body,
    'pinned': pinned,
  });
}

Future<Map<String, dynamic>> updateAdminNews(
  ApiClient client,
  int id, {
  required String title,
  required String body,
  required bool pinned,
}) {
  return client.put('/api/admin/news/$id', body: {
    'title': title,
    'body': body,
    'pinned': pinned,
  });
}

Future<void> deleteAdminNews(ApiClient client, int id) {
  return client.delete('/api/admin/news/$id');
}

Future<List<Map<String, dynamic>>> fetchAdminProducts(ApiClient client) async {
  final raw = await client.getList('/api/admin/products');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<Map<String, dynamic>> saveAdminProduct(
  ApiClient client, {
  String? existingCode,
  required String code,
  required String name,
  required String description,
  required String category,
  required int priceCents,
  required bool active,
  required int sortOrder,
}) {
  final body = {
    'code': code,
    'name': name,
    'description': description,
    'category': category,
    'priceCents': priceCents,
    'active': active,
    'sortOrder': sortOrder,
  };

  if (existingCode == null) {
    return client.post('/api/admin/products', body: body);
  }
  return client.put('/api/admin/products/$existingCode', body: body);
}

Future<void> deleteAdminProduct(ApiClient client, String code) {
  return client.delete('/api/admin/products/$code');
}

Future<List<Map<String, dynamic>>> fetchAdminOrders(ApiClient client) async {
  final raw = await client.getList('/api/admin/orders');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<Map<String, dynamic>> updateAdminOrderStatus(
  ApiClient client,
  String id,
  String status,
) {
  return client.put('/api/admin/orders/$id/status', body: {'status': status});
}

Future<List<Map<String, dynamic>>> fetchAdminClans(ApiClient client) async {
  final raw = await client.getList('/api/admin/clans');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<void> deleteAdminClan(ApiClient client, int id) {
  return client.delete('/api/admin/clans/$id');
}

Future<List<Map<String, dynamic>>> fetchAdminSeasons(ApiClient client) async {
  final raw = await client.getList('/api/admin/battlepass/seasons');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<List<Map<String, dynamic>>> fetchAdminAudit(ApiClient client) async {
  final raw = await client.getList('/api/admin/audit');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}


Future<List<Map<String, dynamic>>> fetchAdminRules(ApiClient client) async {
  final raw = await client.getList('/api/admin/rules');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<Map<String, dynamic>> saveAdminRule(
  ApiClient client, {
  int? id,
  required int sortOrder,
  required String title,
  required String body,
  required bool active,
}) {
  final payload = {
    'sortOrder': sortOrder,
    'title': title,
    'body': body,
    'active': active,
  };
  return id == null
      ? client.post('/api/admin/rules', body: payload)
      : client.put('/api/admin/rules/$id', body: payload);
}

Future<void> deleteAdminRule(ApiClient client, int id) {
  return client.delete('/api/admin/rules/$id');
}

Future<Map<String, dynamic>> createAdminSeason(
  ApiClient client, {
  required String code,
  required String name,
  required String startsAt,
  required String endsAt,
  required bool active,
}) {
  return client.post('/api/admin/battlepass/seasons', body: {
    'code': code,
    'name': name,
    'startsAt': startsAt,
    'endsAt': endsAt,
    'active': active,
  });
}

Future<Map<String, dynamic>> createAdminBattlePassLevel(
  ApiClient client,
  int seasonId, {
  required int levelNumber,
  required int xpRequired,
  required String rewardTitle,
}) {
  return client.post('/api/admin/battlepass/seasons/$seasonId/levels', body: {
    'levelNumber': levelNumber,
    'xpRequired': xpRequired,
    'rewardTitle': rewardTitle,
  });
}

Future<List<Map<String, dynamic>>> fetchAdminBattlePassLevels(ApiClient client, int seasonId) async {
  final raw = await client.getList('/api/admin/battlepass/seasons/$seasonId/levels');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}
