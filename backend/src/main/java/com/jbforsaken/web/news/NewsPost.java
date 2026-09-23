package com.jbforsaken.web.news;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_news")
public class NewsPost {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    @Column(nullable = false)
    private boolean pinned;

    @Column(name = "published_at", nullable = false)
    private Instant publishedAt;

    protected NewsPost() {}

    public NewsPost(String title, String body, boolean pinned, Instant publishedAt) {
        this.title = title;
        this.body = body;
        this.pinned = pinned;
        this.publishedAt = publishedAt;
    }

    public Long getId() { return id; }
    public String getTitle() { return title; }
    public String getBody() { return body; }
    public boolean isPinned() { return pinned; }
    public Instant getPublishedAt() { return publishedAt; }
}
