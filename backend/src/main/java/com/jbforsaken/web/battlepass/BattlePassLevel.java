package com.jbforsaken.web.battlepass;

import jakarta.persistence.*;

@Entity
@Table(name = "jbf_web_battlepass_levels")
public class BattlePassLevel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "season_id", nullable = false)
    private Long seasonId;

    @Column(name = "level_number", nullable = false)
    private int levelNumber;

    @Column(name = "xp_required", nullable = false)
    private int xpRequired;

    @Column(name = "reward_title", nullable = false, length = 160)
    private String rewardTitle;

    protected BattlePassLevel() {}

    public BattlePassLevel(long seasonId, int levelNumber, int xpRequired, String rewardTitle) {
        this.seasonId = seasonId;
        this.levelNumber = levelNumber;
        this.xpRequired = xpRequired;
        this.rewardTitle = rewardTitle;
    }

    public Long getId() { return id; }
    public Long getSeasonId() { return seasonId; }
    public int getLevelNumber() { return levelNumber; }
    public int getXpRequired() { return xpRequired; }
    public String getRewardTitle() { return rewardTitle; }
}
