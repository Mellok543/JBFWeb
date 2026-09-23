package com.jbforsaken.web.news;

import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/news")
public class NewsController {
    private final NewsPostRepository repository;

    public NewsController(NewsPostRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<NewsPost> latest() {
        return repository.findTop20ByOrderByPinnedDescPublishedAtDesc();
    }
}
