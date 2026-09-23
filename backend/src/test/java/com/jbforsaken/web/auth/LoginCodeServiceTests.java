package com.jbforsaken.web.auth;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

@DataJpaTest
@ActiveProfiles("test")
class LoginCodeServiceTests {

    @Autowired
    private LoginCodeRepository repository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    void issueThenConsume_returnsTheSteamId() {
        LoginCodeService service = new LoginCodeService(repository);
        String code = service.issueCode(76561198000000000L);

        Optional<Long> result = service.consumeCode(code);

        assertThat(result).contains(76561198000000000L);
    }

    @Test
    void consumingTwice_secondCallReturnsEmpty() {
        LoginCodeService service = new LoginCodeService(repository);
        String code = service.issueCode(1L);
        service.consumeCode(code);

        // Force the first consumeCode's write to leave the persistence context
        // and reload from scratch, so the second call is proven against the
        // actually-persisted row rather than a first-level-cache-managed
        // entity that happens to still be sitting in memory from the first call.
        entityManager.flush();
        entityManager.clear();

        Optional<Long> result = service.consumeCode(code);

        assertThat(result).isEmpty();
    }

    @Test
    void consumingExpiredCode_returnsEmpty() {
        Clock pastClock = Clock.fixed(Instant.parse("2026-01-01T00:00:00Z"), ZoneOffset.UTC);
        String code = new LoginCodeService(repository, pastClock).issueCode(1L);

        Clock laterClock = Clock.fixed(Instant.parse("2026-01-01T00:10:00Z"), ZoneOffset.UTC);
        Optional<Long> result = new LoginCodeService(repository, laterClock).consumeCode(code);

        assertThat(result).isEmpty();
    }

    @Test
    void consumingUnknownCode_returnsEmpty() {
        LoginCodeService service = new LoginCodeService(repository);

        Optional<Long> result = service.consumeCode("does-not-exist");

        assertThat(result).isEmpty();
    }
}
