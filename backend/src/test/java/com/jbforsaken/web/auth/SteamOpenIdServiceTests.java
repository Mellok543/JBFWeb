package com.jbforsaken.web.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.ExpectedCount;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

class SteamOpenIdServiceTests {

    private static final String STEAM_ENDPOINT = "https://steamcommunity.com/openid/login";
    private static final String RETURN_URL = "http://127.0.0.1:5080/api/auth/steam/callback";
    private static final String VALID_RESPONSE = "ns:http://specs.openid.net/auth/2.0\nis_valid:true\n";

    private SteamOpenIdProperties properties() {
        SteamOpenIdProperties properties = new SteamOpenIdProperties();
        properties.setRealmUrl("http://127.0.0.1:5080");
        properties.setReturnUrl(RETURN_URL);
        return properties;
    }

    /** A well-formed positive assertion, shaped exactly as Steam sends it back to OUR return URL. */
    private static Map<String, String> validAssertion() {
        Map<String, String> query = new HashMap<>();
        query.put("openid.ns", "http://specs.openid.net/auth/2.0");
        query.put("openid.mode", "id_res");
        query.put("openid.op_endpoint", STEAM_ENDPOINT);
        query.put("openid.claimed_id", "https://steamcommunity.com/openid/id/76561198000000000");
        query.put("openid.identity", "https://steamcommunity.com/openid/id/76561198000000000");
        query.put("openid.return_to", RETURN_URL);
        query.put("openid.response_nonce", "2026-09-23T00:00:00Zabcdef");
        query.put("openid.assoc_handle", "1234567890");
        query.put("openid.signed", "signed,op_endpoint,claimed_id,identity,return_to,response_nonce,assoc_handle");
        query.put("openid.sig", "fakesignature");
        return query;
    }

    /**
     * Service whose Steam endpoint always answers is_valid:true — i.e. the signature is genuine —
     * so any rejection can only come from our own relying-party checks.
     */
    private SteamOpenIdService serviceWhereSteamSaysValid() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(ExpectedCount.manyTimes(), requestTo(STEAM_ENDPOINT))
            .andRespond(withSuccess(VALID_RESPONSE, MediaType.TEXT_PLAIN));
        return new SteamOpenIdService(builder, properties());
    }

    @Test
    void buildLoginRedirectUrl_pointsAtSteamWithCorrectReturnUrl() {
        SteamOpenIdService service = new SteamOpenIdService(RestClient.builder(), properties());

        String url = service.buildLoginRedirectUrl();

        assertThat(url).startsWith("https://steamcommunity.com/openid/login?");
        assertThat(url).contains("openid.return_to=http%3A%2F%2F127.0.0.1%3A5080%2Fapi%2Fauth%2Fsteam%2Fcallback");
        assertThat(url).contains("openid.realm=http%3A%2F%2F127.0.0.1%3A5080");
    }

    @Test
    void validateCallback_whenSteamConfirmsValid_returnsSteamId64() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo(STEAM_ENDPOINT))
            .andExpect(method(HttpMethod.POST))
            .andRespond(withSuccess(VALID_RESPONSE, MediaType.TEXT_PLAIN));

        SteamOpenIdService service = new SteamOpenIdService(builder, properties());

        Optional<Long> steamId = service.validateCallback(validAssertion());

        assertThat(steamId).contains(76561198000000000L);
        server.verify();
    }

    @Test
    void validateCallback_whenSteamRejects_returnsEmpty() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo(STEAM_ENDPOINT))
            .andRespond(withSuccess("ns:http://specs.openid.net/auth/2.0\nis_valid:false\n", MediaType.TEXT_PLAIN));

        SteamOpenIdService service = new SteamOpenIdService(builder, properties());

        Optional<Long> steamId = service.validateCallback(validAssertion());

        assertThat(steamId).isEmpty();
    }

    @Test
    void validateCallback_whenSteamRespondsWithServerError_returnsEmptyInsteadOfThrowing() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo(STEAM_ENDPOINT))
            .andRespond(withServerError());

        SteamOpenIdService service = new SteamOpenIdService(builder, properties());

        Optional<Long> steamId = service.validateCallback(validAssertion());

        assertThat(steamId).isEmpty();
    }

    @Test
    void validateCallback_whenClaimedIdMissing_returnsEmptyWithoutCallingSteam() {
        SteamOpenIdService service = new SteamOpenIdService(RestClient.builder(), properties());

        Optional<Long> steamId = service.validateCallback(Map.of("openid.mode", "id_res"));

        assertThat(steamId).isEmpty();
    }

    // --- Relying-party checks (OpenID 2.0 §11.1 / §11.2): a genuine Steam signature alone is not enough ---

    @Test
    void validateCallback_whenReturnToPointsAtAnotherSite_rejectsEvenThoughSteamSaysValid() {
        // Replay of a genuine Steam assertion that was minted for a different relying party.
        Map<String, String> query = validAssertion();
        query.put("openid.return_to", "https://attacker.example/steam/callback");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenReturnToOnlySharesPrefixWithOurs_rejects() {
        Map<String, String> query = validAssertion();
        query.put("openid.return_to", RETURN_URL + ".attacker.example");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenReturnToIsOursWithQueryString_accepts() {
        Map<String, String> query = validAssertion();
        query.put("openid.return_to", RETURN_URL + "?foo=bar");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).contains(76561198000000000L);
    }

    @Test
    void validateCallback_whenReturnToMissing_rejects() {
        Map<String, String> query = validAssertion();
        query.remove("openid.return_to");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenModeIsNotIdRes_rejects() {
        Map<String, String> query = validAssertion();
        query.put("openid.mode", "cancel");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenOpEndpointIsNotSteam_rejects() {
        Map<String, String> query = validAssertion();
        query.put("openid.op_endpoint", "https://evil.example/openid/login");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenReturnToNotInSignedList_rejects() {
        Map<String, String> query = validAssertion();
        query.put("openid.signed", "signed,op_endpoint,claimed_id,identity,response_nonce,assoc_handle");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenClaimedIdNotInSignedList_rejects() {
        Map<String, String> query = validAssertion();
        query.put("openid.signed", "signed,op_endpoint,identity,return_to,response_nonce,assoc_handle");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenIdentityNotInSignedList_rejects() {
        Map<String, String> query = validAssertion();
        query.put("openid.signed", "signed,op_endpoint,claimed_id,return_to,response_nonce,assoc_handle");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenClaimedIdHasTextBeforeSteamUrl_rejects() {
        Map<String, String> query = validAssertion();
        query.put("openid.claimed_id", "evil.com/https://steamcommunity.com/openid/id/76561198000000000");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenClaimedIdHasTextAfterSteamId_rejects() {
        Map<String, String> query = validAssertion();
        query.put("openid.claimed_id", "https://steamcommunity.com/openid/id/76561198000000000/evil");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenClaimedIdIsNotSeventeenDigits_rejects() {
        Map<String, String> query = validAssertion();
        query.put("openid.claimed_id", "https://steamcommunity.com/openid/id/123");

        assertThat(serviceWhereSteamSaysValid().validateCallback(query)).isEmpty();
    }

    @Test
    void validateCallback_whenIsValidTrueAppearsOnlyInsideAnotherLine_rejects() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo(STEAM_ENDPOINT))
            .andRespond(withSuccess(
                "ns:http://specs.openid.net/auth/2.0\nis_valid:false\nerror:is_valid:true\n", MediaType.TEXT_PLAIN));

        SteamOpenIdService service = new SteamOpenIdService(builder, properties());

        assertThat(service.validateCallback(validAssertion())).isEmpty();
    }

    @Test
    void validateCallback_whenResponseUsesCrlfLineEndings_stillAccepts() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo(STEAM_ENDPOINT))
            .andRespond(withSuccess(
                "ns:http://specs.openid.net/auth/2.0\r\nis_valid:true\r\n", MediaType.TEXT_PLAIN));

        SteamOpenIdService service = new SteamOpenIdService(builder, properties());

        assertThat(service.validateCallback(validAssertion())).contains(76561198000000000L);
    }
}
