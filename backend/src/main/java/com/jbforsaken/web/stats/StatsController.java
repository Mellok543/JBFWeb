package com.jbforsaken.web.stats;

import java.util.List;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/stats")
public class StatsController {
    private final PlayerStatsRepository repository;

    public StatsController(PlayerStatsRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/top")
    public List<PlayerStats> top(@RequestParam(defaultValue = "playtime") String metric) {
        String property = switch (metric) {
            case "kills" -> "kills";
            case "credits" -> "credits";
            case "warden" -> "wardenRounds";
            default -> "playtimeMinutes";
        };
        return repository.findAll(PageRequest.of(0, 50, Sort.by(Sort.Direction.DESC, property))).getContent();
    }

    @GetMapping("/me")
    public PlayerStats me(Authentication authentication) {
        return repository.findById(Long.parseLong(authentication.getName())).orElse(null);
    }
}
