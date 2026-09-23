package com.jbforsaken.web.battlepass;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BattlePassProgressRepository extends JpaRepository<BattlePassProgress, Long> {
    Optional<BattlePassProgress> findBySeasonIdAndSteamId64(Long seasonId, Long steamId64);
}
