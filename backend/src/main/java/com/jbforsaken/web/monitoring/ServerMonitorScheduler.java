package com.jbforsaken.web.monitoring;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class ServerMonitorScheduler {

    private static final Logger log = LoggerFactory.getLogger(ServerMonitorScheduler.class);

    private final A2sClient client;
    private final ServerSnapshotStore store;
    private final ServerMonitorProperties properties;

    public ServerMonitorScheduler(A2sClient client, ServerSnapshotStore store, ServerMonitorProperties properties) {
        this.client = client;
        this.store = store;
        this.properties = properties;
    }

    @Scheduled(fixedDelayString = "#{${cs2-server.poll-interval-seconds:12} * 1000}", initialDelay = 0)
    public void pollOnce() {
        long startNanos = System.nanoTime();
        Optional<A2sInfoResult> info = client.queryInfo(properties.getHost(), properties.getPort());
        int pingMs = (int) ((System.nanoTime() - startNanos) / 1_000_000);

        Instant now = Instant.now();

        if (info.isEmpty()) {
            log.warn("A2S query to {}:{} failed or timed out", properties.getHost(), properties.getPort());
            store.set(ServerSnapshot.offline(now));
            return;
        }

        List<A2sPlayerInfo> players = client.queryPlayers(properties.getHost(), properties.getPort());

        ServerSnapshot previous = store.get();
        A2sInfoResult result = info.get();
        Instant mapSince = previous.online() && result.map().equals(previous.map())
            ? previous.mapSinceUtc()
            : now;

        store.set(new ServerSnapshot(
            true,
            result.name(),
            result.map(),
            result.game(),
            result.players(),
            result.maxPlayers(),
            pingMs,
            now,
            mapSince,
            players));
    }
}
