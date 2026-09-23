package com.jbforsaken.web.store;

import java.util.List;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/store")
public class StoreController {
    private final StoreService service;

    public StoreController(StoreService service) {
        this.service = service;
    }

    @GetMapping("/products")
    public List<StoreProduct> products() {
        return service.products();
    }

    @GetMapping("/orders")
    public List<StoreOrder> myOrders(Authentication authentication) {
        return service.orders(steamId(authentication));
    }

    @PostMapping("/orders")
    public StoreOrder createOrder(Authentication authentication, @RequestBody CreateOrderRequest request) {
        if (request.productCode() == null || request.productCode().isBlank()) {
            throw new IllegalArgumentException("productCode is required");
        }
        return service.createOrder(steamId(authentication), request.productCode());
    }

    private long steamId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }
}
