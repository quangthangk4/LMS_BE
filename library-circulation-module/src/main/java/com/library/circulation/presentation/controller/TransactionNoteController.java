package com.library.circulation.presentation.controller;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import com.library.shared.constant.RoleConstants;
import com.library.shared.dto.ApiResponseApp;
import com.library.shared.util.RequiresRole;
import com.library.shared.util.SecurityEvaluator;
import com.library.shared.util.TsIdGenerator;
import io.swagger.v3.oas.annotations.Operation;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import lombok.Builder;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/transactions/{transactionId}/note")
@RequiredArgsConstructor
public class TransactionNoteController {

  private final NamedParameterJdbcTemplate jdbcTemplate;
  private final SecurityEvaluator security;

  public record UpsertTransactionNoteRequest(Boolean important, String note) {}

  @Builder
  public record TransactionNoteResponse(
      @JsonSerialize(using = ToStringSerializer.class) Long transactionId,
      boolean important,
      String note,
      Instant updatedAt) {}

  @PutMapping
  @RequiresRole(RoleConstants.LIBRARIAN)
  @Operation(summary = "Create or update librarian note for a transaction")
  public ApiResponseApp<TransactionNoteResponse> upsertNote(
      @PathVariable("transactionId") Long transactionId,
      @RequestBody UpsertTransactionNoteRequest request) {
    Long librarianId = security.getCurrentUserId();
    Boolean important = request.important() == null ? Boolean.TRUE : request.important();
    String note = request.note() == null ? "" : request.note().trim();

    jdbcTemplate.update("""
        INSERT INTO transaction_notes (id, created_at, updated_at, transaction_id, librarian_id, important, note)
        VALUES (:id, NOW(), NOW(), :transactionId, :librarianId, :important, :note)
        ON CONFLICT (transaction_id)
        DO UPDATE SET updated_at = NOW(), librarian_id = :librarianId, important = :important, note = :note
        """, Map.of(
        "id", TsIdGenerator.next(),
        "transactionId", transactionId,
        "librarianId", librarianId,
        "important", important,
        "note", note
    ));

    return ApiResponseApp.success(fetchNote(transactionId));
  }

  @DeleteMapping
  @RequiresRole(RoleConstants.LIBRARIAN)
  @Operation(summary = "Delete librarian note for a transaction")
  public ApiResponseApp<Void> deleteNote(@PathVariable("transactionId") Long transactionId) {
    jdbcTemplate.update(
        "DELETE FROM transaction_notes WHERE transaction_id = :transactionId",
        Map.of("transactionId", transactionId));
    return ApiResponseApp.success(null);
  }

  private TransactionNoteResponse fetchNote(Long transactionId) {
    List<TransactionNoteResponse> notes = jdbcTemplate.query("""
        SELECT transaction_id, important, note, updated_at
        FROM transaction_notes
        WHERE transaction_id = :transactionId
        """, Map.of("transactionId", transactionId), (rs, rowNum) ->
        TransactionNoteResponse.builder()
            .transactionId(rs.getLong("transaction_id"))
            .important(rs.getBoolean("important"))
            .note(rs.getString("note"))
            .updatedAt(toInstant(rs.getTimestamp("updated_at")))
            .build()
    );
    return notes.isEmpty()
        ? TransactionNoteResponse.builder().transactionId(transactionId).important(false).note("").updatedAt(null).build()
        : notes.get(0);
  }

  private Instant toInstant(Timestamp timestamp) {
    return timestamp == null ? null : timestamp.toInstant();
  }
}
