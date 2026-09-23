package com.jbforsaken.web.config;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

class RateLimitFilterTests {

    private static final FilterChain OK_CHAIN =
        (req, res) -> ((HttpServletResponse) res).setStatus(200);

    @Test
    void exceedingServerStatusLimit_returns429() throws Exception {
        RateLimitFilter filter = new RateLimitFilter();

        MockHttpServletResponse lastResponse = null;
        for (int i = 0; i < 31; i++) {
            MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/server/status");
            request.setRemoteAddr("127.0.0.1");
            lastResponse = new MockHttpServletResponse();
            filter.doFilter(request, lastResponse, OK_CHAIN);
        }

        assertThat(lastResponse.getStatus()).isEqualTo(429);
    }

    @Test
    void exceedingAuthLimit_returns429() throws Exception {
        RateLimitFilter filter = new RateLimitFilter();

        MockHttpServletResponse lastResponse = null;
        for (int i = 0; i < 11; i++) {
            MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/auth/me");
            request.setRemoteAddr("127.0.0.1");
            lastResponse = new MockHttpServletResponse();
            filter.doFilter(request, lastResponse, OK_CHAIN);
        }

        assertThat(lastResponse.getStatus()).isEqualTo(429);
    }

    @Test
    void unrelatedPath_isNeverRateLimited() throws Exception {
        RateLimitFilter filter = new RateLimitFilter();

        MockHttpServletResponse lastResponse = null;
        for (int i = 0; i < 50; i++) {
            MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/health");
            request.setRemoteAddr("127.0.0.1");
            lastResponse = new MockHttpServletResponse();
            filter.doFilter(request, lastResponse, OK_CHAIN);
        }

        assertThat(lastResponse.getStatus()).isEqualTo(200);
    }
}
