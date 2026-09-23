package com.jbforsaken.web.auth;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Component
public class SteamOpenIdService {

    private static final String STEAM_OPENID_ENDPOINT = "https://steamcommunity.com/openid/login";
    // Anchored and used via Matcher.matches() (never find()): a claimed_id with anything
    // before or after the canonical Steam identity URL is rejected.
    private static final Pattern CLAIMED_ID_PATTERN =
        Pattern.compile("^https://steamcommunity\\.com/openid/id/(\\d{17})$");
    // Fields that MUST be covered by Steam's signature. Otherwise a genuine signature over
    // a stripped-down field set could be paired with attacker-chosen unsigned values.
    private static final List<String> REQUIRED_SIGNED_FIELDS =
        List.of("op_endpoint", "claimed_id", "identity", "return_to");

    private final RestClient restClient;
    private final SteamOpenIdProperties properties;

    public SteamOpenIdService(RestClient.Builder restClientBuilder, SteamOpenIdProperties properties) {
        this.restClient = restClientBuilder.build();
        this.properties = properties;
    }

    public String buildLoginRedirectUrl() {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("openid.ns", "http://specs.openid.net/auth/2.0");
        params.put("openid.mode", "checkid_setup");
        params.put("openid.return_to", properties.getReturnUrl());
        params.put("openid.realm", properties.getRealmUrl());
        params.put("openid.identity", "http://specs.openid.net/auth/2.0/identifier_select");
        params.put("openid.claimed_id", "http://specs.openid.net/auth/2.0/identifier_select");

        String query = params.entrySet().stream()
            .map(e -> e.getKey() + "=" + URLEncoder.encode(e.getValue(), StandardCharsets.UTF_8))
            .collect(Collectors.joining("&"));

        return STEAM_OPENID_ENDPOINT + "?" + query;
    }

    public Optional<Long> validateCallback(Map<String, String> queryParams) {
        // Relying-party checks (OpenID 2.0 §11.1-§11.2) run BEFORE asking Steam.
        // check_authentication only proves the signature is genuine — not that the
        // assertion was issued for us. Without the return_to check, an assertion
        // captured by any other "Sign in through Steam" site could be replayed here
        // to log in as its victim.
        if (!"id_res".equals(queryParams.get("openid.mode"))) {
            return Optional.empty();
        }
        if (!STEAM_OPENID_ENDPOINT.equals(queryParams.get("openid.op_endpoint"))) {
            return Optional.empty();
        }
        if (!isOurReturnUrl(queryParams.get("openid.return_to"))) {
            return Optional.empty();
        }
        if (!signsRequiredFields(queryParams.get("openid.signed"))) {
            return Optional.empty();
        }

        String claimedId = queryParams.getOrDefault("openid.claimed_id", "");
        Matcher matcher = CLAIMED_ID_PATTERN.matcher(claimedId);
        if (!matcher.matches()) {
            return Optional.empty();
        }

        MultiValueMap<String, String> verificationParams = new LinkedMultiValueMap<>();
        queryParams.forEach((key, value) -> {
            if (key.startsWith("openid.")) {
                verificationParams.add(key, value);
            }
        });
        verificationParams.set("openid.mode", "check_authentication");

        String body;
        try {
            body = restClient.post()
                .uri(STEAM_OPENID_ENDPOINT)
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(verificationParams)
                .retrieve()
                .body(String.class);
        } catch (RestClientException ex) {
            // A Steam outage (5xx, timeout, DNS failure) should be treated the
            // same as a rejected verification, not propagate out of this
            // service — AuthController relies on an empty Optional here to
            // redirect the browser to the graceful /?login=failed path instead
            // of surfacing a 500. Same reasoning as SteamProfileService.
            return Optional.empty();
        }

        if (!isValidTrue(body)) {
            return Optional.empty();
        }

        return Optional.of(Long.parseLong(matcher.group(1)));
    }

    /**
     * Exact match against the configured return URL. A query string appended to it is
     * tolerated (spec §11.1 allows extra return_to parameters), but a bare prefix match is
     * not — "…/callback.attacker.example" must not pass.
     */
    private boolean isOurReturnUrl(String returnTo) {
        if (returnTo == null) {
            return false;
        }
        String ours = properties.getReturnUrl();
        return returnTo.equals(ours) || returnTo.startsWith(ours + "?");
    }

    private static boolean signsRequiredFields(String signed) {
        if (signed == null || signed.isBlank()) {
            return false;
        }
        Set<String> signedFields = Set.copyOf(Arrays.asList(signed.split(",")));
        return signedFields.containsAll(REQUIRED_SIGNED_FIELDS);
    }

    /** Key-Value Form (spec §4.1.1): require a whole line equal to is_valid:true, not a substring. */
    private static boolean isValidTrue(String body) {
        if (body == null) {
            return false;
        }
        return body.lines().anyMatch("is_valid:true"::equals);
    }
}
