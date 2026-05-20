package com.library.circulation.application.policy;

import java.math.BigDecimal;
import java.time.Instant;

public record CirculationPolicy(
    Integer pickupDeadlineHours,
    Integer defaultLoanDays,
    Integer maxActiveBorrows,
    Integer maxActiveReservations,
    BigDecimal overdueFinePerDay,
    Boolean blockBorrowWhenUnpaidFines,
    Long updatedByAdminId,
    String updatedByAdminName,
    Instant updatedAt
) {
}
