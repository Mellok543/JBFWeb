package com.jbforsaken.web.admin;

import com.jbforsaken.web.battlepass.*;
import com.jbforsaken.web.clan.*;
import com.jbforsaken.web.news.*;
import com.jbforsaken.web.store.*;
import com.jbforsaken.web.user.*;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final AdminGuard guard;
    private final AdminAuditRepository audit;
    private final WebUserRepository users;
    private final NewsPostRepository news;
    private final StoreProductRepository products;
    private final StoreOrderRepository orders;
    private final BattlePassSeasonRepository seasons;
    private final BattlePassLevelRepository levels;
    private final ClanRepository clans;

    public AdminController(
            AdminGuard guard,
            AdminAuditRepository audit,
            WebUserRepository users,
            NewsPostRepository news,
            StoreProductRepository products,
            StoreOrderRepository orders,
            BattlePassSeasonRepository seasons,
            BattlePassLevelRepository levels,
            ClanRepository clans) {
        this.guard = guard;
        this.audit = audit;
        this.users = users;
        this.news = news;
        this.products = products;
        this.orders = orders;
        this.seasons = seasons;
        this.levels = levels;
        this.clans = clans;
    }

    @GetMapping("/me")
    public Map<String, Object> me(Authentication auth) {
        return Map.of("admin", guard.isAdmin(auth));
    }

    @GetMapping("/dashboard")
    public Map<String, Object> dashboard(Authentication auth) {
        guard.requireAdmin(auth);
        return Map.of(
            "users", users.count(),
            "news", news.count(),
            "products", products.count(),
            "orders", orders.count(),
            "clans", clans.count(),
            "seasons", seasons.count()
        );
    }

    @GetMapping("/users")
    public List<WebUser> users(Authentication auth) {
        guard.requireAdmin(auth);
        return users.findAll(PageRequest.of(0, 100, Sort.by(Sort.Direction.DESC, "lastLoginAt"))).getContent();
    }

    @GetMapping("/news")
    public List<NewsPost> news(Authentication auth) {
        guard.requireAdmin(auth);
        return news.findTop20ByOrderByPinnedDescPublishedAtDesc();
    }

    @PostMapping("/news")
    @Transactional
    public NewsPost createNews(Authentication auth, @RequestBody NewsRequest request) {
        long admin = guard.requireAdmin(auth);
        NewsPost item = news.save(new NewsPost(requireText(request.title(), "title"), requireText(request.body(), "body"), request.pinned(), Instant.now()));
        log(admin, "CREATE", "NEWS", item.getId().toString(), item.getTitle());
        return item;
    }

    @PutMapping("/news/{id}")
    @Transactional
    public NewsPost updateNews(Authentication auth, @PathVariable Long id, @RequestBody NewsRequest request) {
        long admin = guard.requireAdmin(auth);
        NewsPost item = news.findById(id).orElseThrow();
        item.update(requireText(request.title(), "title"), requireText(request.body(), "body"), request.pinned());
        log(admin, "UPDATE", "NEWS", id.toString(), item.getTitle());
        return item;
    }

    @DeleteMapping("/news/{id}")
    @Transactional
    public void deleteNews(Authentication auth, @PathVariable Long id) {
        long admin = guard.requireAdmin(auth);
        news.deleteById(id);
        log(admin, "DELETE", "NEWS", id.toString(), null);
    }

    @GetMapping("/products")
    public List<StoreProduct> products(Authentication auth) {
        guard.requireAdmin(auth);
        return products.findAll(Sort.by("sortOrder"));
    }

    @PostMapping("/products")
    @Transactional
    public StoreProduct createProduct(Authentication auth, @RequestBody ProductRequest request) {
        long admin = guard.requireAdmin(auth);
        String code = requireText(request.code(), "code").toUpperCase();
        if (products.existsById(code)) throw new IllegalArgumentException("Product code already exists");
        StoreProduct item = new StoreProduct(code, requireText(request.name(), "name"),
            request.description() == null ? "" : request.description(),
            requireText(request.category(), "category"), request.priceCents(), request.sortOrder());
        item.update(item.getName(), item.getDescription(), item.getCategory(), item.getPriceCents(), request.active(), item.getSortOrder());
        item = products.save(item);
        log(admin, "CREATE", "PRODUCT", item.getCode(), item.getName());
        return item;
    }

    @PutMapping("/products/{code}")
    @Transactional
    public StoreProduct updateProduct(Authentication auth, @PathVariable String code, @RequestBody ProductRequest request) {
        long admin = guard.requireAdmin(auth);
        StoreProduct item = products.findById(code).orElseThrow();
        item.update(requireText(request.name(), "name"), request.description() == null ? "" : request.description(),
            requireText(request.category(), "category"), request.priceCents(), request.active(), request.sortOrder());
        log(admin, "UPDATE", "PRODUCT", code, item.getName());
        return item;
    }

    @DeleteMapping("/products/{code}")
    @Transactional
    public void deleteProduct(Authentication auth, @PathVariable String code) {
        long admin = guard.requireAdmin(auth);
        products.deleteById(code);
        log(admin, "DELETE", "PRODUCT", code, null);
    }

    @GetMapping("/orders")
    public List<StoreOrder> orders(Authentication auth) {
        guard.requireAdmin(auth);
        return orders.findAll(PageRequest.of(0, 100, Sort.by(Sort.Direction.DESC, "createdAt"))).getContent();
    }

    @PutMapping("/orders/{id}/status")
    @Transactional
    public StoreOrder updateOrderStatus(Authentication auth, @PathVariable String id, @RequestBody OrderStatusRequest request) {
        long admin = guard.requireAdmin(auth);
        String status = requireText(request.status(), "status").toUpperCase();
        if (!List.of("PENDING", "PAID", "FULFILLED", "FAILED", "REFUNDED").contains(status)) {
            throw new IllegalArgumentException("Unsupported order status");
        }
        StoreOrder order = orders.findById(id).orElseThrow();
        order.updateStatus(status);
        log(admin, "STATUS", "ORDER", id, status);
        return order;
    }

    @GetMapping("/battlepass/seasons")
    public List<BattlePassSeason> seasons(Authentication auth) {
        guard.requireAdmin(auth);
        return seasons.findAll(Sort.by(Sort.Direction.DESC, "startsAt"));
    }

    @GetMapping("/battlepass/seasons/{id}/levels")
    public List<BattlePassLevel> levels(Authentication auth, @PathVariable Long id) {
        guard.requireAdmin(auth);
        return levels.findBySeasonIdOrderByLevelNumberAsc(id);
    }

    @PostMapping("/battlepass/seasons")
    @Transactional
    public BattlePassSeason createSeason(Authentication auth, @RequestBody SeasonRequest request) {
        long admin = guard.requireAdmin(auth);
        BattlePassSeason season = seasons.save(new BattlePassSeason(
            requireText(request.code(), "code"),
            requireText(request.name(), "name"),
            request.startsAt(),
            request.endsAt(),
            request.active()
        ));
        log(admin, "CREATE", "BATTLEPASS_SEASON", season.getId().toString(), season.getName());
        return season;
    }

    @PostMapping("/battlepass/seasons/{id}/levels")
    @Transactional
    public BattlePassLevel createLevel(Authentication auth, @PathVariable Long id, @RequestBody LevelRequest request) {
        long admin = guard.requireAdmin(auth);
        if (!seasons.existsById(id)) throw new IllegalArgumentException("Season not found");
        BattlePassLevel level = levels.save(new BattlePassLevel(id, request.levelNumber(), request.xpRequired(), requireText(request.rewardTitle(), "rewardTitle")));
        log(admin, "CREATE", "BATTLEPASS_LEVEL", level.getId().toString(), level.getRewardTitle());
        return level;
    }

    @GetMapping("/clans")
    public List<Clan> clans(Authentication auth) {
        guard.requireAdmin(auth);
        return clans.findTop100ByOrderByCreatedAtDesc();
    }

    @DeleteMapping("/clans/{id}")
    @Transactional
    public void deleteClan(Authentication auth, @PathVariable Long id) {
        long admin = guard.requireAdmin(auth);
        clans.deleteById(id);
        log(admin, "DELETE", "CLAN", id.toString(), null);
    }

    @GetMapping("/audit")
    public List<AdminAudit> audit(Authentication auth) {
        guard.requireAdmin(auth);
        return audit.findTop100ByOrderByCreatedAtDesc();
    }

    private void log(long admin, String action, String type, String id, String details) {
        audit.save(new AdminAudit(admin, action, type, id, details));
    }

    private String requireText(String value, String field) {
        if (value == null || value.isBlank()) throw new IllegalArgumentException(field + " is required");
        return value.trim();
    }

    public record NewsRequest(String title, String body, boolean pinned) {}
    public record ProductRequest(String code, String name, String description, String category, int priceCents, boolean active, int sortOrder) {}
    public record OrderStatusRequest(String status) {}
    public record SeasonRequest(String code, String name, Instant startsAt, Instant endsAt, boolean active) {}
    public record LevelRequest(int levelNumber, int xpRequired, String rewardTitle) {}
}
