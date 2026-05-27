package com.library.catalog.application.cache;

import com.library.catalog.application.i18n.MetadataLanguage;
import com.library.catalog.dto.request.publication.PublicSearchRequest;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

public final class CatalogCacheKeys {

  private CatalogCacheKeys() {
  }

  public static String publicSearch(PublicSearchRequest req, String uiLanguage) {
    return String.join("|",
        "lang=" + MetadataLanguage.normalize(uiLanguage),
        "kw=" + normalize(req.getKeyword()),
        "categoryId=" + value(req.getCategoryId()),
        "categoryIds=" + sortedIds(req.getCategoryIds()),
        "language=" + normalize(req.getLanguage()),
        "yearFrom=" + value(req.getYearFrom()),
        "yearTo=" + value(req.getYearTo()),
        "available=" + value(req.getAvailable()),
        "branch=" + normalize(req.getBranch()),
        "sortBy=" + normalize(req.getSortBy()),
        "titleOnly=" + value(req.getTitleOnly()),
        "page=" + req.getPage(),
        "size=" + req.getSize());
  }

  public static String localizedLimit(int limit, String uiLanguage) {
    return "limit=" + limit + "|lang=" + MetadataLanguage.normalize(uiLanguage);
  }

  public static String detail(Long publicationId, String uiLanguage) {
    return "id=" + publicationId + "|lang=" + MetadataLanguage.normalize(uiLanguage);
  }

  private static String sortedIds(List<Long> ids) {
    if (ids == null || ids.isEmpty()) {
      return "";
    }
    return ids.stream()
        .filter(Objects::nonNull)
        .sorted(Comparator.naturalOrder())
        .map(String::valueOf)
        .collect(Collectors.joining(","));
  }

  private static String normalize(String value) {
    return value == null ? "" : value.trim().toLowerCase();
  }

  private static String value(Object value) {
    return value == null ? "" : String.valueOf(value);
  }
}
