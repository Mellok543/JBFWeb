package com.jbforsaken.web.admin;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "jbf_web_admin_audit")
public class AdminAudit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "admin_steam_id64", nullable = false)
    private Long adminSteamId64;

    @Column(nullable = false, length = 80)
    private String action;

    @Column(name = "target_type", nullable = false, length = 80)
    private String targetType;

    @Column(name = "target_id", length = 128)
    private String targetId;

    @Column(columnDefinition = "TEXT")
    private String details;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected AdminAudit() {}

    public AdminAudit(long adminSteamId64, String action, String targetType, String targetId, String details) {
        this.adminSteamId64 = adminSteamId64;
        this.action = action;
        this.targetType = targetType;
        this.targetId = targetId;
        this.details = details;
        this.createdAt = Instant.now();
    }

    public Long getId() { return id; }
    public Long getAdminSteamId64() { return adminSteamId64; }
    public String getAction() { return action; }
    public String getTargetType() { return targetType; }
    public String getTargetId() { return targetId; }
    public String getDetails() { return details; }
    public Instant getCreatedAt() { return createdAt; }
}
