package com.jbforsaken.web.battlepass;

import java.util.List;

public record BattlePassResponse(
    BattlePassSeason season,
    List<BattlePassLevel> levels,
    BattlePassProgress progress
) {}
