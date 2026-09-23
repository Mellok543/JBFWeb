package com.jbforsaken.web.user;

import java.time.Clock;
import java.time.Instant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private final WebUserRepository repository;
    private final Clock clock;

    @Autowired
    public UserService(WebUserRepository repository) {
        this(repository, Clock.systemUTC());
    }

    UserService(WebUserRepository repository, Clock clock) {
        this.repository = repository;
        this.clock = clock;
    }

    @Transactional
    public WebUser upsertFromSteamLogin(long steamId64, String nickname, String avatarUrl) {
        Instant now = Instant.now(clock);

        return repository.findById(steamId64)
            .map(existing -> {
                existing.recordLogin(nickname, avatarUrl, now);
                return existing;
            })
            .orElseGet(() -> repository.save(new WebUser(steamId64, nickname, avatarUrl, now)));
    }
}
