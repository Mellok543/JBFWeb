package com.jbforsaken.web.idempotency;

import java.time.Clock;
import java.time.Instant;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class IdempotencyService {

    public enum ReservationOutcome { RESERVED, REPLAY, IN_PROGRESS, CONFLICT }

    public record ReservationResult(ReservationOutcome outcome, Integer responseStatus, String responseBody) {
    }

    private final IdempotencyKeyRepository repository;
    private final Clock clock;

    @Autowired
    public IdempotencyService(IdempotencyKeyRepository repository) {
        this(repository, Clock.systemUTC());
    }

    IdempotencyService(IdempotencyKeyRepository repository, Clock clock) {
        this.repository = repository;
        this.clock = clock;
    }
    // @Autowired is required here, not optional: with two constructors present,
    // Spring's implicit single-constructor autowiring doesn't apply, and without
    // an explicit choice it can resolve the wider (repository, Clock) constructor
    // instead — Clock isn't a registered bean, so the full application context
    // fails to start. Task 4's UserService hit exactly this; same fix here.

    @Transactional
    public ReservationResult reserve(String key, String fingerprint) {
        Optional<IdempotencyKey> existing = repository.findById(key);
        if (existing.isPresent()) {
            IdempotencyKey found = existing.get();
            if (!found.getRequestFingerprint().equals(fingerprint)) {
                return new ReservationResult(ReservationOutcome.CONFLICT, null, null);
            }
            if (found.isCompleted()) {
                return new ReservationResult(ReservationOutcome.REPLAY, found.getResponseStatus(), found.getResponseBody());
            }
            return new ReservationResult(ReservationOutcome.IN_PROGRESS, null, null);
        }

        try {
            repository.saveAndFlush(new IdempotencyKey(key, fingerprint, Instant.now(clock)));
            return new ReservationResult(ReservationOutcome.RESERVED, null, null);
        } catch (DataIntegrityViolationException raceLost) {
            // Another concurrent request won the insert race between our findById and save —
            // known limitation: a third concurrent request in the same narrow window could see
            // this as IN_PROGRESS too, which is the correct, safe outcome (never a double RESERVED).
            return new ReservationResult(ReservationOutcome.IN_PROGRESS, null, null);
        }
    }

    @Transactional
    public void complete(String key, int status, String body) {
        repository.findById(key).ifPresent(found -> found.complete(status, body));
    }
}
