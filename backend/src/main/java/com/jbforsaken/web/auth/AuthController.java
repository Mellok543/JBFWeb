package com.jbforsaken.web.auth;

import com.jbforsaken.web.config.AppProperties;
import com.jbforsaken.web.user.UserService;
import com.jbforsaken.web.user.WebUserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    private final SteamOpenIdService openIdService;
    private final SteamProfileService profileService;
    private final UserService userService;
    private final WebUserRepository webUserRepository;
    private final LoginCodeService loginCodeService;
    private final JwtService jwtService;
    private final AppProperties appProperties;

    public AuthController(
            SteamOpenIdService openIdService,
            SteamProfileService profileService,
            UserService userService,
            WebUserRepository webUserRepository,
            LoginCodeService loginCodeService,
            JwtService jwtService,
            AppProperties appProperties) {
        this.openIdService = openIdService;
        this.profileService = profileService;
        this.userService = userService;
        this.webUserRepository = webUserRepository;
        this.loginCodeService = loginCodeService;
        this.jwtService = jwtService;
        this.appProperties = appProperties;
    }

    @GetMapping("/steam/login")
    public void login(HttpServletResponse response) throws IOException {
        response.sendRedirect(openIdService.buildLoginRedirectUrl());
    }

    @GetMapping("/steam/callback")
    public void callback(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Map<String, String> queryParams = request.getParameterMap().entrySet().stream()
            .collect(Collectors.toMap(Map.Entry::getKey, e -> e.getValue()[0]));

        Optional<Long> steamId = openIdService.validateCallback(queryParams);
        if (steamId.isEmpty()) {
            log.warn("Steam OpenID callback failed validation");
            response.sendRedirect(appProperties.getFrontendOrigin() + "/?login=failed");
            return;
        }

        SteamProfile profile = profileService.fetchProfile(steamId.get());
        userService.upsertFromSteamLogin(steamId.get(), profile.nickname(), profile.avatarUrl());
        String code = loginCodeService.issueCode(steamId.get());

        log.info("Steam login succeeded for SteamID64 {}", steamId.get());
        response.sendRedirect(appProperties.getFrontendOrigin() + "/auth-callback?code=" + code);
    }

    // This endpoint sits behind Task 9's IdempotencyFilter when the client sends
    // an Idempotency-Key header. A successful response here — including the
    // bearer token below — is cached verbatim in jbf_web_idempotency_keys and
    // replayed to anyone who later sends the same Idempotency-Key + body. This
    // is an accepted Phase 1 tradeoff: Idempotency-Key values are client-generated,
    // unguessable, single-purpose UUIDs, so replay requires already possessing
    // the original key. Not a structural fix here — flagging it for the next
    // reader rather than restructuring the already-approved Task 9 infrastructure.
    @PostMapping("/exchange")
    public ResponseEntity<ExchangeResponseDto> exchange(@RequestBody ExchangeRequest request) {
        if (request.code() == null || request.code().isBlank()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }

        Optional<Long> steamId = loginCodeService.consumeCode(request.code());
        if (steamId.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }

        JwtService.IssuedToken issued = jwtService.issue(steamId.get());
        return ResponseEntity.ok(new ExchangeResponseDto(issued.token(), issued.expiresAt()));
    }

    @GetMapping("/me")
    public ResponseEntity<AuthMeDto> me(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        long steamId64 = Long.parseLong(authentication.getName());
        return webUserRepository.findById(steamId64)
            .map(user -> ResponseEntity.ok(new AuthMeDto(user.getSteamId64().toString(), user.getNickname(), user.getAvatarUrl())))
            .orElseGet(() -> ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
    }
}
