package com.jbforsaken.web.idempotency;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingResponseWrapper;

// Explicit servlet-filter order: RateLimitFilter(1) -> IdempotencyFilter(2) -> JwtAuthenticationFilter(3).
@Component
@Order(2)
public class IdempotencyFilter extends OncePerRequestFilter {

    private static final String HEADER_NAME = "Idempotency-Key";

    private final IdempotencyService service;

    public IdempotencyFilter(IdempotencyService service) {
        this.service = service;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String idempotencyKey = request.getHeader(HEADER_NAME);
        boolean isMutating = "POST".equalsIgnoreCase(request.getMethod())
            || "PUT".equalsIgnoreCase(request.getMethod())
            || "PATCH".equalsIgnoreCase(request.getMethod());

        if (idempotencyKey == null || idempotencyKey.isBlank() || !isMutating) {
            filterChain.doFilter(request, response);
            return;
        }

        CachedBodyHttpServletRequest wrappedRequest = new CachedBodyHttpServletRequest(request);
        String fingerprint = fingerprint(request.getMethod(), request.getRequestURI(), wrappedRequest.getCachedBody());

        IdempotencyService.ReservationResult reservation = service.reserve(idempotencyKey, fingerprint);

        switch (reservation.outcome()) {
            case CONFLICT -> {
                response.setStatus(422); // 422 Unprocessable Entity — no jakarta.servlet constant exists for it
                response.setContentType("application/json");
                response.getWriter().write("{\"error\":\"Idempotency-Key reused with a different request\"}");
            }
            case IN_PROGRESS -> {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                response.setContentType("application/json");
                response.getWriter().write("{\"error\":\"A request with this Idempotency-Key is already being processed\"}");
            }
            case REPLAY -> {
                response.setStatus(reservation.responseStatus());
                response.setContentType("application/json");
                if (reservation.responseBody() != null) {
                    response.getWriter().write(reservation.responseBody());
                }
            }
            case RESERVED -> {
                ContentCachingResponseWrapper wrappedResponse = new ContentCachingResponseWrapper(response);
                filterChain.doFilter(wrappedRequest, wrappedResponse);
                String body = new String(wrappedResponse.getContentAsByteArray(), StandardCharsets.UTF_8);
                service.complete(idempotencyKey, wrappedResponse.getStatus(), body);
                wrappedResponse.copyBodyToResponse();
            }
        }
    }

    private String fingerprint(String method, String requestUri, byte[] body) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            digest.update(method.getBytes(StandardCharsets.UTF_8));
            digest.update(requestUri.getBytes(StandardCharsets.UTF_8));
            digest.update(body);
            return HexFormat.of().formatHex(digest.digest());
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }
}
