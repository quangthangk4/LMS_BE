package com.library.recommendation.application.ai;

import com.library.recommendation.infrastructure.ai.AiGatewayService;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executor;
import java.util.concurrent.RejectedExecutionException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class SemanticSearchJobService {

  private static final int MAX_LIMIT = 50;
  private static final long JOB_TTL_SECONDS = 600;

  private final AiGatewayService aiGatewayService;
  private final Executor aiSearchExecutor;
  private final Map<String, SemanticSearchJob> jobs = new ConcurrentHashMap<>();

  public SemanticSearchJobService(
      AiGatewayService aiGatewayService,
      @Qualifier("aiSearchExecutor") Executor aiSearchExecutor
  ) {
    this.aiGatewayService = aiGatewayService;
    this.aiSearchExecutor = aiSearchExecutor;
  }

  public SemanticSearchJob submit(String queryText, Integer requestedLimit) {
    pruneExpiredJobs();
    String normalizedQuery = normalizeQuery(queryText);
    int limit = normalizeLimit(requestedLimit);
    String jobId = UUID.randomUUID().toString();
    SemanticSearchJob job = SemanticSearchJob.queued(jobId, normalizedQuery, limit);
    jobs.put(jobId, job);

    try {
      aiSearchExecutor.execute(() -> run(jobId, normalizedQuery, limit));
    } catch (RejectedExecutionException e) {
      SemanticSearchJob rejected = job.failed("AI search queue is full");
      jobs.put(jobId, rejected);
      log.warn("AI semantic search job rejected: jobId={}", jobId);
      return rejected;
    }

    return job;
  }

  public SemanticSearchJob get(String jobId) {
    pruneExpiredJobs();
    return jobs.get(jobId);
  }

  private void run(String jobId, String queryText, int limit) {
    jobs.computeIfPresent(jobId, (id, job) -> job.running());
    long startedAt = System.nanoTime();
    try {
      List<String> publicationIds = aiGatewayService.semanticSearch(queryText, limit)
          .publicationIds()
          .stream()
          .map(String::valueOf)
          .toList();
      long latencyMs = elapsedMs(startedAt);
      jobs.computeIfPresent(jobId, (id, job) -> job.completed(publicationIds, latencyMs));
      log.info("AI semantic search job completed: jobId={}, resultCount={}, latencyMs={}",
          jobId, publicationIds.size(), latencyMs);
    } catch (Exception e) {
      long latencyMs = elapsedMs(startedAt);
      jobs.computeIfPresent(jobId, (id, job) -> job.failed("AI semantic search failed", latencyMs));
      log.warn("AI semantic search job failed: jobId={}, latencyMs={}, error={}",
          jobId, latencyMs, e.getMessage());
    }
  }

  private void pruneExpiredJobs() {
    Instant cutoff = Instant.now().minusSeconds(JOB_TTL_SECONDS);
    jobs.entrySet().removeIf(entry -> entry.getValue().createdAt().isBefore(cutoff));
  }

  private static String normalizeQuery(String queryText) {
    if (queryText == null || queryText.isBlank()) {
      throw new IllegalArgumentException("queryText is required");
    }
    return queryText.trim();
  }

  private static int normalizeLimit(Integer requestedLimit) {
    int limit = requestedLimit != null ? requestedLimit : 10;
    return Math.max(1, Math.min(limit, MAX_LIMIT));
  }

  private static long elapsedMs(long startedAt) {
    return (System.nanoTime() - startedAt) / 1_000_000L;
  }

  public record SemanticSearchJob(
      String jobId,
      String status,
      String queryText,
      int limit,
      List<String> publicationIds,
      String error,
      Long latencyMs,
      Instant createdAt,
      Instant updatedAt
  ) {
    static SemanticSearchJob queued(String jobId, String queryText, int limit) {
      Instant now = Instant.now();
      return new SemanticSearchJob(jobId, "QUEUED", queryText, limit, List.of(), null, null, now, now);
    }

    SemanticSearchJob running() {
      return new SemanticSearchJob(jobId, "RUNNING", queryText, limit, publicationIds, null, null, createdAt, Instant.now());
    }

    SemanticSearchJob completed(List<String> publicationIds, long latencyMs) {
      return new SemanticSearchJob(jobId, "COMPLETED", queryText, limit, publicationIds, null, latencyMs, createdAt, Instant.now());
    }

    SemanticSearchJob failed(String error) {
      return failed(error, null);
    }

    SemanticSearchJob failed(String error, Long latencyMs) {
      return new SemanticSearchJob(jobId, "FAILED", queryText, limit, publicationIds, error, latencyMs, createdAt, Instant.now());
    }
  }
}
