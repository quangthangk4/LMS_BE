package com.library.catalog.application.impl;

import com.library.catalog.application.SearchPublisherUseCase;
import com.library.catalog.application.cache.CatalogCacheNames;
import com.library.catalog.dto.response.publisher.PublisherOverviewResponse;
import com.library.catalog.infrastructure.persistence.repository.PublisherJpaRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SearchPublisherUseCaseImpl implements SearchPublisherUseCase {

    private final PublisherJpaRepository publisherJpaRepository;

    @Override
    @Cacheable(
        cacheNames = CatalogCacheNames.PUBLISHER_SEARCH,
        key = "T(com.library.catalog.application.cache.CatalogCacheKeys).keyword(#keyword)"
    )
    public List<PublisherOverviewResponse> execute(String keyword) {
        return publisherJpaRepository.searchByName(keyword, PageRequest.of(0, 10))
                .stream()
                .map(entity -> PublisherOverviewResponse.builder()
                        .id(entity.getId())
                        .name(entity.getName())
                        .build())
                .toList();
    }
}
