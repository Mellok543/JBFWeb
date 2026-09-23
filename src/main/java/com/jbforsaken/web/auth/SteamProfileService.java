package com.jbforsaken.web.auth;

import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Component
public class SteamProfileService {

    private final RestClient restClient;
    private final String apiKey;

    public SteamProfileService(RestClient.Builder restClientBuilder, @Value("${STEAM_API_KEY:}") String apiKey) {
        this.restClient = restClientBuilder.build();
        this.apiKey = (apiKey == null || apiKey.isBlank()) ? null : apiKey;
    }

    public SteamProfile fetchProfile(long steamId64) {
        if (apiKey == null) {
            return new SteamProfile(steamId64, null, null);
        }

        try {
            SteamApiResponse response = restClient.get()
                .uri("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key={key}&steamids={id}", apiKey, steamId64)
                .retrieve()
                .body(SteamApiResponse.class);

            if (response == null || response.response() == null || response.response().players().isEmpty()) {
                return new SteamProfile(steamId64, null, null);
            }

            SteamApiPlayer player = response.response().players().get(0);
            return new SteamProfile(steamId64, player.personaname(), player.avatarfull());
        } catch (RestClientException ex) {
            return new SteamProfile(steamId64, null, null);
        }
    }

    private record SteamApiResponse(SteamApiInnerResponse response) {
    }

    private record SteamApiInnerResponse(List<SteamApiPlayer> players) {
    }

    private record SteamApiPlayer(String personaname, String avatarfull) {
    }
}
