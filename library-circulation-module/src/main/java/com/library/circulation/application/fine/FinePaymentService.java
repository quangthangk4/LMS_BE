package com.library.circulation.application.fine;

import com.library.circulation.dto.response.FinePaymentLinkResponse;

public interface FinePaymentService {
    FinePaymentLinkResponse createPayOsPaymentLink(String studentId);

    int syncPayOsPayment(Long orderCode);

    int confirmPayOsWebhook(String rawBody);
}
