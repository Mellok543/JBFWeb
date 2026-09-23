package com.jbforsaken.web.idempotency;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.context.ActiveProfiles;

@DataJpaTest
@ActiveProfiles("test")
class IdempotencyFilterTests {

    @Autowired
    private IdempotencyKeyRepository repository;

    private IdempotencyFilter newFilter() {
        return new IdempotencyFilter(new IdempotencyService(repository));
    }

    private MockHttpServletRequest postRequest(String idempotencyKey, String body) {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/mutate");
        if (idempotencyKey != null) {
            request.addHeader("Idempotency-Key", idempotencyKey);
        }
        request.setContent(body.getBytes(StandardCharsets.UTF_8));
        return request;
    }

    private static final class RecordingChain implements FilterChain {
        int invocations = 0;
        private final int status;
        private final String body;

        RecordingChain(int status, String body) {
            this.status = status;
            this.body = body;
        }

        @Override
        public void doFilter(ServletRequest request, ServletResponse response) throws IOException {
            invocations++;
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            httpResponse.setStatus(status);
            httpResponse.getWriter().write(body);
        }
    }

    /**
     * A chain that reads the request body downstream, the way a real controller deserializing
     * a {@code @RequestBody} would. Used to prove the filter's fingerprinting read doesn't
     * exhaust the stream before the chain gets to it.
     */
    private static final class BodyReadingChain implements FilterChain {
        int invocations = 0;
        String observedBody;

        @Override
        public void doFilter(ServletRequest request, ServletResponse response) throws IOException {
            invocations++;
            observedBody = new String(request.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            httpResponse.setStatus(200);
            httpResponse.getWriter().write("{\"result\":\"ok\"}");
        }
    }

    @Test
    void firstRequestWithKey_invokesChainAndStoresResponse() throws ServletException, IOException {
        IdempotencyFilter filter = newFilter();
        MockHttpServletResponse response = new MockHttpServletResponse();
        RecordingChain chain = new RecordingChain(200, "{\"result\":\"ok\"}");

        filter.doFilter(postRequest("key-a", "{\"amount\":10}"), response, chain);

        assertThat(chain.invocations).isEqualTo(1);
        assertThat(response.getStatus()).isEqualTo(200);
        assertThat(response.getContentAsString(StandardCharsets.UTF_8)).isEqualTo("{\"result\":\"ok\"}");
    }

    @Test
    void secondRequestWithSameKeyAndBody_replaysWithoutInvokingChainAgain() throws ServletException, IOException {
        IdempotencyFilter filter = newFilter();
        filter.doFilter(
            postRequest("key-b", "{\"amount\":10}"),
            new MockHttpServletResponse(),
            new RecordingChain(200, "{\"result\":\"ok\"}"));

        RecordingChain secondChain = new RecordingChain(200, "should-not-be-used");
        MockHttpServletResponse secondResponse = new MockHttpServletResponse();
        filter.doFilter(postRequest("key-b", "{\"amount\":10}"), secondResponse, secondChain);

        assertThat(secondChain.invocations).isEqualTo(0);
        assertThat(secondResponse.getStatus()).isEqualTo(200);
        assertThat(secondResponse.getContentAsString(StandardCharsets.UTF_8)).isEqualTo("{\"result\":\"ok\"}");
    }

    @Test
    void sameKeyDifferentBody_returnsUnprocessableEntityWithoutInvokingChain() throws ServletException, IOException {
        IdempotencyFilter filter = newFilter();
        filter.doFilter(
            postRequest("key-c", "{\"amount\":10}"),
            new MockHttpServletResponse(),
            new RecordingChain(200, "ok"));

        RecordingChain secondChain = new RecordingChain(200, "should-not-be-used");
        MockHttpServletResponse secondResponse = new MockHttpServletResponse();
        filter.doFilter(postRequest("key-c", "{\"amount\":999}"), secondResponse, secondChain);

        assertThat(secondChain.invocations).isEqualTo(0);
        assertThat(secondResponse.getStatus()).isEqualTo(422);
    }

    @Test
    void reservedPath_downstreamChainCanStillReadFullRequestBody() throws ServletException, IOException {
        IdempotencyFilter filter = newFilter();
        BodyReadingChain chain = new BodyReadingChain();
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(postRequest("key-d", "{\"amount\":10}"), response, chain);

        assertThat(chain.invocations).isEqualTo(1);
        assertThat(chain.observedBody).isEqualTo("{\"amount\":10}");
        assertThat(response.getStatus()).isEqualTo(200);
    }

    @Test
    void requestsWithoutIdempotencyKey_alwaysInvokeChain() throws ServletException, IOException {
        IdempotencyFilter filter = newFilter();
        RecordingChain chain = new RecordingChain(200, "ok");

        filter.doFilter(postRequest(null, "{\"amount\":10}"), new MockHttpServletResponse(), chain);
        filter.doFilter(postRequest(null, "{\"amount\":10}"), new MockHttpServletResponse(), chain);

        assertThat(chain.invocations).isEqualTo(2);
    }
}
