package com.jbforsaken.web.battlepass;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_battlepass_progress")
public class BattlePassProgress {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "season_id", nullable = false)
    private Long seasonId;

    @Column(name = "steam_id64", nullable = false)
    private Long steamId64;

    @Column(nullable = false)
    private int xp;

    @Column(nullable = false)
    private boolean premium;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected BattlePassProgress() {}

    public BattlePassProgress(long seasonId, long steamId64) {
        this.seasonId = seasonId;
        this.steamId64 = steamId64;
        this.xp = 0;
        this.premium = false;
        this.updatedAt = Instant.now();
    }

    public Long getId() { return id; }
    public Long getSeasonId() { return seasonId; }
    public Long getSteamId64() { return steamId64; }
    public int getXp() { return xp; }
    public boolean isPremium() { return premium; }
    public Instant getUpdatedAt() { return updatedAt; }
}
