package com.jbforsaken.web.admin;

import com.jbforsaken.web.config.AppProperties;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Component
public class AdminGuard {
    private final AppProperties properties;

    public AdminGuard(AppProperties properties) {
        this.properties = properties;
    }

    public long requireAdmin(Authentication authentication) {
        if (authentication == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }

        long steamId64;
        try {
            steamId64 = Long.parseLong(authentication.getName());
        } catch (NumberFormatException ex) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }

        if (!properties.getAdminSteamIdSet().contains(steamId64)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }

        return steamId64;
    }

    public boolean isAdmin(Authentication authentication) {
        if (authentication == null) return false;
        try {
            return properties.getAdminSteamIdSet().contains(Long.parseLong(authentication.getName()));
        } catch (NumberFormatException ex) {
            return false;
        }
    }
}
