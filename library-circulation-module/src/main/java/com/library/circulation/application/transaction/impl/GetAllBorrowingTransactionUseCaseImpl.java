package com.library.circulation.application.transaction.impl;

import com.library.circulation.application.transaction.GetAllBorrowingTransactionUseCase;
import com.library.circulation.domain.enums.PaymentStatus;
import com.library.circulation.domain.enums.TransactionStatus;
import com.library.circulation.dto.response.TransactionListResponse;
import com.library.shared.dto.PageResponse;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GetAllBorrowingTransactionUseCaseImpl implements GetAllBorrowingTransactionUseCase {

    private static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public PageResponse<TransactionListResponse> execute(
        int page,
        int size,
        String keyword,
        String status,
        String fineStatus,
        String dateFrom,
        String dateTo,
        String sortBy,
        String sortDir
    ) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.min(Math.max(size, 1), 100);
        String normalizedKeyword = keyword == null ? "" : keyword.trim();
        String normalizedStatus = normalizeEnum(status);
        String normalizedFineStatus = normalizeEnum(fineStatus);

        Instant fromInstant = parseDateStart(dateFrom);
        Instant toInstantExclusive = parseDateEndExclusive(dateTo);

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("keyword", normalizedKeyword, Types.VARCHAR)
            .addValue("limit", safeSize)
            .addValue("offset", safePage * safeSize);

        StringBuilder baseFromWhere = new StringBuilder("""
            FROM borrowing_transactions t
            LEFT JOIN users u ON u.id = t.user_id
            LEFT JOIN LATERAL (
              SELECT
                COALESCE(SUM(fine_amount), 0) AS fine_amount,
                COUNT(*) AS fine_count,
                COUNT(*) FILTER (WHERE payment_status = 'UNPAID') AS unpaid_count,
                STRING_AGG(DISTINCT type, ', ') FILTER (WHERE type IS NOT NULL) AS fine_types
              FROM fines
              WHERE transaction_id = t.id
            ) fa ON TRUE
            LEFT JOIN transaction_notes tn ON tn.transaction_id = t.id
            WHERE (:keyword = ''
                OR LOWER(u.full_name) LIKE LOWER(CONCAT('%', :keyword, '%'))
                OR LOWER(u.student_id) LIKE LOWER(CONCAT('%', :keyword, '%'))
                OR CAST(t.id AS TEXT) LIKE CONCAT('%', :keyword, '%'))
            """);

        if (normalizedStatus != null) {
            baseFromWhere.append(" AND t.status = :status");
            params.addValue("status", normalizedStatus, Types.VARCHAR);
        }
        if (fromInstant != null) {
            baseFromWhere.append(" AND t.borrowed_date >= :dateFrom");
            params.addValue("dateFrom", Timestamp.from(fromInstant));
        }
        if (toInstantExclusive != null) {
            baseFromWhere.append(" AND t.borrowed_date < :dateTo");
            params.addValue("dateTo", Timestamp.from(toInstantExclusive));
        }
        if ("UNPAID".equals(normalizedFineStatus)) {
            baseFromWhere.append(" AND COALESCE(fa.unpaid_count, 0) > 0");
        } else if ("PAID".equals(normalizedFineStatus)) {
            baseFromWhere.append(" AND COALESCE(fa.fine_count, 0) > 0 AND COALESCE(fa.unpaid_count, 0) = 0");
        }

        String sql = """
            SELECT
              t.id AS transaction_id,
              t.user_id,
              u.full_name,
              u.student_id,
              COALESCE(fa.fine_amount, 0) AS fine_amount,
              fa.fine_types,
              CASE
                WHEN COALESCE(fa.fine_count, 0) = 0 THEN NULL
                WHEN COALESCE(fa.unpaid_count, 0) > 0 THEN 'UNPAID'
                ELSE 'PAID'
              END AS fine_payment_status,
              COALESCE(tn.important, FALSE) AS important,
              tn.note,
              t.created_at,
              t.borrowed_date,
              t.due_date,
              t.returned_date,
              t.status
            """ + baseFromWhere + " ORDER BY " + resolveSort(sortBy) + " " + resolveDirection(sortDir) + " LIMIT :limit OFFSET :offset";

        String countSql = "SELECT COUNT(*) FROM (SELECT t.id " + baseFromWhere + ") counted";

        List<TransactionListResponse> content = jdbcTemplate.query(sql, params, (rs, rowNum) ->
            TransactionListResponse.builder()
                .transactionId(rs.getLong("transaction_id"))
                .userId(rs.getLong("user_id"))
                .fullName(rs.getString("full_name"))
                .studentId(rs.getString("student_id"))
                .fineAmount((BigDecimal) rs.getObject("fine_amount"))
                .finePaymentStatus(toPaymentStatus(rs.getString("fine_payment_status")))
                .fineTypes(rs.getString("fine_types"))
                .important(rs.getBoolean("important"))
                .note(rs.getString("note"))
                .createdAt(toInstant(rs.getTimestamp("created_at")))
                .borrowedDate(toInstant(rs.getTimestamp("borrowed_date")))
                .dueDate(toLocalDate(rs.getDate("due_date")))
                .returnedDate(toInstant(rs.getTimestamp("returned_date")))
                .status(TransactionStatus.valueOf(rs.getString("status")))
                .build()
        );

        long totalElements = jdbcTemplate.queryForObject(countSql, params, Long.class);
        int totalPages = (int) Math.ceil((double) totalElements / safeSize);

        return PageResponse.<TransactionListResponse>builder()
            .content(content)
            .currentPage(safePage)
            .pageSize(safeSize)
            .totalElements(totalElements)
            .totalPages(totalPages)
            .isFirst(safePage == 0)
            .isLast(totalPages == 0 || safePage >= totalPages - 1)
            .build();
    }

    private String resolveSort(String sortBy) {
        return switch (sortBy == null ? "" : sortBy) {
            case "borrowedDate" -> "t.borrowed_date";
            case "returnedDate" -> "t.returned_date";
            case "dueDate" -> "t.due_date";
            case "fineAmount" -> "fine_amount";
            default -> "t.created_at";
        };
    }

    private String resolveDirection(String sortDir) {
        return "ASC".equalsIgnoreCase(sortDir) ? "ASC" : "DESC";
    }

    private String normalizeEnum(String value) {
        if (value == null || value.isBlank() || "ALL".equalsIgnoreCase(value)) return null;
        return value.trim().toUpperCase();
    }

    private Instant parseDateStart(String value) {
        if (value == null || value.isBlank()) return null;
        return LocalDate.parse(value).atStartOfDay(ZONE).toInstant();
    }

    private Instant parseDateEndExclusive(String value) {
        if (value == null || value.isBlank()) return null;
        return LocalDate.parse(value).plusDays(1).atStartOfDay(ZONE).toInstant();
    }

    private Instant toInstant(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toInstant();
    }

    private LocalDate toLocalDate(Date date) {
        return date == null ? null : date.toLocalDate();
    }

    private PaymentStatus toPaymentStatus(String value) {
        return value == null ? null : PaymentStatus.valueOf(value);
    }
}
