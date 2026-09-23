package com.jbforsaken.web.clan;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_clans")
public class Clan {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false, unique = true, length = 64)
    private String name;
    @Column(nullable = false, unique = true, length = 12)
    private String tag;
    @Column(name = "owner_steam_id64", nullable = false)
    private Long ownerSteamId64;
    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected Clan() {}

    public Clan(String name, String tag, long ownerSteamId64, Instant createdAt) {
        this.name = name;
        this.tag = tag;
        this.ownerSteamId64 = ownerSteamId64;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public String getName() { return name; }
    public String getTag() { return tag; }
    public Long getOwnerSteamId64() { return ownerSteamId64; }
    public Instant getCreatedAt() { return createdAt; }
}
