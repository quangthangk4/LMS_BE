package com.library.config;

import com.github.benmanes.caffeine.cache.Caffeine;
import com.library.catalog.application.cache.CatalogCacheNames;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import org.springframework.cache.CacheManager;
import org.springframework.cache.caffeine.CaffeineCache;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.cache.support.SimpleCacheManager;

@Configuration
public class CacheConfig {

  @Bean
  public CacheManager cacheManager() {
    SimpleCacheManager manager = new SimpleCacheManager();
    List<CaffeineCache> caches = new ArrayList<>();

    caches.add(cache(CatalogCacheNames.PUBLICATION_SEARCH, Duration.ofMinutes(5), 1_000));
    caches.add(cache(CatalogCacheNames.PUBLICATION_DETAIL, Duration.ofMinutes(3), 2_000));
    caches.add(cache(CatalogCacheNames.NEWEST_PUBLICATIONS, Duration.ofMinutes(10), 200));
    caches.add(cache(CatalogCacheNames.MOST_BORROWED_PUBLICATIONS, Duration.ofMinutes(15), 200));
    caches.add(cache(CatalogCacheNames.PUBLIC_LIBRARY_STATS, Duration.ofMinutes(15), 50));
    caches.add(cache(CatalogCacheNames.PUBLIC_TESTIMONIALS, Duration.ofMinutes(15), 100));
    caches.add(cache(CatalogCacheNames.CATEGORY_OVERVIEWS, Duration.ofMinutes(30), 20));
    caches.add(cache(CatalogCacheNames.AUTHOR_SEARCH, Duration.ofMinutes(30), 500));
    caches.add(cache(CatalogCacheNames.CATEGORY_SEARCH, Duration.ofMinutes(30), 500));
    caches.add(cache(CatalogCacheNames.PUBLISHER_SEARCH, Duration.ofMinutes(30), 500));
    caches.add(cache(CatalogCacheNames.TAG_SEARCH, Duration.ofMinutes(30), 500));

    manager.setCaches(List.copyOf(caches));
    return manager;
  }

  private CaffeineCache cache(String name, Duration ttl, long maximumSize) {
    return new CaffeineCache(name, Caffeine.newBuilder()
        .maximumSize(maximumSize)
        .expireAfterWrite(ttl)
        .recordStats()
        .build());
  }
}
