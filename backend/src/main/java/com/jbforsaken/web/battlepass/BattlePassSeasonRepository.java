package com.jbforsaken.web.battlepass;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BattlePassSeasonRepository extends JpaRepository<BattlePassSeason, Long> {
    Optional<BattlePassSeason> findFirstByActiveTrueOrderByStartsAtDesc();
}
