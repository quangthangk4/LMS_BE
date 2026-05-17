package com.library.recommendation.infrastructure.ai;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.library.shared.port.AiPublicationProcessingPort;
import java.time.Duration;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Slf4j
@Service
public class AiGatewayService implements AiPublicationProcessingPort {

    private final RestClient restClient;
    private final RestClient processingRestClient;
    private final JdbcTemplate jdbcTemplate;

    public AiGatewayService(
        @Value("${ai.gateway.base-url:http://localhost:8001}") String baseUrl,
        @Value("${ai.gateway.connect-timeout-ms:1000}") int connectTimeoutMs,
        @Value("${ai.gateway.read-timeout-ms:5000}") int readTimeoutMs,
        @Value("${ai.gateway.processing-read-timeout-ms:180000}") int processingReadTimeoutMs,
        JdbcTemplate jdbcTemplate
    ) {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(Duration.ofMillis(connectTimeoutMs));
        requestFactory.setReadTimeout(Duration.ofMillis(readTimeoutMs));
        SimpleClientHttpRequestFactory processingRequestFactory = new SimpleClientHttpRequestFactory();
        processingRequestFactory.setConnectTimeout(Duration.ofMillis(connectTimeoutMs));
        processingRequestFactory.setReadTimeout(Duration.ofMillis(processingReadTimeoutMs));

        this.restClient = RestClient.builder()
            .baseUrl(baseUrl)
            .requestFactory(requestFactory)
            .build();
        this.processingRestClient = RestClient.builder()
            .baseUrl(baseUrl)
            .requestFactory(processingRequestFactory)
            .build();
        this.jdbcTemplate = jdbcTemplate;
    }

    public AiRecommendationResult getRecommendations(Long userId, int limit) {
        try {
            AiRecommendationRequest request = new AiRecommendationRequest(userId, limit);
            AiRecommendationResult response = restClient.post()
                .uri("/api/v1/recommendations")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .retrieve()
                .body(AiRecommendationResult.class);

            if (response == null) {
                return new AiRecommendationResult(List.of(), "TRENDING_FALLBACK");
            }
            return response;
        } catch (Exception e) {
            log.warn("AI recommendation request failed for userId={}: {}", userId, e.getMessage());
            return new AiRecommendationResult(List.of(), "AI_GATEWAY_UNAVAILABLE");
        }
    }

    public AiRecommendationResult refreshRecommendations(Long userId, int limit) {
        try {
            AiRecommendationRequest request = new AiRecommendationRequest(userId, limit);
            AiRecommendationResult response = restClient.post()
                .uri("/api/v1/recommendations/refresh")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .retrieve()
                .body(AiRecommendationResult.class);

            return response != null ? response : new AiRecommendationResult(List.of(), "TRENDING_FALLBACK");
        } catch (Exception e) {
            log.warn("AI recommendation refresh failed for userId={}: {}", userId, e.getMessage());
            return new AiRecommendationResult(List.of(), "AI_GATEWAY_UNAVAILABLE");
        }
    }

    public AiSemanticSearchResult semanticSearch(String queryText, int limit) {
        try {
            AiSemanticSearchRequest request = new AiSemanticSearchRequest(queryText, limit);
            AiSemanticSearchResult response = restClient.post()
                .uri("/api/v1/semantic-search")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .retrieve()
                .body(AiSemanticSearchResult.class);

            return response != null ? response : new AiSemanticSearchResult(List.of());
        } catch (Exception e) {
            log.warn("AI semantic search request failed: {}", e.getMessage());
            return new AiSemanticSearchResult(List.of());
        }
    }

    public AiSimilarPublicationsResult getSimilarPublications(Long publicationId, int limit) {
        try {
            AiSimilarPublicationsResult response = restClient.get()
                .uri(uriBuilder -> uriBuilder
                    .path("/api/v1/publications/{publicationId}/similar")
                    .queryParam("limit", limit)
                    .build(publicationId))
                .retrieve()
                .body(AiSimilarPublicationsResult.class);

            return response != null ? response : new AiSimilarPublicationsResult(List.of());
        } catch (Exception e) {
            log.warn("AI similar publication request failed for publicationId={}: {}", publicationId, e.getMessage());
            return new AiSimilarPublicationsResult(List.of());
        }
    }

    @Override
    @Async("interactionExecutor")
    public void processPublication(Long publicationId, String pdfUrl, boolean forceReprocess) {
        try {
            AiProcessPublicationRequest request =
                new AiProcessPublicationRequest(publicationId, pdfUrl, forceReprocess);
            AiProcessPublicationResult response = processingRestClient.post()
                .uri("/api/v1/publications/process")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .retrieve()
                .body(AiProcessPublicationResult.class);

            log.info("AI publication process requested: publicationId={}, response={}", publicationId, response);
        } catch (Exception e) {
            log.warn("AI publication process request failed for publicationId={}: {}", publicationId, e.getMessage());
            markAiFailed(publicationId, "Không gửi được yêu cầu xử lý sang AI Service: " + e.getMessage());
        }
    }

    private void markAiFailed(Long publicationId, String errorMessage) {
        try {
            jdbcTemplate.update(
                """
                INSERT INTO ai_engine.publication_etl_runs (
                    publication_id,
                    file_hash,
                    status,
                    error_message,
                    chunks_count,
                    vectors_count,
                    updated_at
                )
                VALUES (?, NULL, 'FAILED', ?, 0, 0, CURRENT_TIMESTAMP)
                ON CONFLICT (publication_id)
                DO UPDATE SET
                    status = 'FAILED',
                    error_message = EXCLUDED.error_message,
                    updated_at = CURRENT_TIMESTAMP
                """,
                publicationId,
                errorMessage.length() > 2000 ? errorMessage.substring(0, 2000) : errorMessage
            );
        } catch (Exception ex) {
            log.warn("Failed to persist AI processing failure for publicationId={}: {}", publicationId, ex.getMessage());
        }
    }

    public record AiRecommendationRequest(
        @JsonProperty("user_id") Long userId,
        Integer limit
    ) {
    }

    public record AiRecommendationResult(
        @JsonProperty("publication_ids") List<Long> publicationIds,
        String strategy
    ) {
    }

    public record AiSemanticSearchRequest(
        @JsonProperty("query_text") String queryText,
        Integer limit
    ) {
    }

    public record AiSemanticSearchResult(
        @JsonProperty("publication_ids") List<Long> publicationIds
    ) {
    }

    public record AiSimilarPublicationsResult(
        @JsonProperty("publication_ids") List<Long> publicationIds
    ) {
    }

    public record AiProcessPublicationRequest(
        @JsonProperty("publication_id") Long publicationId,
        @JsonProperty("pdf_url") String pdfUrl,
        @JsonProperty("force_reprocess") boolean forceReprocess
    ) {
    }

    public record AiProcessPublicationResult(
        @JsonProperty("publication_id") Long publicationId,
        String status,
        boolean skipped,
        int chunks,
        int vectors,
        @JsonProperty("summary_generated") boolean summaryGenerated,
        List<String> tags,
        @JsonProperty("ai_target_audience") String aiTargetAudience,
        String error
    ) {
    }
}
