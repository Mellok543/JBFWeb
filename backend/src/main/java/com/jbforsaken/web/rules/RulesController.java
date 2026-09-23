package com.jbforsaken.web.rules;

import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/rules")
public class RulesController {
    private final RuleItemRepository repository;

    public RulesController(RuleItemRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<RuleItem> rules() {
        return repository.findByActiveTrueOrderBySortOrderAsc();
    }
}
