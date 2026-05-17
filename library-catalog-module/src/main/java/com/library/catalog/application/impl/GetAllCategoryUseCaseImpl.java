package com.library.catalog.application.impl;

import com.library.catalog.application.GetAllCategoryUseCase;
import com.library.catalog.dto.response.category.CategoryOverviewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GetAllCategoryUseCaseImpl implements GetAllCategoryUseCase {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    private static final String CATEGORY_OVERVIEW_SQL = """
        SELECT
            c.id,
            c.name,
            c.bio,
            c.parent_category_id,
            parent.name AS parent_category_name,
            COUNT(DISTINCT pc.publication_id) AS publication_count
        FROM categories c
        LEFT JOIN categories parent ON parent.id = c.parent_category_id
        LEFT JOIN publication_categories pc ON pc.category_id = c.id
        GROUP BY c.id, c.name, c.bio, c.parent_category_id, parent.name
        ORDER BY COUNT(DISTINCT pc.publication_id) DESC, c.name ASC
        """;

    @Override
    @Transactional(readOnly = true)
    public List<CategoryOverviewResponse> execute() {
        return jdbcTemplate.query(CATEGORY_OVERVIEW_SQL, (rs, rowNum) ->
            CategoryOverviewResponse.builder()
                .id(rs.getLong("id"))
                .name(rs.getString("name"))
                .bio(rs.getString("bio"))
                .parentCategoryId((Long) rs.getObject("parent_category_id"))
                .parentCategoryName(rs.getString("parent_category_name"))
                .publicationCount(rs.getLong("publication_count"))
                .build()
        );
    }
}
