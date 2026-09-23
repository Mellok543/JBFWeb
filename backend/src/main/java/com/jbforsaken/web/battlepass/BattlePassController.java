package com.jbforsaken.web.battlepass;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/battlepass")
public class BattlePassController {
    private final BattlePassService service;

    public BattlePassController(BattlePassService service) {
        this.service = service;
    }

    @GetMapping("/current")
    public BattlePassResponse current(Authentication authentication) {
        Long steamId = authentication == null ? null : Long.parseLong(authentication.getName());
        return service.current(steamId);
    }
}
