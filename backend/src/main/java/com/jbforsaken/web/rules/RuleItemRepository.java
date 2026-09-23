package com.jbforsaken.web.rules;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RuleItemRepository extends JpaRepository<RuleItem, Long> {
    List<RuleItem> findByActiveTrueOrderBySortOrderAsc();
    List<RuleItem> findAllByOrderBySortOrderAsc();
}
