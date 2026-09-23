package com.jbforsaken.web.auth;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_login_codes")
public class LoginCode {

    @Id
    @Column(name = "code")
    private String code;

    @Column(name = "steam_id64", nullable = false)
    private Long steamId64;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "used_at")
    private Instant usedAt;

    protected LoginCode() {
        // required by JPA
    }

    public LoginCode(String code, Long steamId64, Instant expiresAt) {
        this.code = code;
        this.steamId64 = steamId64;
        this.expiresAt = expiresAt;
    }

    public String getCode() {
        return code;
    }

    public Long getSteamId64() {
        return steamId64;
    }

    public Instant getExpiresAt() {
        return expiresAt;
    }

    public Instant getUsedAt() {
        return usedAt;
    }
}
