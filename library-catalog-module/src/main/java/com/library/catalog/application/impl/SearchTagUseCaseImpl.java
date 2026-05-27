package com.library.catalog.application.impl;

import com.library.catalog.application.SearchTagUseCase;
import com.library.catalog.application.cache.CatalogCacheNames;
import com.library.catalog.dto.response.tag.TagResponse;
import com.library.catalog.infrastructure.persistence.repository.TagJpaRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SearchTagUseCaseImpl implements SearchTagUseCase {

    private final TagJpaRepository tagJpaRepository;

    @Override
    @Cacheable(
        cacheNames = CatalogCacheNames.TAG_SEARCH,
        key = "T(com.library.catalog.application.cache.CatalogCacheKeys).keyword(#keyword)"
    )
    public List<TagResponse> execute(String keyword) {
        return tagJpaRepository.searchByName(keyword, PageRequest.of(0, 10))
                .stream()
                .map(entity -> TagResponse.builder()
                        .id(entity.getId())
                        .name(entity.getName())
                        .build())
                .toList();
    }
}
