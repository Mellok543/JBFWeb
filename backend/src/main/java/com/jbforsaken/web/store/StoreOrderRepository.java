package com.jbforsaken.web.store;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StoreOrderRepository extends JpaRepository<StoreOrder, String> {
    List<StoreOrder> findTop50BySteamId64OrderByCreatedAtDesc(Long steamId64);
}
