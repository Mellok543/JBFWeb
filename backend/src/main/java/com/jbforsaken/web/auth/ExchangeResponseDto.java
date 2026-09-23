package com.jbforsaken.web.auth;

import java.time.Instant;

public record ExchangeResponseDto(String token, Instant expiresAt) {
}
