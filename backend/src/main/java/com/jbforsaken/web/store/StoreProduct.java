package com.jbforsaken.web.store;

import jakarta.persistence.*;

@Entity
@Table(name = "jbf_web_store_products")
public class StoreProduct {
    @Id
    @Column(length = 64)
    private String code;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 32)
    private String category;

    @Column(name = "price_cents", nullable = false)
    private int priceCents;

    @Column(nullable = false)
    private boolean active;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    protected StoreProduct() {}

    public StoreProduct(String code, String name, String description, String category, int priceCents, int sortOrder) {
        this.code = code;
        this.name = name;
        this.description = description;
        this.category = category;
        this.priceCents = priceCents;
        this.active = true;
        this.sortOrder = sortOrder;
    }

    public void update(String name, String description, String category, int priceCents, boolean active, int sortOrder) {
        this.name = name;
        this.description = description;
        this.category = category;
        this.priceCents = priceCents;
        this.active = active;
        this.sortOrder = sortOrder;
    }

    public String getCode() { return code; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public String getCategory() { return category; }
    public int getPriceCents() { return priceCents; }
    public boolean isActive() { return active; }
    public int getSortOrder() { return sortOrder; }
}
