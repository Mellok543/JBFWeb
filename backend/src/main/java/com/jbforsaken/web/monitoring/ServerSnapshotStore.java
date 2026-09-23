package com.jbforsaken.web.monitoring;

import java.time.Instant;
import java.util.concurrent.atomic.AtomicReference;
import org.springframework.stereotype.Component;

@Component
public class ServerSnapshotStore {

    private final AtomicReference<ServerSnapshot> current =
        new AtomicReference<>(ServerSnapshot.offline(Instant.EPOCH));

    public ServerSnapshot get() {
        return current.get();
    }

    public void set(ServerSnapshot snapshot) {
        current.set(snapshot);
    }
}
