package com.library.circulation.application.transaction;

import com.library.circulation.dto.response.TransactionListResponse;
import com.library.shared.dto.PageResponse;

public interface GetAllBorrowingTransactionUseCase {
    PageResponse<TransactionListResponse> execute(
        int page,
        int size,
        String keyword,
        String status,
        String fineStatus,
        String dateFrom,
        String dateTo,
        String sortBy,
        String sortDir
    );
}
