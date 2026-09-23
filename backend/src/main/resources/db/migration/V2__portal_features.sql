CREATE TABLE jbf_web_news (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(160) NOT NULL,
    body TEXT NOT NULL,
    pinned BOOLEAN NOT NULL DEFAULT FALSE,
    published_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jbf_web_store_products (
    code VARCHAR(64) NOT NULL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(32) NOT NULL,
    price_cents INT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jbf_web_store_orders (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    steam_id64 BIGINT NOT NULL,
    product_code VARCHAR(64) NOT NULL,
    amount_cents INT NOT NULL,
    status VARCHAR(24) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP NULL,
    CONSTRAINT fk_jbf_web_order_product FOREIGN KEY (product_code)
        REFERENCES jbf_web_store_products(code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_jbf_web_store_orders_steam ON jbf_web_store_orders(steam_id64, created_at);

CREATE TABLE jbf_web_battlepass_seasons (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NOT NULL,
    active BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jbf_web_battlepass_levels (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    season_id BIGINT NOT NULL,
    level_number INT NOT NULL,
    xp_required INT NOT NULL,
    reward_title VARCHAR(160) NOT NULL,
    CONSTRAINT uq_jbf_web_bp_level UNIQUE (season_id, level_number),
    CONSTRAINT fk_jbf_web_bp_level_season FOREIGN KEY (season_id)
        REFERENCES jbf_web_battlepass_seasons(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jbf_web_battlepass_progress (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    season_id BIGINT NOT NULL,
    steam_id64 BIGINT NOT NULL,
    xp INT NOT NULL DEFAULT 0,
    premium BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_jbf_web_bp_progress UNIQUE (season_id, steam_id64),
    CONSTRAINT fk_jbf_web_bp_progress_season FOREIGN KEY (season_id)
        REFERENCES jbf_web_battlepass_seasons(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jbf_web_clans (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,
    tag VARCHAR(12) NOT NULL UNIQUE,
    owner_steam_id64 BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jbf_web_clan_members (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    clan_id BIGINT NOT NULL,
    steam_id64 BIGINT NOT NULL UNIQUE,
    role VARCHAR(24) NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_jbf_web_clan_member_clan FOREIGN KEY (clan_id)
        REFERENCES jbf_web_clans(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jbf_web_player_stats (
    steam_id64 BIGINT NOT NULL PRIMARY KEY,
    playtime_minutes BIGINT NOT NULL DEFAULT 0,
    kills INT NOT NULL DEFAULT 0,
    deaths INT NOT NULL DEFAULT 0,
    credits BIGINT NOT NULL DEFAULT 0,
    warden_rounds INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO jbf_web_news(title, body, pinned)
VALUES
('JBFORSAKEN развивается', 'Мы собираем сайт и игровые системы проекта в единую экосистему.', TRUE),
('Веб-профиль игрока', 'Steam-авторизация уже является основой для профиля, статистики и покупок.', FALSE);

INSERT INTO jbf_web_store_products(code, name, description, category, price_cents, sort_order)
VALUES
('VIP_30D', 'VIP — 30 дней', 'Базовая привилегия JBFORSAKEN на 30 дней.', 'VIP', 29900, 10),
('PREMIUM_30D', 'Premium — 30 дней', 'Расширенная привилегия JBFORSAKEN на 30 дней.', 'VIP', 49900, 20),
('CREDITS_1000', '1000 кредитов', 'Игровая валюта для серверных систем и косметики.', 'CREDITS', 14900, 30);

INSERT INTO jbf_web_battlepass_seasons(code, name, starts_at, ends_at, active)
VALUES ('S01', 'Frozen Forsaken — Season 01', CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 90 DAY), TRUE);

SET @season_id = LAST_INSERT_ID();

INSERT INTO jbf_web_battlepass_levels(season_id, level_number, xp_required, reward_title)
VALUES
(@season_id, 1, 0, 'Стартовый значок'),
(@season_id, 2, 1000, '250 кредитов'),
(@season_id, 3, 2500, 'Сезонный кейс'),
(@season_id, 4, 4500, '500 кредитов'),
(@season_id, 5, 7000, 'Frozen Forsaken Reward');
