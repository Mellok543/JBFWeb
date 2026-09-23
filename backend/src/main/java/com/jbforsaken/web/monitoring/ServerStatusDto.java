package com.jbforsaken.web.monitoring;

import java.time.Instant;

public record ServerStatusDto(
    boolean online,
    String name,
    String map,
    String game,
    int players,
    int maxPlayers,
    int pingMs,
    Integer mapTimeSeconds,
    Instant lastUpdateUtc,
    // "host:port" from cs2-server config — static, so present even when offline.
    // Single source of truth for the frontend's "connect" button.
    String connectAddress) {
}
