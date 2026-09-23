package com.jbforsaken.web.store;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_store_orders")
public class StoreOrder {
    @Id
    @Column(length = 36)
    private String id;

    @Column(name = "steam_id64", nullable = false)
    private Long steamId64;

    @Column(name = "product_code", nullable = false, length = 64)
    private String productCode;

    @Column(name = "amount_cents", nullable = false)
    private int amountCents;

    @Column(nullable = false, length = 24)
    private String status;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "paid_at")
    private Instant paidAt;

    protected StoreOrder() {}

    public StoreOrder(String id, long steamId64, String productCode, int amountCents, Instant createdAt) {
        this.id = id;
        this.steamId64 = steamId64;
        this.productCode = productCode;
        this.amountCents = amountCents;
        this.status = "PENDING";
        this.createdAt = createdAt;
    }

    public void updateStatus(String status) {
        this.status = status;
        if ("PAID".equals(status) && paidAt == null) {
            this.paidAt = Instant.now();
        }
    }

    public String getId() { return id; }
    public Long getSteamId64() { return steamId64; }
    public String getProductCode() { return productCode; }
    public int getAmountCents() { return amountCents; }
    public String getStatus() { return status; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getPaidAt() { return paidAt; }
}
