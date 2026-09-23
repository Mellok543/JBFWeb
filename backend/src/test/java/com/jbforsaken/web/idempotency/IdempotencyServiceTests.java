package com.jbforsaken.web.idempotency;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

@DataJpaTest
@ActiveProfiles("test")
class IdempotencyServiceTests {

    @Autowired
    private IdempotencyKeyRepository repository;

    @Test
    void reserve_firstCall_returnsReserved() {
        IdempotencyService service = new IdempotencyService(repository);

        var result = service.reserve("key-1", "fingerprint-a");

        assertThat(result.outcome()).isEqualTo(IdempotencyService.ReservationOutcome.RESERVED);
    }

    @Test
    void reserve_secondCallBeforeCompletion_returnsInProgress() {
        IdempotencyService service = new IdempotencyService(repository);
        service.reserve("key-2", "fingerprint-a");

        var result = service.reserve("key-2", "fingerprint-a");

        assertThat(result.outcome()).isEqualTo(IdempotencyService.ReservationOutcome.IN_PROGRESS);
    }

    @Test
    void reserve_afterCompletion_replaysStoredResponse() {
        IdempotencyService service = new IdempotencyService(repository);
        service.reserve("key-3", "fingerprint-a");
        service.complete("key-3", 200, "{\"ok\":true}");

        var result = service.reserve("key-3", "fingerprint-a");

        assertThat(result.outcome()).isEqualTo(IdempotencyService.ReservationOutcome.REPLAY);
        assertThat(result.responseStatus()).isEqualTo(200);
        assertThat(result.responseBody()).isEqualTo("{\"ok\":true}");
    }

    @Test
    void reserve_sameKeyDifferentFingerprint_returnsConflict() {
        IdempotencyService service = new IdempotencyService(repository);
        service.reserve("key-4", "fingerprint-a");

        var result = service.reserve("key-4", "fingerprint-b");

        assertThat(result.outcome()).isEqualTo(IdempotencyService.ReservationOutcome.CONFLICT);
    }
}
