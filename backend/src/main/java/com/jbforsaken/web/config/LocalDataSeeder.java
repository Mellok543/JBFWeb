package com.jbforsaken.web.config;

import com.jbforsaken.web.battlepass.*;
import com.jbforsaken.web.news.*;
import com.jbforsaken.web.store.*;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("local")
public class LocalDataSeeder {

    @Bean
    CommandLineRunner seedLocalData(
            NewsPostRepository news,
            StoreProductRepository products,
            BattlePassSeasonRepository seasons,
            BattlePassLevelRepository levels) {
        return args -> {
            if (news.count() == 0) {
                news.save(new NewsPost(
                    "JBFORSAKEN развивается",
                    "Веб-портал, Steam-профиль, магазин и игровые системы собираются в единую экосистему.",
                    true,
                    Instant.now()
                ));
                news.save(new NewsPost(
                    "Локальная среда готова",
                    "Backend можно запускать без внешней MySQL через профиль local.",
                    false,
                    Instant.now().minus(1, ChronoUnit.DAYS)
                ));
            }

            if (products.count() == 0) {
                products.save(new StoreProduct(
                    "VIP_30D", "VIP — 30 дней",
                    "Базовая привилегия JBFORSAKEN на 30 дней.",
                    "VIP", 29900, 10
                ));
                products.save(new StoreProduct(
                    "PREMIUM_30D", "Premium — 30 дней",
                    "Расширенная привилегия JBFORSAKEN.",
                    "VIP", 49900, 20
                ));
                products.save(new StoreProduct(
                    "CREDITS_1000", "1000 кредитов",
                    "Игровая валюта для серверных систем и косметики.",
                    "CREDITS", 14900, 30
                ));
            }

            if (seasons.count() == 0) {
                Instant start = Instant.now();
                BattlePassSeason season = seasons.save(new BattlePassSeason(
                    "S01",
                    "Frozen Forsaken — Season 01",
                    start,
                    start.plus(90, ChronoUnit.DAYS),
                    true
                ));

                levels.save(new BattlePassLevel(season.getId(), 1, 0, "Стартовый значок"));
                levels.save(new BattlePassLevel(season.getId(), 2, 1000, "250 кредитов"));
                levels.save(new BattlePassLevel(season.getId(), 3, 2500, "Сезонный кейс"));
                levels.save(new BattlePassLevel(season.getId(), 4, 4500, "500 кредитов"));
                levels.save(new BattlePassLevel(season.getId(), 5, 7000, "Frozen Forsaken Reward"));
            }
        };
    }
}
