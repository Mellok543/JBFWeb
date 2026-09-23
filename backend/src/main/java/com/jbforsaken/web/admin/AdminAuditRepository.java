package com.jbforsaken.web.admin;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminAuditRepository extends JpaRepository<AdminAudit, Long> {
    List<AdminAudit> findTop100ByOrderByCreatedAtDesc();
}
