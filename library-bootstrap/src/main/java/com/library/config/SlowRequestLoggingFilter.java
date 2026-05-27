package com.library.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Slf4j
@Component
public class SlowRequestLoggingFilter extends OncePerRequestFilter {

  private final long thresholdMs;

  public SlowRequestLoggingFilter(
      @Value("${observability.slow-request-threshold-ms:1000}") long thresholdMs) {
    this.thresholdMs = thresholdMs;
  }

  @Override
  protected boolean shouldNotFilter(HttpServletRequest request) {
    String path = request.getRequestURI();
    return path.startsWith("/actuator");
  }

  @Override
  protected void doFilterInternal(
      HttpServletRequest request,
      HttpServletResponse response,
      FilterChain filterChain
  ) throws ServletException, IOException {
    long startedAt = System.nanoTime();
    try {
      filterChain.doFilter(request, response);
    } finally {
      long latencyMs = (System.nanoTime() - startedAt) / 1_000_000L;
      if (latencyMs >= thresholdMs) {
        log.warn(
            "SLOW_REQUEST method={} path={} status={} latencyMs={} remoteAddr={} query='{}'",
            request.getMethod(),
            request.getRequestURI(),
            response.getStatus(),
            latencyMs,
            clientIp(request),
            request.getQueryString() == null ? "" : request.getQueryString());
      }
    }
  }

  private String clientIp(HttpServletRequest request) {
    String forwardedFor = request.getHeader("X-Forwarded-For");
    if (forwardedFor != null && !forwardedFor.isBlank()) {
      return forwardedFor.split(",")[0].trim();
    }
    String realIp = request.getHeader("X-Real-IP");
    return realIp != null && !realIp.isBlank() ? realIp.trim() : request.getRemoteAddr();
  }
}
