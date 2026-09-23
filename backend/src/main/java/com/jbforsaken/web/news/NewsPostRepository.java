package com.jbforsaken.web.news;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NewsPostRepository extends JpaRepository<NewsPost, Long> {
    List<NewsPost> findTop20ByOrderByPinnedDescPublishedAtDesc();
}
