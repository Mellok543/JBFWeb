package com.jbforsaken.web.clan;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClanRepository extends JpaRepository<Clan, Long> {
    List<Clan> findTop100ByOrderByCreatedAtDesc();
    boolean existsByNameIgnoreCase(String name);
    boolean existsByTagIgnoreCase(String tag);
}
