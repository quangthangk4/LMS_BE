package com.library.circulation.dto.response;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import com.library.circulation.domain.enums.PaymentStatus;
import com.library.circulation.domain.enums.TransactionStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Data
@Builder
public class TransactionListResponse {
    @JsonSerialize(using = ToStringSerializer.class)
    private Long transactionId;
    @JsonSerialize(using = ToStringSerializer.class)
    private Long userId;
    private String fullName;
    private String studentId;
    private BigDecimal fineAmount;
    private PaymentStatus finePaymentStatus;
    private String fineTypes;
    private Instant createdAt;
    private Instant borrowedDate;
    private LocalDate dueDate;
    private Instant returnedDate;
    private TransactionStatus status;
    private Boolean important;
    private String note;

    public TransactionListResponse(
        Long transactionId,
        Long userId,
        String fullName,
        String studentId,
        BigDecimal fineAmount,
        PaymentStatus finePaymentStatus,
        String fineTypes,
        Instant createdAt,
        Instant borrowedDate,
        LocalDate dueDate,
        Instant returnedDate,
        TransactionStatus status,
        Boolean important,
        String note
    ) {
        this.transactionId = transactionId;
        this.userId = userId;
        this.fullName = fullName;
        this.studentId = studentId;
        this.fineAmount = fineAmount;
        this.finePaymentStatus = finePaymentStatus;
        this.fineTypes = fineTypes;
        this.createdAt = createdAt;
        this.borrowedDate = borrowedDate;
        this.dueDate = dueDate;
        this.returnedDate = returnedDate;
        this.status = status;
        this.important = important;
        this.note = note;
    }

    public TransactionListResponse(
        Long transactionId,
        Long userId,
        String fullName,
        String studentId,
        BigDecimal fineAmount,
        Instant borrowedDate,
        LocalDate dueDate,
        Instant returnedDate,
        TransactionStatus status
    ) {
        this.transactionId = transactionId;
        this.userId = userId;
        this.fullName = fullName;
        this.studentId = studentId;
        this.fineAmount = fineAmount;
        this.borrowedDate = borrowedDate;
        this.dueDate = dueDate;
        this.returnedDate = returnedDate;
        this.status = status;
    }
}
