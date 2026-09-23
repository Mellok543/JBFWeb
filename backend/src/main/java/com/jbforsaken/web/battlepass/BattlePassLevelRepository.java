package com.jbforsaken.web.battlepass;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BattlePassLevelRepository extends JpaRepository<BattlePassLevel, Long> {
    List<BattlePassLevel> findBySeasonIdOrderByLevelNumberAsc(Long seasonId);
}
