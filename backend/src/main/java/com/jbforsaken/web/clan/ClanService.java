package com.jbforsaken.web.clan;

import java.time.Instant;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ClanService {
    private final ClanRepository clans;
    private final ClanMemberRepository members;

    public ClanService(ClanRepository clans, ClanMemberRepository members) {
        this.clans = clans;
        this.members = members;
    }

    @Transactional(readOnly = true)
    public List<Clan> list() {
        return clans.findTop100ByOrderByCreatedAtDesc();
    }

    @Transactional
    public Clan create(long steamId64, String name, String tag) {
        String cleanName = name == null ? "" : name.trim();
        String cleanTag = tag == null ? "" : tag.trim().toUpperCase();

        if (cleanName.length() < 3 || cleanName.length() > 64) {
            throw new IllegalArgumentException("Clan name must be 3-64 characters");
        }
        if (cleanTag.length() < 2 || cleanTag.length() > 12) {
            throw new IllegalArgumentException("Clan tag must be 2-12 characters");
        }
        if (members.findBySteamId64(steamId64).isPresent()) {
            throw new IllegalArgumentException("Player is already in a clan");
        }
        if (clans.existsByNameIgnoreCase(cleanName) || clans.existsByTagIgnoreCase(cleanTag)) {
            throw new IllegalArgumentException("Clan name or tag already exists");
        }

        Clan clan = clans.save(new Clan(cleanName, cleanTag, steamId64, Instant.now()));
        members.save(new ClanMember(clan.getId(), steamId64, "OWNER", Instant.now()));
        return clan;
    }
}
