package com.jbforsaken.web;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(webEnvironment = WebEnvironment.DEFINED_PORT)
@ActiveProfiles("test")
class HealthEndpointPortTests {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void healthEndpoint_respondsOnFixedPort5080() {
        ResponseEntity<String> response = restTemplate.getForEntity("http://127.0.0.1:5080/api/health", String.class);

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).contains("\"status\":\"ok\"");
    }
}
