package com.jbforsaken.web.clan;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClanMemberRepository extends JpaRepository<ClanMember, Long> {
    Optional<ClanMember> findBySteamId64(Long steamId64);
    long countByClanId(Long clanId);
}
