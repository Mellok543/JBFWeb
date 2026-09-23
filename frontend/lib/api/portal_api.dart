import 'api_client.dart';

Future<List<Map<String, dynamic>>> fetchNews(ApiClient client) async {
  final raw = await client.getList('/api/news');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<List<Map<String, dynamic>>> fetchStoreProducts(ApiClient client) async {
  final raw = await client.getList('/api/store/products');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<Map<String, dynamic>> createStoreOrder(ApiClient client, String productCode) {
  return client.post('/api/store/orders', body: {'productCode': productCode});
}

Future<List<Map<String, dynamic>>> fetchMyOrders(ApiClient client) async {
  final raw = await client.getList('/api/store/orders');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<Map<String, dynamic>> fetchBattlePass(ApiClient client) {
  return client.get('/api/battlepass/current');
}

Future<List<Map<String, dynamic>>> fetchClans(ApiClient client) async {
  final raw = await client.getList('/api/clans');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<Map<String, dynamic>> createClan(ApiClient client, String name, String tag) {
  return client.post('/api/clans', body: {'name': name, 'tag': tag});
}

Future<List<Map<String, dynamic>>> fetchTopStats(ApiClient client, {String metric = 'playtime'}) async {
  final raw = await client.getList('/api/stats/top?metric=$metric');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<Map<String, dynamic>> fetchMyStats(ApiClient client) {
  return client.get('/api/stats/me');
}


Future<List<Map<String, dynamic>>> fetchRules(ApiClient client) async {
  final raw = await client.getList('/api/rules');
  return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}
