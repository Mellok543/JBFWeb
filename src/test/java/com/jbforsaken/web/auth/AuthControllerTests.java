package com.jbforsaken.web.auth;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jbforsaken.web.config.AppProperties;
import com.jbforsaken.web.config.CorsConfig;
import com.jbforsaken.web.user.UserService;
import com.jbforsaken.web.user.WebUser;
import com.jbforsaken.web.user.WebUserRepository;
import java.time.Instant;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(AuthController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class, JwtService.class, CorsConfig.class})
@EnableConfigurationProperties({AppProperties.class, JwtProperties.class})
@TestPropertySource(properties = {
    "jwt.secret=test-secret-key-at-least-32-bytes-long!!",
    "jwt.expiration-minutes=60",
    "app.frontend-origin=http://localhost:5173"
})
class AuthControllerTests {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private JwtService jwtService;

    @MockBean
    private SteamOpenIdService openIdService;
    @MockBean
    private SteamProfileService profileService;
    @MockBean
    private UserService userService;
    @MockBean
    private WebUserRepository webUserRepository;
    @MockBean
    private LoginCodeService loginCodeService;
    @MockBean
    private com.jbforsaken.web.idempotency.IdempotencyService idempotencyService;
    // Required since Task 9: IdempotencyFilter is a global @Component Filter bean,
    // and @WebMvcTest pulls in every registered Filter into the MockMvc chain
    // regardless of which controller is under test — without this @MockBean, the
    // slice fails to build (IdempotencyFilter's own IdempotencyService dependency
    // has no bean to satisfy). Task 9 hit the identical issue in ServerControllerTests.

    @Test
    void me_withoutToken_returns401() throws Exception {
        mockMvc.perform(get("/api/auth/me"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void me_withValidToken_returnsUserFromRepository() throws Exception {
        WebUser user = new WebUser(76561198000000000L, "Mell", "https://avatar", Instant.now());
        when(webUserRepository.findById(76561198000000000L)).thenReturn(Optional.of(user));
        String token = jwtService.issue(76561198000000000L).token();

        mockMvc.perform(get("/api/auth/me").header("Authorization", "Bearer " + token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.steamId64").value("76561198000000000"))
            .andExpect(jsonPath("$.nickname").value("Mell"));
    }

    @Test
    void exchange_withValidCode_returnsToken() throws Exception {
        when(loginCodeService.consumeCode("valid-code")).thenReturn(Optional.of(76561198000000000L));

        mockMvc.perform(post("/api/auth/exchange")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"code\":\"valid-code\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").isNotEmpty());
    }

    @Test
    void exchange_withInvalidCode_returns400() throws Exception {
        when(loginCodeService.consumeCode("bad-code")).thenReturn(Optional.empty());

        mockMvc.perform(post("/api/auth/exchange")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"code\":\"bad-code\"}"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void exchange_withMissingCode_returns400NotServerError() throws Exception {
        mockMvc.perform(post("/api/auth/exchange")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
            .andExpect(status().isBadRequest());

        // The @MockBean would return Optional.empty() -> 400 anyway, so the status alone
        // doesn't prove the guard ran. Prove it short-circuits before the service.
        verify(loginCodeService, never()).consumeCode(any());
    }

    @Test
    void exchange_withBlankCode_returns400NotServerError() throws Exception {
        mockMvc.perform(post("/api/auth/exchange")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"code\":\"\"}"))
            .andExpect(status().isBadRequest());

        verify(loginCodeService, never()).consumeCode(any());
    }

    @Test
    void steamCallback_whenValidationSucceeds_upsertsUserAndRedirectsWithLoginCode() throws Exception {
        long steamId = 76561198000000000L;
        when(openIdService.validateCallback(anyMap())).thenReturn(Optional.of(steamId));
        when(profileService.fetchProfile(steamId)).thenReturn(new SteamProfile(steamId, "Mell", "https://avatar"));
        when(loginCodeService.issueCode(steamId)).thenReturn("one-time-code");

        mockMvc.perform(get("/api/auth/steam/callback")
                .param("openid.mode", "id_res")
                .param("openid.claimed_id", "https://steamcommunity.com/openid/id/" + steamId))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrl("http://localhost:5173/auth-callback?code=one-time-code"));

        verify(userService).upsertFromSteamLogin(steamId, "Mell", "https://avatar");
        verify(loginCodeService).issueCode(steamId);
    }

    @Test
    void steamCallback_whenValidationFails_redirectsToLoginFailedWithoutTouchingUsers() throws Exception {
        when(openIdService.validateCallback(anyMap())).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/auth/steam/callback")
                .param("openid.mode", "id_res")
                .param("openid.return_to", "https://attacker.example/steam/callback"))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrl("http://localhost:5173/?login=failed"));

        verify(userService, never()).upsertFromSteamLogin(anyLong(), anyString(), anyString());
        verifyNoInteractions(profileService, loginCodeService);
    }
}
