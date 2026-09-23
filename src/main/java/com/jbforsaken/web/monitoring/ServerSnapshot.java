package com.jbforsaken.web.monitoring;

import java.time.Instant;
import java.util.List;

public record ServerSnapshot(
    boolean online,
    String name,
    String map,
    String game,
    int players,
    int maxPlayers,
    int pingMs,
    Instant lastUpdateUtc,
    Instant mapSinceUtc,
    List<A2sPlayerInfo> playerList) {

    public static ServerSnapshot offline(Instant lastUpdateUtc) {
        return new ServerSnapshot(false, null, null, null, 0, 0, 0, lastUpdateUtc, null, List.of());
    }
}
