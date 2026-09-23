package com.jbforsaken.web.store;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StoreProductRepository extends JpaRepository<StoreProduct, String> {
    List<StoreProduct> findByActiveTrueOrderBySortOrderAsc();
}
