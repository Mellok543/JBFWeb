package com.jbforsaken.web.monitoring;

import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jbforsaken.web.auth.JwtAuthenticationFilter;
import com.jbforsaken.web.auth.JwtService;
import com.jbforsaken.web.auth.SecurityConfig;
import com.jbforsaken.web.config.AppProperties;
import com.jbforsaken.web.config.CorsConfig;
import com.jbforsaken.web.idempotency.IdempotencyService;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

// Task 10: spring-boot-starter-security is now on the classpath, so @WebMvcTest
// slices are secured by Spring Boot's auto-configured default (deny-all) filter
// chain unless the app's own SecurityConfig is present. Importing it (plus the
// beans it depends on) restores the real /api/server/** permitAll posture instead
// of masking the endpoint behind a default 401.
@WebMvcTest(ServerController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class, CorsConfig.class})
@EnableConfigurationProperties({AppProperties.class, ServerMonitorProperties.class})
@TestPropertySource(properties = {
    "cs2-server.host=185.154.195.198",
    "cs2-server.port=27015"
})
class ServerControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ServerSnapshotStore store;

    // IdempotencyFilter is a Filter-typed @Component, so @WebMvcTest's slice
    // component scan picks it up regardless of the specified controller class.
    // All requests in this test class are GET (non-mutating), so the filter
    // passes them straight through; it just needs its dependency satisfied.
    @MockBean
    private IdempotencyService idempotencyService;

    // Task 10: JwtAuthenticationFilter is also a global @Component Filter bean,
    // so it's pulled into this slice's filter chain the same way IdempotencyFilter
    // is above — its JwtService dependency needs a bean to satisfy it here too.
    @MockBean
    private JwtService jwtService;

    @Test
    void getStatus_returnsSnapshotFromStore() throws Exception {
        Instant mapSince = Instant.now().minusSeconds(300);
        ServerSnapshot snapshot = new ServerSnapshot(
            true, "JBFORSAKEN", "jb_spy_vs_spy", "Counter-Strike 2",
            18, 32, 24, Instant.now(), mapSince,
            List.of(new A2sPlayerInfo("Alice", 10, 300f)));
        when(store.get()).thenReturn(snapshot);

        mockMvc.perform(get("/api/server/status"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.online").value(true))
            .andExpect(jsonPath("$.name").value("JBFORSAKEN"))
            .andExpect(jsonPath("$.players").value(18))
            .andExpect(jsonPath("$.mapTimeSeconds").value(greaterThanOrEqualTo(300)))
            .andExpect(jsonPath("$.connectAddress").value("185.154.195.198:27015"));
    }

    @Test
    void getPlayers_returnsPlayerListFromStore() throws Exception {
        ServerSnapshot snapshot = new ServerSnapshot(
            true, "JBFORSAKEN", "jb_spy_vs_spy", "Counter-Strike 2",
            18, 32, 24, Instant.now(), Instant.now(),
            List.of(new A2sPlayerInfo("Alice", 10, 300f)));
        when(store.get()).thenReturn(snapshot);

        mockMvc.perform(get("/api/server/players"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].name").value("Alice"))
            .andExpect(jsonPath("$[0].connectedSeconds").value(300));
    }

    @Test
    void getStatus_whenServerOffline_returns200WithNullFieldsAndOnlineFalse() throws Exception {
        ServerSnapshot snapshot = ServerSnapshot.offline(Instant.now());
        when(store.get()).thenReturn(snapshot);

        mockMvc.perform(get("/api/server/status"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.online").value(false))
            .andExpect(jsonPath("$.name").doesNotExist())
            .andExpect(jsonPath("$.map").doesNotExist())
            .andExpect(jsonPath("$.game").doesNotExist())
            .andExpect(jsonPath("$.mapTimeSeconds").doesNotExist())
            .andExpect(jsonPath("$.players").value(0))
            .andExpect(jsonPath("$.lastUpdateUtc").exists())
            // Static config, not live state: present even while the server is offline.
            .andExpect(jsonPath("$.connectAddress").value("185.154.195.198:27015"));
    }

    @Test
    void getPlayers_whenServerOffline_returnsEmptyArray() throws Exception {
        ServerSnapshot snapshot = ServerSnapshot.offline(Instant.now());
        when(store.get()).thenReturn(snapshot);

        mockMvc.perform(get("/api/server/players"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").isArray())
            .andExpect(jsonPath("$").isEmpty());
    }
}
