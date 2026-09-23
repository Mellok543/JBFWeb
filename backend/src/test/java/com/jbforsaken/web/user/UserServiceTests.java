package com.jbforsaken.web.user;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

@DataJpaTest
@ActiveProfiles("test")
class UserServiceTests {

    @Autowired
    private WebUserRepository repository;

    @Test
    void upsertFromSteamLogin_createsNewUserOnFirstLogin() {
        Clock fixedClock = Clock.fixed(Instant.parse("2026-09-22T10:00:00Z"), ZoneOffset.UTC);
        UserService service = new UserService(repository, fixedClock);

        WebUser user = service.upsertFromSteamLogin(76561198000000000L, "Mell", "https://avatar");

        assertThat(user.getSteamId64()).isEqualTo(76561198000000000L);
        assertThat(user.getNickname()).isEqualTo("Mell");
        assertThat(user.getFirstLoginAt()).isEqualTo(Instant.parse("2026-09-22T10:00:00Z"));
        assertThat(repository.findById(76561198000000000L)).isPresent();
    }

    @Test
    void upsertFromSteamLogin_updatesNicknameOnSecondLoginKeepingFirstLoginAt() {
        Clock firstClock = Clock.fixed(Instant.parse("2026-09-22T10:00:00Z"), ZoneOffset.UTC);
        new UserService(repository, firstClock).upsertFromSteamLogin(1L, "OldName", null);

        Clock secondClock = Clock.fixed(Instant.parse("2026-09-22T11:00:00Z"), ZoneOffset.UTC);
        WebUser updated = new UserService(repository, secondClock).upsertFromSteamLogin(1L, "NewName", "https://avatar2");

        assertThat(updated.getNickname()).isEqualTo("NewName");
        assertThat(updated.getFirstLoginAt()).isEqualTo(Instant.parse("2026-09-22T10:00:00Z"));
        assertThat(updated.getLastLoginAt()).isEqualTo(Instant.parse("2026-09-22T11:00:00Z"));
        assertThat(repository.count()).isEqualTo(1);
    }
}
