package com.library.catalog.application.impl;

import com.library.catalog.application.SearchPublicationsUseCase;
import com.library.catalog.dto.request.publication.PublicSearchRequest;
import com.library.catalog.dto.response.publication.PublicSearchResult;
import com.library.shared.dto.PageResponse;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SearchPublicationsUseCaseImpl implements SearchPublicationsUseCase {

    private final NamedParameterJdbcTemplate jdbc;

    private static final String SELECT_CLAUSE = """
        SELECT
            p.id                                                                          AS publication_id,
            p.title,
            p.cover_image_url,
            p.publication_year,
            p.description,
            pub.name                                                                      AS publisher_name,
            (SELECT STRING_AGG(a2.name, ', ' ORDER BY a2.name)
             FROM publication_authors pa2 JOIN authors a2 ON a2.id = pa2.author_id
             WHERE pa2.publication_id = p.id)                                             AS author_names,
            (SELECT STRING_AGG(c2.name, ', ')
             FROM publication_categories pc2 JOIN categories c2 ON c2.id = pc2.category_id
             WHERE pc2.publication_id = p.id)                                             AS category_names,
            (SELECT COUNT(*) FROM items i2 WHERE i2.publication_id = p.id)                AS total_items,
            (SELECT COUNT(*) FROM items i2 WHERE i2.publication_id = p.id
             AND i2.status = 'AVAILABLE')                                                 AS available_items,
            (SELECT COALESCE(AVG(r.star::numeric), 0) FROM ratings r
             WHERE r.publication_id = p.id)                                               AS avg_rating,
            (SELECT COUNT(*) FROM borrowing_transactions bt
             JOIN items bi ON bi.id = bt.item_id
             WHERE bi.publication_id = p.id)                                              AS borrow_count,
            (SELECT COUNT(*) FROM user_interactions ui
             WHERE ui.publication_id = p.id AND ui.type = 'WATCH')                        AS view_count
        FROM publications p
        LEFT JOIN publishers pub ON pub.id = p.publisher_id
        """;

    private static final String COUNT_CLAUSE =
        "SELECT COUNT(DISTINCT p.id) FROM publications p LEFT JOIN publishers pub ON pub.id = p.publisher_id ";

    @Override
    public PageResponse<PublicSearchResult> execute(PublicSearchRequest req) {
        MapSqlParameterSource params = new MapSqlParameterSource();
        String where = buildWhere(req, params);

        int size = Math.min(req.getSize(), 50);
        int page = Math.max(req.getPage(), 0);
        params.addValue("size", size).addValue("offset", page * size);

        String orderBy = buildOrderBy(req.getSortBy(), req.getKeyword());
        String dataSql = SELECT_CLAUSE + where + " ORDER BY " + orderBy + " LIMIT :size OFFSET :offset";
        String countSql = COUNT_CLAUSE + where;

        List<PublicSearchResult> content = jdbc.query(dataSql, params, (rs, row) ->
            new PublicSearchResult(
                rs.getLong("publication_id"),
                rs.getString("title"),
                rs.getString("cover_image_url"),
                rs.getObject("publication_year", Integer.class),
                rs.getString("description"),
                rs.getString("publisher_name"),
                rs.getString("author_names"),
                rs.getString("category_names"),
                rs.getInt("total_items"),
                rs.getInt("available_items"),
                rs.getDouble("avg_rating"),
                rs.getLong("borrow_count"),
                rs.getLong("view_count")
            )
        );

        long total = jdbc.queryForObject(countSql, params, Long.class);
        int totalPages = size > 0 ? (int) Math.ceil((double) total / size) : 0;

        return PageResponse.<PublicSearchResult>builder()
            .content(content)
            .totalElements(total)
            .totalPages(totalPages)
            .currentPage(page)
            .pageSize(size)
            .isFirst(page == 0)
            .isLast(page >= totalPages - 1)
            .build();
    }

    private String buildWhere(PublicSearchRequest req, MapSqlParameterSource params) {
        StringBuilder sb = new StringBuilder("WHERE 1=1 ");

        if (req.getKeyword() != null && !req.getKeyword().isBlank()) {
            String kw = "%" + req.getKeyword().trim().toLowerCase() + "%";
            sb.append("""
                AND (LOWER(p.title) LIKE :kw
                  OR LOWER(p.subtitle) LIKE :kw
                  OR p.isbn = :kwExact
                  OR EXISTS (SELECT 1 FROM publication_authors pa JOIN authors a ON a.id = pa.author_id
                             WHERE pa.publication_id = p.id AND LOWER(a.name) LIKE :kw)
                  OR EXISTS (SELECT 1 FROM publication_tags pt JOIN tags t ON t.id = pt.tag_id
                             WHERE pt.publication_id = p.id AND LOWER(t.name) LIKE :kw)
                  OR EXISTS (SELECT 1 FROM publication_categories pc JOIN categories c ON c.id = pc.category_id
                             WHERE pc.publication_id = p.id AND LOWER(c.name) LIKE :kw))
                """);
            params.addValue("kw", kw).addValue("kwExact", req.getKeyword().trim());
        }

        if (req.getCategoryId() != null) {
            sb.append("AND EXISTS (SELECT 1 FROM publication_categories pc WHERE pc.publication_id = p.id AND pc.category_id = :categoryId) ");
            params.addValue("categoryId", req.getCategoryId());
        }

        if (req.getLanguage() != null && !req.getLanguage().isBlank()) {
            sb.append("AND p.language = :language ");
            params.addValue("language", req.getLanguage());
        }

        if (req.getYearFrom() != null) {
            sb.append("AND p.publication_year >= :yearFrom ");
            params.addValue("yearFrom", req.getYearFrom());
        }

        if (req.getYearTo() != null) {
            sb.append("AND p.publication_year <= :yearTo ");
            params.addValue("yearTo", req.getYearTo());
        }

        boolean hasAvailable = Boolean.TRUE.equals(req.getAvailable());
        boolean hasBranch = req.getBranch() != null && !req.getBranch().isBlank();

        if (hasAvailable && hasBranch) {
            sb.append("AND EXISTS (SELECT 1 FROM items i WHERE i.publication_id = p.id AND i.status = 'AVAILABLE' AND i.branch = :branch) ");
            params.addValue("branch", req.getBranch());
        } else if (hasAvailable) {
            sb.append("AND EXISTS (SELECT 1 FROM items i WHERE i.publication_id = p.id AND i.status = 'AVAILABLE') ");
        } else if (hasBranch) {
            sb.append("AND EXISTS (SELECT 1 FROM items i WHERE i.publication_id = p.id AND i.branch = :branch) ");
            params.addValue("branch", req.getBranch());
        }

        return sb.toString();
    }

    private String buildOrderBy(String sortBy, String keyword) {
        // Khi có keyword, luôn ưu tiên title/subtitle match trước
        String relevancePrefix = "";
        if (keyword != null && !keyword.isBlank()) {
            relevancePrefix = """
                CASE
                    WHEN LOWER(p.title) LIKE :kw THEN 0
                    WHEN LOWER(p.subtitle) LIKE :kw THEN 1
                    ELSE 2
                END ASC,\s""";
        }

        String primarySort = switch (sortBy != null ? sortBy : "newest") {
            case "title_az"      -> "p.title ASC";
            case "most_borrowed" -> "(SELECT COUNT(*) FROM borrowing_transactions bt JOIN items bi ON bi.id = bt.item_id WHERE bi.publication_id = p.id) DESC";
            case "most_viewed"   -> "(SELECT COUNT(*) FROM user_interactions ui WHERE ui.publication_id = p.id AND ui.type = 'WATCH') DESC";
            case "rating"        -> "(SELECT COALESCE(AVG(r.star::numeric), 0) FROM ratings r WHERE r.publication_id = p.id) DESC";
            default              -> "p.publication_year DESC NULLS LAST, p.id DESC";
        };

        return relevancePrefix + primarySort;
    }
}
