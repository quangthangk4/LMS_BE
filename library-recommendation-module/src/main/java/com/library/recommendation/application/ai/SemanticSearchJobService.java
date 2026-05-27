package com.library.recommendation.application.ai;

import com.library.recommendation.infrastructure.ai.AiGatewayService;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
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
  private static final long RESULT_CACHE_TTL_SECONDS = 900;
  private static final long RUNNING_TIMEOUT_SECONDS = 45;
  private static final int MAX_JOBS_PER_CLIENT_WINDOW = 20;
  private static final Duration RATE_LIMIT_WINDOW = Duration.ofMinutes(1);

  private final AiGatewayService aiGatewayService;
  private final Executor aiSearchExecutor;
  private final Map<String, SemanticSearchJob> jobs = new ConcurrentHashMap<>();
  private final Map<String, String> inFlightJobIdsByQuery = new ConcurrentHashMap<>();
  private final Map<String, CachedSemanticResult> cachedResultsByQuery = new ConcurrentHashMap<>();
  private final Map<String, Deque<Instant>> submitTimesByClient = new ConcurrentHashMap<>();

  public SemanticSearchJobService(
      AiGatewayService aiGatewayService,
      @Qualifier("aiSearchExecutor") Executor aiSearchExecutor
  ) {
    this.aiGatewayService = aiGatewayService;
    this.aiSearchExecutor = aiSearchExecutor;
  }

  public SemanticSearchJob submit(String queryText, Integer requestedLimit) {
    return submit(queryText, requestedLimit, "anonymous");
  }

  public SemanticSearchJob submit(String queryText, Integer requestedLimit, String clientKey) {
    pruneExpiredJobs();
    String normalizedQuery = normalizeQuery(queryText);
    int limit = normalizeLimit(requestedLimit);
    String queryKey = queryKey(normalizedQuery, limit);

    CachedSemanticResult cached = cachedResultsByQuery.get(queryKey);
    if (cached != null && !cached.isExpired()) {
      String jobId = UUID.randomUUID().toString();
      SemanticSearchJob job = SemanticSearchJob.completedFromCache(
          jobId,
          normalizedQuery,
          limit,
          cached.publicationIds(),
          cached.latencyMs());
      jobs.put(jobId, job);
      return job;
    }

    String inFlightJobId = inFlightJobIdsByQuery.get(queryKey);
    SemanticSearchJob inFlight = inFlightJobId != null ? jobs.get(inFlightJobId) : null;
    if (inFlight != null && inFlight.isActive()) {
      return inFlight;
    }
    inFlightJobIdsByQuery.remove(queryKey, inFlightJobId);

    if (!allowSubmit(clientKey)) {
      String jobId = UUID.randomUUID().toString();
      SemanticSearchJob rejected = SemanticSearchJob.queued(jobId, normalizedQuery, limit)
          .failed("Too many AI semantic search requests. Please wait a moment.");
      jobs.put(jobId, rejected);
      return rejected;
    }

    String jobId = UUID.randomUUID().toString();
    SemanticSearchJob job = SemanticSearchJob.queued(jobId, normalizedQuery, limit);
    jobs.put(jobId, job);
    inFlightJobIdsByQuery.put(queryKey, jobId);

    try {
      aiSearchExecutor.execute(() -> run(jobId, normalizedQuery, limit, queryKey));
    } catch (RejectedExecutionException e) {
      SemanticSearchJob rejected = job.failed("AI search queue is full");
      jobs.put(jobId, rejected);
      inFlightJobIdsByQuery.remove(queryKey, jobId);
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
    run(jobId, queryText, limit, queryKey(queryText, limit));
  }

  private void run(String jobId, String queryText, int limit, String queryKey) {
    jobs.computeIfPresent(jobId, (id, job) -> job.running());
    long startedAt = System.nanoTime();
    try {
      List<String> publicationIds = aiGatewayService.semanticSearch(queryText, limit)
          .publicationIds()
          .stream()
          .map(String::valueOf)
          .toList();
      long latencyMs = elapsedMs(startedAt);
      cachedResultsByQuery.put(queryKey, new CachedSemanticResult(
          publicationIds,
          latencyMs,
          Instant.now().plusSeconds(RESULT_CACHE_TTL_SECONDS)));
      jobs.computeIfPresent(jobId, (id, job) -> job.completed(publicationIds, latencyMs));
      log.info("AI semantic search job completed: jobId={}, resultCount={}, latencyMs={}",
          jobId, publicationIds.size(), latencyMs);
    } catch (Exception e) {
      long latencyMs = elapsedMs(startedAt);
      jobs.computeIfPresent(jobId, (id, job) -> job.failed("AI semantic search failed", latencyMs));
      log.warn("AI semantic search job failed: jobId={}, latencyMs={}, error={}",
          jobId, latencyMs, e.getMessage());
    } finally {
      inFlightJobIdsByQuery.remove(queryKey, jobId);
    }
  }

  private void pruneExpiredJobs() {
    Instant cutoff = Instant.now().minusSeconds(JOB_TTL_SECONDS);
    jobs.entrySet().removeIf(entry -> entry.getValue().createdAt().isBefore(cutoff));
    cachedResultsByQuery.entrySet().removeIf(entry -> entry.getValue().isExpired());
    Instant staleRunningCutoff = Instant.now().minusSeconds(RUNNING_TIMEOUT_SECONDS);
    jobs.replaceAll((id, job) ->
        job.isActive() && job.updatedAt().isBefore(staleRunningCutoff)
            ? job.failed("AI semantic search timed out")
            : job);
    inFlightJobIdsByQuery.entrySet().removeIf(entry -> {
      SemanticSearchJob job = jobs.get(entry.getValue());
      return job == null || !job.isActive();
    });
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

  private boolean allowSubmit(String clientKey) {
    String key = clientKey == null || clientKey.isBlank() ? "anonymous" : clientKey;
    Instant now = Instant.now();
    Instant cutoff = now.minus(RATE_LIMIT_WINDOW);
    Deque<Instant> submissions = submitTimesByClient.computeIfAbsent(key, ignored -> new ArrayDeque<>());
    synchronized (submissions) {
      while (!submissions.isEmpty() && submissions.peekFirst().isBefore(cutoff)) {
        submissions.removeFirst();
      }
      if (submissions.size() >= MAX_JOBS_PER_CLIENT_WINDOW) {
        return false;
      }
      submissions.addLast(now);
      return true;
    }
  }

  private static String queryKey(String queryText, int limit) {
    return normalizeQuery(queryText).toLowerCase() + "|limit=" + limit;
  }

  private static long elapsedMs(long startedAt) {
    return (System.nanoTime() - startedAt) / 1_000_000L;
  }

  private record CachedSemanticResult(List<String> publicationIds, long latencyMs, Instant expiresAt) {
    boolean isExpired() {
      return Instant.now().isAfter(expiresAt);
    }
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

    static SemanticSearchJob completedFromCache(
        String jobId,
        String queryText,
        int limit,
        List<String> publicationIds,
        long latencyMs
    ) {
      Instant now = Instant.now();
      return new SemanticSearchJob(jobId, "COMPLETED", queryText, limit, publicationIds, null, latencyMs, now, now);
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

    boolean isActive() {
      return "QUEUED".equals(status) || "RUNNING".equals(status);
    }
  }
}
