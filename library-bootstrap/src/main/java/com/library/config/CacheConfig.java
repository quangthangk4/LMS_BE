package com.library.config;

import com.github.benmanes.caffeine.cache.Caffeine;
import java.time.Duration;
import java.util.List;
import org.springframework.cache.CacheManager;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CacheConfig {

  public static final String PUBLICATION_SEARCH = "publicationSearch";
  public static final String PUBLICATION_DETAIL = "publicationDetail";
  public static final String NEWEST_PUBLICATIONS = "newestPublications";
  public static final String MOST_BORROWED_PUBLICATIONS = "mostBorrowedPublications";
  public static final String PUBLIC_LIBRARY_STATS = "publicLibraryStats";
  public static final String PUBLIC_TESTIMONIALS = "publicTestimonials";

  public static final String[] CATALOG_CACHE_NAMES = {
      PUBLICATION_SEARCH,
      PUBLICATION_DETAIL,
      NEWEST_PUBLICATIONS,
      MOST_BORROWED_PUBLICATIONS,
      PUBLIC_LIBRARY_STATS,
      PUBLIC_TESTIMONIALS
  };

  @Bean
  public CacheManager cacheManager() {
    CaffeineCacheManager manager = new CaffeineCacheManager();
    manager.setCacheNames(List.of(CATALOG_CACHE_NAMES));
    manager.setCaffeine(Caffeine.newBuilder()
        .maximumSize(2_000)
        .expireAfterWrite(Duration.ofMinutes(5))
        .recordStats());
    return manager;
  }
}
