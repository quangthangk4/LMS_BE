package com.library.recommendation.presentation.controller;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.library.shared.dto.ApiResponseApp;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/api/ai")
public class AiCallbackController {

    private final JdbcTemplate jdbcTemplate;

    public AiCallbackController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostMapping("/callback")
    public ApiResponseApp<Void> handlePublicationProcessingCallback(@RequestBody AiProcessingCallback payload) {
        if ("SUCCESS".equalsIgnoreCase(payload.status())) {
            log.info("AI publication processing succeeded: bookId={}", payload.bookId());
            updateStatusFromCallback(payload.bookId(), "SUCCESS", null);
        } else {
            log.warn(
                "AI publication processing failed: bookId={}, status={}, error={}",
                payload.bookId(),
                payload.status(),
                payload.error()
            );
            updateStatusFromCallback(payload.bookId(), "FAILED", payload.error());
        }
        return ApiResponseApp.success("AI callback received");
    }

    private void updateStatusFromCallback(Long publicationId, String status, String error) {
        if (publicationId == null) {
            return;
        }
        jdbcTemplate.update(
            """
            INSERT INTO ai_engine.publication_etl_runs (
                publication_id,
                file_hash,
                status,
                error_message,
                updated_at
            )
            VALUES (?, NULL, ?, ?, CURRENT_TIMESTAMP)
            ON CONFLICT (publication_id)
            DO UPDATE SET
                status = EXCLUDED.status,
                error_message = EXCLUDED.error_message,
                updated_at = CURRENT_TIMESTAMP
            """,
            publicationId,
            status,
            error
        );
    }

    public record AiProcessingCallback(
        @JsonProperty("book_id") Long bookId,
        String status,
        String error
    ) {
    }
}
