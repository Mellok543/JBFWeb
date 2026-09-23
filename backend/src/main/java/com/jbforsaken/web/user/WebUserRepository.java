package com.jbforsaken.web.user;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WebUserRepository extends JpaRepository<WebUser, Long> {
    List<WebUser> findTop100ByNicknameContainingIgnoreCaseOrderByLastLoginAtDesc(String nickname);
}
