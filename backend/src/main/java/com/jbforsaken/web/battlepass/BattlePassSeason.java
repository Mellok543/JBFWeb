package com.jbforsaken.web.battlepass;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_battlepass_seasons")
public class BattlePassSeason {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 64)
    private String code;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(name = "starts_at", nullable = false)
    private Instant startsAt;

    @Column(name = "ends_at", nullable = false)
    private Instant endsAt;

    @Column(nullable = false)
    private boolean active;

    protected BattlePassSeason() {}

    public Long getId() { return id; }
    public String getCode() { return code; }
    public String getName() { return name; }
    public Instant getStartsAt() { return startsAt; }
    public Instant getEndsAt() { return endsAt; }
    public boolean isActive() { return active; }
}
