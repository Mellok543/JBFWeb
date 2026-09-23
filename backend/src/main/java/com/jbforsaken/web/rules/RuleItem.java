package com.jbforsaken.web.rules;

import jakarta.persistence.*;

@Entity
@Table(name = "jbf_web_rules")
public class RuleItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    @Column(nullable = false)
    private boolean active;

    protected RuleItem() {}

    public RuleItem(int sortOrder, String title, String body, boolean active) {
        this.sortOrder = sortOrder;
        this.title = title;
        this.body = body;
        this.active = active;
    }

    public void update(int sortOrder, String title, String body, boolean active) {
        this.sortOrder = sortOrder;
        this.title = title;
        this.body = body;
        this.active = active;
    }

    public Long getId() { return id; }
    public int getSortOrder() { return sortOrder; }
    public String getTitle() { return title; }
    public String getBody() { return body; }
    public boolean isActive() { return active; }
}
