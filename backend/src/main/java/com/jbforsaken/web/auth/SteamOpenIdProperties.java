package com.jbforsaken.web.auth;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "steam-openid")
public class SteamOpenIdProperties {

    private String realmUrl = "http://127.0.0.1:5080";
    private String returnUrl = "http://127.0.0.1:5080/api/auth/steam/callback";

    public String getRealmUrl() {
        return realmUrl;
    }

    public void setRealmUrl(String realmUrl) {
        this.realmUrl = realmUrl;
    }

    public String getReturnUrl() {
        return returnUrl;
    }

    public void setReturnUrl(String returnUrl) {
        this.returnUrl = returnUrl;
    }
}
