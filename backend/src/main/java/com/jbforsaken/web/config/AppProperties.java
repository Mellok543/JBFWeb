package com.jbforsaken.web.config;

import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app")
public class AppProperties {

    private String frontendOrigin = "http://localhost:5173";
    private String adminSteamIds = "";

    public String getFrontendOrigin() {
        return frontendOrigin;
    }

    public void setFrontendOrigin(String frontendOrigin) {
        this.frontendOrigin = frontendOrigin;
    }

    public String getAdminSteamIds() {
        return adminSteamIds;
    }

    public void setAdminSteamIds(String adminSteamIds) {
        this.adminSteamIds = adminSteamIds;
    }

    public Set<Long> getAdminSteamIdSet() {
        if (adminSteamIds == null || adminSteamIds.isBlank()) {
            return Set.of();
        }
        return Arrays.stream(adminSteamIds.split(","))
            .map(String::trim)
            .filter(s -> !s.isBlank())
            .map(Long::parseLong)
            .collect(Collectors.toUnmodifiableSet());
    }
}
