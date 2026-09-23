package com.jbforsaken.web.auth;

import java.time.Instant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface LoginCodeRepository extends JpaRepository<LoginCode, String> {

    // Atomic single-use guarantee: only succeeds (returns 1) for the caller
    // that wins the conditional UPDATE. A plain findById()-then-save() would
    // let two concurrent exchanges of the same code (different
    // Idempotency-Keys) both observe usedAt == null before either commits.
    @Modifying
    @Query("UPDATE LoginCode c SET c.usedAt = :usedAt WHERE c.code = :code AND c.usedAt IS NULL AND c.expiresAt > :now")
    int markUsedIfUnused(@Param("code") String code, @Param("usedAt") Instant usedAt, @Param("now") Instant now);
}
