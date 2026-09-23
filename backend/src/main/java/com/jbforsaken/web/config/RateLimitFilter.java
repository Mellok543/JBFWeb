package com.jbforsaken.web.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

// Explicit servlet-filter order: RateLimitFilter(1) -> IdempotencyFilter(2) -> JwtAuthenticationFilter(3).
// Reject abusive traffic before doing any other work.
@Component
@Order(1)
public class RateLimitFilter extends OncePerRequestFilter {

    private record Rule(String name, int limit, long windowMillis) {
    }

    private static final Rule AUTH_RULE = new Rule("auth", 10, 60_000);
    private static final Rule SERVER_STATUS_RULE = new Rule("server-status", 30, 60_000);

    private record Window(AtomicInteger count, AtomicLong windowStartMillis) {
    }

    private final Map<String, Window> windows = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        Optional<Rule> rule = matchRule(request.getRequestURI());
        if (rule.isEmpty()) {
            filterChain.doFilter(request, response);
            return;
        }

        String key = rule.get().name() + ":" + request.getRemoteAddr();
        Window window = windows.computeIfAbsent(key, k -> new Window(new AtomicInteger(0), new AtomicLong(System.currentTimeMillis())));

        long now = System.currentTimeMillis();
        if (now - window.windowStartMillis().get() > rule.get().windowMillis()) {
            window.windowStartMillis().set(now);
            window.count().set(0);
        }

        if (window.count().incrementAndGet() > rule.get().limit()) {
            response.setStatus(429);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Too many requests\"}");
            return;
        }

        filterChain.doFilter(request, response);
    }

    private Optional<Rule> matchRule(String path) {
        if (path.startsWith("/api/auth/")) {
            return Optional.of(AUTH_RULE);
        }
        if (path.startsWith("/api/server/")) {
            return Optional.of(SERVER_STATUS_RULE);
        }
        return Optional.empty();
    }
}
