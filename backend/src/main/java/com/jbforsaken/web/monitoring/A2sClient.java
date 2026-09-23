package com.jbforsaken.web.monitoring;

import java.util.List;
import java.util.Optional;

public interface A2sClient {

    Optional<A2sInfoResult> queryInfo(String host, int port);

    List<A2sPlayerInfo> queryPlayers(String host, int port);
}
