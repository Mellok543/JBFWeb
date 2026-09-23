package com.jbforsaken.web.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_users")
public class WebUser {

    @Id
    @Column(name = "steam_id64")
    private Long steamId64;

    @Column(name = "nickname")
    private String nickname;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "first_login_at", nullable = false)
    private Instant firstLoginAt;

    @Column(name = "last_login_at", nullable = false)
    private Instant lastLoginAt;

    protected WebUser() {
        // required by JPA
    }

    public WebUser(Long steamId64, String nickname, String avatarUrl, Instant now) {
        this.steamId64 = steamId64;
        this.nickname = nickname;
        this.avatarUrl = avatarUrl;
        this.firstLoginAt = now;
        this.lastLoginAt = now;
    }

    public void recordLogin(String nickname, String avatarUrl, Instant now) {
        // Steam profile lookups can transiently fail (no API key, empty
        // response, network error — see SteamProfileService), in which case
        // nickname/avatarUrl arrive here as null. Don't let a hiccup during
        // profile enrichment wipe out data captured by a previous successful
        // login; only overwrite when the caller actually has a fresh value.
        if (nickname != null) {
            this.nickname = nickname;
        }
        if (avatarUrl != null) {
            this.avatarUrl = avatarUrl;
        }
        this.lastLoginAt = now;
    }

    public Long getSteamId64() {
        return steamId64;
    }

    public String getNickname() {
        return nickname;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public Instant getFirstLoginAt() {
        return firstLoginAt;
    }

    public Instant getLastLoginAt() {
        return lastLoginAt;
    }
}
