package com.jbforsaken.web.battlepass;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BattlePassService {
    private final BattlePassSeasonRepository seasons;
    private final BattlePassLevelRepository levels;
    private final BattlePassProgressRepository progress;

    public BattlePassService(
        BattlePassSeasonRepository seasons,
        BattlePassLevelRepository levels,
        BattlePassProgressRepository progress
    ) {
        this.seasons = seasons;
        this.levels = levels;
        this.progress = progress;
    }

    @Transactional(readOnly = true)
    public BattlePassResponse current(Long steamId64) {
        BattlePassSeason season = seasons.findFirstByActiveTrueOrderByStartsAtDesc()
            .orElse(null);
        if (season == null) {
            return new BattlePassResponse(null, java.util.List.of(), null);
        }

        BattlePassProgress player = steamId64 == null
            ? null
            : progress.findBySeasonIdAndSteamId64(season.getId(), steamId64).orElse(null);

        return new BattlePassResponse(
            season,
            levels.findBySeasonIdOrderByLevelNumberAsc(season.getId()),
            player
        );
    }
}
