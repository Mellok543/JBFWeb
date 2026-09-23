package com.jbforsaken.web.monitoring;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/server")
public class ServerController {

    private final ServerSnapshotStore store;
    private final ServerMonitorProperties serverProperties;

    public ServerController(ServerSnapshotStore store, ServerMonitorProperties serverProperties) {
        this.store = store;
        this.serverProperties = serverProperties;
    }

    @GetMapping("/status")
    public ServerStatusDto getStatus() {
        ServerSnapshot snapshot = store.get();
        Integer mapTimeSeconds = snapshot.mapSinceUtc() != null
            ? (int) Duration.between(snapshot.mapSinceUtc(), Instant.now()).getSeconds()
            : null;

        return new ServerStatusDto(
            snapshot.online(),
            snapshot.name(),
            snapshot.map(),
            snapshot.game(),
            snapshot.players(),
            snapshot.maxPlayers(),
            snapshot.pingMs(),
            mapTimeSeconds,
            snapshot.lastUpdateUtc(),
            serverProperties.getHost() + ":" + serverProperties.getPort());
    }

    @GetMapping("/players")
    public List<ServerPlayerDto> getPlayers() {
        return store.get().playerList().stream()
            .map(p -> new ServerPlayerDto(p.name(), p.score(), (int) p.durationSeconds()))
            .toList();
    }
}
