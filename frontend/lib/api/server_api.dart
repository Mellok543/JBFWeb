import 'api_client.dart';

class ServerStatusResponse {
  final bool online;
  final String? name;
  final String? map;
  final String? game;
  final int players;
  final int maxPlayers;
  final int pingMs;
  final int? mapTimeSeconds;
  final String lastUpdateUtc;
  // "host:port", single source of truth for the CONNECT button's steam://
  // URI. Populated by the backend on both online and offline responses.
  final String connectAddress;

  ServerStatusResponse({
    required this.online,
    required this.name,
    required this.map,
    required this.game,
    required this.players,
    required this.maxPlayers,
    required this.pingMs,
    required this.mapTimeSeconds,
    required this.lastUpdateUtc,
    required this.connectAddress,
  });

  factory ServerStatusResponse.fromJson(Map<String, dynamic> json) => ServerStatusResponse(
        online: json['online'] as bool,
        name: json['name'] as String?,
        map: json['map'] as String?,
        game: json['game'] as String?,
        players: json['players'] as int,
        maxPlayers: json['maxPlayers'] as int,
        pingMs: json['pingMs'] as int,
        mapTimeSeconds: json['mapTimeSeconds'] as int?,
        lastUpdateUtc: json['lastUpdateUtc'] as String,
        connectAddress: json['connectAddress'] as String,
      );
}

Future<ServerStatusResponse> fetchServerStatus(ApiClient client) async {
  final json = await client.get('/api/server/status');
  return ServerStatusResponse.fromJson(json);
}
