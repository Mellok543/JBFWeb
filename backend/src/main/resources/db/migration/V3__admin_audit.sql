CREATE TABLE jbf_web_admin_audit (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    admin_steam_id64 BIGINT NOT NULL,
    action VARCHAR(80) NOT NULL,
    target_type VARCHAR(80) NOT NULL,
    target_id VARCHAR(128) NULL,
    details TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_jbf_web_admin_audit_created_at
    ON jbf_web_admin_audit(created_at);
