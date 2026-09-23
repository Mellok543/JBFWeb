package com.jbforsaken.web.monitoring;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class ServerMonitorSchedulerTests {

    private static final class StubA2sClient implements A2sClient {
        private Optional<A2sInfoResult> infoToReturn = Optional.empty();
        private List<A2sPlayerInfo> playersToReturn = List.of();

        void setInfoToReturn(Optional<A2sInfoResult> value) {
            this.infoToReturn = value;
        }

        void setPlayersToReturn(List<A2sPlayerInfo> value) {
            this.playersToReturn = value;
        }

        @Override
        public Optional<A2sInfoResult> queryInfo(String host, int port) {
            return infoToReturn;
        }

        @Override
        public List<A2sPlayerInfo> queryPlayers(String host, int port) {
            return playersToReturn;
        }
    }

    private static ServerMonitorProperties properties() {
        ServerMonitorProperties properties = new ServerMonitorProperties();
        properties.setHost("127.0.0.1");
        properties.setPort(27015);
        properties.setPollIntervalSeconds(12);
        return properties;
    }

    @Test
    void pollOnce_whenServerResponds_storesOnlineSnapshot() {
        StubA2sClient client = new StubA2sClient();
        client.setInfoToReturn(Optional.of(new A2sInfoResult("Test Server", "jb_test", "csgo", "Counter-Strike 2", 4, 32)));
        client.setPlayersToReturn(List.of(new A2sPlayerInfo("Alice", 10, 120f)));
        ServerSnapshotStore store = new ServerSnapshotStore();
        ServerMonitorScheduler scheduler = new ServerMonitorScheduler(client, store, properties());

        scheduler.pollOnce();

        ServerSnapshot snapshot = store.get();
        assertThat(snapshot.online()).isTrue();
        assertThat(snapshot.name()).isEqualTo("Test Server");
        assertThat(snapshot.map()).isEqualTo("jb_test");
        assertThat(snapshot.players()).isEqualTo(4);
        assertThat(snapshot.playerList()).hasSize(1);
    }

    @Test
    void pollOnce_whenServerUnreachable_storesOfflineSnapshotWithLastUpdate() {
        StubA2sClient client = new StubA2sClient();
        ServerSnapshotStore store = new ServerSnapshotStore();
        ServerMonitorScheduler scheduler = new ServerMonitorScheduler(client, store, properties());

        scheduler.pollOnce();

        ServerSnapshot snapshot = store.get();
        assertThat(snapshot.online()).isFalse();
        assertThat(snapshot.name()).isNull();
        assertThat(snapshot.lastUpdateUtc()).isNotNull();
    }

    @Test
    void pollOnce_whenMapChanges_resetsMapSinceTimestamp() throws InterruptedException {
        StubA2sClient client = new StubA2sClient();
        client.setInfoToReturn(Optional.of(new A2sInfoResult("Test Server", "jb_map_one", "csgo", "Counter-Strike 2", 1, 32)));
        ServerSnapshotStore store = new ServerSnapshotStore();
        ServerMonitorScheduler scheduler = new ServerMonitorScheduler(client, store, properties());

        scheduler.pollOnce();
        var firstMapSince = store.get().mapSinceUtc();

        // Ensure the wall clock visibly advances between polls: on some platforms
        // (observed on Windows) back-to-back Instant.now() calls can otherwise
        // resolve to the exact same instant due to coarse clock granularity.
        Thread.sleep(10);

        client.setInfoToReturn(Optional.of(new A2sInfoResult("Test Server", "jb_map_two", "csgo", "Counter-Strike 2", 1, 32)));
        scheduler.pollOnce();
        var secondMapSince = store.get().mapSinceUtc();

        assertThat(secondMapSince).isNotEqualTo(firstMapSince);
    }

    @Test
    void pollOnce_whenMapUnchanged_keepsMapSinceTimestamp() {
        StubA2sClient client = new StubA2sClient();
        client.setInfoToReturn(Optional.of(new A2sInfoResult("Test Server", "jb_same_map", "csgo", "Counter-Strike 2", 1, 32)));
        ServerSnapshotStore store = new ServerSnapshotStore();
        ServerMonitorScheduler scheduler = new ServerMonitorScheduler(client, store, properties());

        scheduler.pollOnce();
        var firstMapSince = store.get().mapSinceUtc();

        scheduler.pollOnce();
        var secondMapSince = store.get().mapSinceUtc();

        assertThat(secondMapSince).isEqualTo(firstMapSince);
    }
}
