package com.jbforsaken.web.clan;

import java.util.List;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/clans")
public class ClanController {
    private final ClanService service;

    public ClanController(ClanService service) {
        this.service = service;
    }

    @GetMapping
    public List<Clan> list() {
        return service.list();
    }

    @PostMapping
    public Clan create(Authentication authentication, @RequestBody CreateClanRequest request) {
        return service.create(Long.parseLong(authentication.getName()), request.name(), request.tag());
    }
}
