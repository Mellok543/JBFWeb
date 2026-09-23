package com.jbforsaken.web.auth;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class LoginCodeService {

    private static final Duration CODE_TTL = Duration.ofMinutes(2);

    private final LoginCodeRepository repository;
    private final Clock clock;

    @Autowired
    public LoginCodeService(LoginCodeRepository repository) {
        this(repository, Clock.systemUTC());
    }

    LoginCodeService(LoginCodeRepository repository, Clock clock) {
        this.repository = repository;
        this.clock = clock;
    }
    // @Autowired required: with two constructors, Spring won't implicitly pick
    // the 1-arg one — see the same note on IdempotencyService (Task 9).

    @Transactional
    public String issueCode(long steamId64) {
        String code = UUID.randomUUID().toString();
        Instant expiresAt = Instant.now(clock).plus(CODE_TTL);
        repository.save(new LoginCode(code, steamId64, expiresAt));
        return code;
    }

    @Transactional
    public Optional<Long> consumeCode(String code) {
        Optional<LoginCode> found = repository.findById(code);
        if (found.isEmpty()) {
            return Optional.empty();
        }

        // Atomic conditional UPDATE, not findById()+isUsable()+save(): only the
        // caller whose UPDATE actually flips a row from unused to used gets the
        // SteamID back. This closes the race where two concurrent exchanges of
        // the same code (different Idempotency-Keys) would otherwise both read
        // usedAt == null before either transaction commits.
        Instant now = Instant.now(clock);
        int updatedRows = repository.markUsedIfUnused(code, now, now);
        if (updatedRows != 1) {
            return Optional.empty();
        }

        return Optional.of(found.get().getSteamId64());
    }
}
