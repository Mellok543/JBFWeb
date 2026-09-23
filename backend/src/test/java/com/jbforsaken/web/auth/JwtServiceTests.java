package com.jbforsaken.web.auth;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;

class JwtServiceTests {

    private JwtProperties properties() {
        JwtProperties properties = new JwtProperties();
        properties.setSecret("test-secret-key-at-least-32-bytes-long!!");
        properties.setExpirationMinutes(60);
        return properties;
    }

    @Test
    void issueThenParse_roundTripsTheSteamId() {
        JwtService service = new JwtService(properties());

        JwtService.IssuedToken issued = service.issue(76561198000000000L);
        var parsed = service.parse(issued.token());

        assertThat(parsed).contains(76561198000000000L);
    }

    @Test
    void parse_invalidToken_returnsEmpty() {
        JwtService service = new JwtService(properties());

        var parsed = service.parse("not-a-real-token");

        assertThat(parsed).isEmpty();
    }

    @Test
    void parse_tokenSignedWithDifferentSecret_returnsEmpty() {
        JwtProperties secretA = properties();
        secretA.setSecret("test-secret-key-at-least-32-bytes-long-A");
        JwtProperties secretB = properties();
        secretB.setSecret("test-secret-key-at-least-32-bytes-long-B");

        JwtService.IssuedToken issued = new JwtService(secretA).issue(76561198000000000L);
        var parsed = new JwtService(secretB).parse(issued.token());

        assertThat(parsed).isEmpty();
    }

    @Test
    void parse_expiredToken_returnsEmpty() {
        JwtProperties properties = properties();
        properties.setExpirationMinutes(1);

        Clock issueClock = Clock.fixed(Instant.parse("2026-01-01T00:00:00Z"), ZoneOffset.UTC);
        JwtService.IssuedToken issued = new JwtService(properties, issueClock).issue(1L);

        Clock laterClock = Clock.fixed(Instant.parse("2026-01-01T00:10:00Z"), ZoneOffset.UTC);
        var parsed = new JwtService(properties, laterClock).parse(issued.token());

        assertThat(parsed).isEmpty();
    }
}
