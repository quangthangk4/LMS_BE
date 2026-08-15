package com.library.catalog.application.dto.request;

import jakarta.validation.constraints.Min;

public record GetAllPublicationForLibrarian(
    String keyword,

    Long categoryId,

    Integer year,

    AvailabilityFilter availability,

    String sortBy,

    SortDirection direction,

    @Min(value = 0, message = "Page must be >= 0")
    Integer page,

    @Min(value = 1, message = "Size must be >= 1")
    Integer size
) {
    public GetAllPublicationForLibrarian {
        if (availability == null) availability = AvailabilityFilter.ALL;
        if (direction == null) direction = SortDirection.ASC;
        if (page == null || page < 0) page = 0;
        if (size == null || size < 1) size = 10;
        if (sortBy == null) sortBy = "createdAt"; // default sorting field
    }

    public enum AvailabilityFilter {
        ALL,
        HAS_ITEMS,
        NO_ITEMS
    }

    public enum SortDirection {
        ASC,
        DESC
    }
}
