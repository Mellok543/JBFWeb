package com.jbforsaken.web.store;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StoreService {
    private final StoreProductRepository products;
    private final StoreOrderRepository orders;

    public StoreService(StoreProductRepository products, StoreOrderRepository orders) {
        this.products = products;
        this.orders = orders;
    }

    @Transactional(readOnly = true)
    public List<StoreProduct> products() {
        return products.findByActiveTrueOrderBySortOrderAsc();
    }

    @Transactional
    public StoreOrder createOrder(long steamId64, String productCode) {
        StoreProduct product = products.findById(productCode)
            .filter(StoreProduct::isActive)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        StoreOrder order = new StoreOrder(
            UUID.randomUUID().toString(),
            steamId64,
            product.getCode(),
            product.getPriceCents(),
            Instant.now()
        );
        return orders.save(order);
    }

    @Transactional(readOnly = true)
    public List<StoreOrder> orders(long steamId64) {
        return orders.findTop50BySteamId64OrderByCreatedAtDesc(steamId64);
    }
}
