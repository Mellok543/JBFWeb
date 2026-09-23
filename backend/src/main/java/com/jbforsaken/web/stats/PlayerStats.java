package com.jbforsaken.web.stats;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_player_stats")
public class PlayerStats {
    @Id
    @Column(name = "steam_id64")
    private Long steamId64;
    @Column(name = "playtime_minutes", nullable = false)
    private long playtimeMinutes;
    @Column(nullable = false)
    private int kills;
    @Column(nullable = false)
    private int deaths;
    @Column(nullable = false)
    private long credits;
    @Column(name = "warden_rounds", nullable = false)
    private int wardenRounds;
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected PlayerStats() {}

    public Long getSteamId64() { return steamId64; }
    public long getPlaytimeMinutes() { return playtimeMinutes; }
    public int getKills() { return kills; }
    public int getDeaths() { return deaths; }
    public long getCredits() { return credits; }
    public int getWardenRounds() { return wardenRounds; }
    public Instant getUpdatedAt() { return updatedAt; }
}
