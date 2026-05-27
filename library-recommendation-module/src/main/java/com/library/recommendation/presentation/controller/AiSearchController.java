package com.library.recommendation.presentation.controller;

import com.library.recommendation.application.ai.SemanticSearchJobService;
import com.library.recommendation.infrastructure.ai.AiGatewayService;
import com.library.shared.dto.ApiResponseApp;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AiSearchController {

    private final AiGatewayService aiGatewayService;
    private final SemanticSearchJobService semanticSearchJobService;

    @PostMapping("/semantic-search")
    public ApiResponseApp<SemanticSearchResponse> semanticSearch(@RequestBody SemanticSearchRequest request) {
        int limit = request.limit() != null ? request.limit() : 10;
        var result = aiGatewayService.semanticSearch(request.queryText(), limit);
        List<String> publicationIds = result.publicationIds().stream()
            .map(String::valueOf)
            .toList();
        return ApiResponseApp.success(new SemanticSearchResponse(publicationIds));
    }

    @PostMapping("/semantic-search/jobs")
    public ApiResponseApp<SemanticSearchJobService.SemanticSearchJob> submitSemanticSearchJob(
        @RequestBody SemanticSearchRequest request,
        HttpServletRequest httpRequest) {
        return ApiResponseApp.success(semanticSearchJobService.submit(
            request.queryText(),
            request.limit(),
            clientKey(httpRequest)));
    }

    @GetMapping("/semantic-search/jobs/{jobId}")
    public ApiResponseApp<SemanticSearchJobService.SemanticSearchJob> getSemanticSearchJob(
        @PathVariable("jobId") String jobId) {
        var job = semanticSearchJobService.get(jobId);
        if (job == null) {
            return ApiResponseApp.success("AI semantic search job not found", null);
        }
        return ApiResponseApp.success(job);
    }

    public record SemanticSearchRequest(String queryText, Integer limit) {
    }

    public record SemanticSearchResponse(List<String> publicationIds) {
    }

    private String clientKey(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        String realIp = request.getHeader("X-Real-IP");
        if (realIp != null && !realIp.isBlank()) {
            return realIp.trim();
        }
        return request.getRemoteAddr();
    }
}
