package com.jbforsaken.web.auth;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Instant;
import java.util.Date;
import java.util.Optional;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class JwtService {

    public record IssuedToken(String token, Instant expiresAt) {
    }

    private final SecretKey key;
    private final java.time.Duration expiry;
    private final Clock clock;

    @Autowired
    public JwtService(JwtProperties properties) {
        this(properties, Clock.systemUTC());
    }

    JwtService(JwtProperties properties, Clock clock) {
        this.key = Keys.hmacShaKeyFor(properties.getSecret().getBytes(StandardCharsets.UTF_8));
        this.expiry = java.time.Duration.ofMinutes(properties.getExpirationMinutes());
        this.clock = clock;
    }
    // @Autowired required: with two constructors, Spring won't implicitly pick
    // the 1-arg one — see the same note on IdempotencyService (Task 9).

    public IssuedToken issue(long steamId64) {
        Instant now = Instant.now(clock);
        Instant expiresAt = now.plus(expiry);

        String token = Jwts.builder()
            .subject(Long.toString(steamId64))
            .issuedAt(Date.from(now))
            .expiration(Date.from(expiresAt))
            .signWith(key)
            .compact();

        return new IssuedToken(token, expiresAt);
    }

    public Optional<Long> parse(String token) {
        try {
            Claims claims = Jwts.parser()
                .verifyWith(key)
                .clock(() -> Date.from(Instant.now(clock)))
                .build()
                .parseSignedClaims(token)
                .getPayload();

            return Optional.of(Long.parseLong(claims.getSubject()));
        } catch (JwtException | IllegalArgumentException ex) {
            return Optional.empty();
        }
    }
}
