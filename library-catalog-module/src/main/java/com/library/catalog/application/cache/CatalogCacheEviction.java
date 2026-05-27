package com.library.catalog.application.cache;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.springframework.cache.annotation.Caching;
import org.springframework.cache.annotation.CacheEvict;

public final class CatalogCacheEviction {

  private CatalogCacheEviction() {
  }

  @Caching(evict = {
      @CacheEvict(cacheNames = CatalogCacheNames.PUBLICATION_SEARCH, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.PUBLICATION_DETAIL, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.NEWEST_PUBLICATIONS, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.MOST_BORROWED_PUBLICATIONS, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.PUBLIC_LIBRARY_STATS, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.PUBLIC_TESTIMONIALS, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.CATEGORY_OVERVIEWS, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.AUTHOR_SEARCH, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.CATEGORY_SEARCH, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.PUBLISHER_SEARCH, allEntries = true),
      @CacheEvict(cacheNames = CatalogCacheNames.TAG_SEARCH, allEntries = true)
  })
  @Target(ElementType.METHOD)
  @Retention(RetentionPolicy.RUNTIME)
  public @interface EvictCatalogReadCaches {
  }
}
