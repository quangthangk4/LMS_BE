package com.library.catalog.application.impl;

import com.library.catalog.application.SearchCategoryUseCase;
import com.library.catalog.application.cache.CatalogCacheNames;
import com.library.catalog.dto.response.category.CategoryOverviewResponse;
import com.library.catalog.infrastructure.persistence.repository.CategoryJpaRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SearchCategoryUseCaseImpl implements SearchCategoryUseCase {

    private final CategoryJpaRepository categoryJpaRepository;

    @Override
    @Cacheable(
        cacheNames = CatalogCacheNames.CATEGORY_SEARCH,
        key = "T(com.library.catalog.application.cache.CatalogCacheKeys).keyword(#keyword)"
    )
    public List<CategoryOverviewResponse> execute(String keyword) {
        return categoryJpaRepository.searchByName(keyword, PageRequest.of(0, 10))
                .stream()
                .map(entity -> CategoryOverviewResponse.builder()
                        .id(entity.getId())
                        .name(entity.getName())
                        .build())
                .toList();
    }
}
