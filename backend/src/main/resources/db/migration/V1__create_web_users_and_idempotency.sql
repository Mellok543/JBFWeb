CREATE TABLE jbf_web_users (
    steam_id64 BIGINT NOT NULL PRIMARY KEY,
    nickname VARCHAR(64) NULL,
    avatar_url VARCHAR(255) NULL,
    first_login_at TIMESTAMP NOT NULL,
    last_login_at TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jbf_web_idempotency_keys (
    idempotency_key VARCHAR(128) NOT NULL PRIMARY KEY,
    request_fingerprint VARCHAR(128) NOT NULL,
    response_status INT NULL,
    response_body LONGTEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jbf_web_login_codes (
    code VARCHAR(64) NOT NULL PRIMARY KEY,
    steam_id64 BIGINT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
