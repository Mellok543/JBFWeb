package com.jbforsaken.web.clan;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_clan_members")
public class ClanMember {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "clan_id", nullable = false)
    private Long clanId;
    @Column(name = "steam_id64", nullable = false, unique = true)
    private Long steamId64;
    @Column(nullable = false, length = 24)
    private String role;
    @Column(name = "joined_at", nullable = false)
    private Instant joinedAt;

    protected ClanMember() {}

    public ClanMember(long clanId, long steamId64, String role, Instant joinedAt) {
        this.clanId = clanId;
        this.steamId64 = steamId64;
        this.role = role;
        this.joinedAt = joinedAt;
    }

    public Long getId() { return id; }
    public Long getClanId() { return clanId; }
    public Long getSteamId64() { return steamId64; }
    public String getRole() { return role; }
    public Instant getJoinedAt() { return joinedAt; }
}
