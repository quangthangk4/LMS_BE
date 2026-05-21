package com.library.circulation.application.transaction.impl;

import com.library.catalog.domain.valueobject.ItemId;
import com.library.circulation.application.policy.CirculationPolicyService;
import com.library.circulation.application.transaction.ConfirmPickupUseCase;
import com.library.circulation.domain.entities.BorrowingTransaction;
import com.library.circulation.domain.enums.TransactionStatus;
import com.library.circulation.domain.valueobject.TransactionId;
import com.library.circulation.dto.response.BorrowTransactionResponse;
import com.library.circulation.infrastructure.persistence.entity.BorrowingTransactionEntity;
import com.library.circulation.infrastructure.persistence.repository.BorrowingTransactionJpaRepository;
import com.library.shared.exception.AppException;
import com.library.shared.exception.ErrorCode;
import com.library.shared.kafka.KafkaTopics;
import com.library.shared.kafka.event.NotificationMessage;
import com.library.user.domain.valueobject.UserId;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ConfirmPickupUseCaseImpl implements ConfirmPickupUseCase {

    private static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private static final DateTimeFormatter DUE_DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final BorrowingTransactionJpaRepository transactionJpaRepository;
    private final com.library.shared.port.ItemStatusPort itemStatusPort;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final com.library.shared.port.UserInteractionPort userInteractionPort;
    private final CirculationPolicyService policyService;

    @Override
    @Transactional
    public BorrowTransactionResponse execute(Long transactionId, Long librarianId) {
        // Infrastructure: load JPA entity
        BorrowingTransactionEntity entity = transactionJpaRepository.findById(transactionId)
            .orElseThrow(() -> new AppException(ErrorCode.TRANSACTION_NOT_FOUND));

        // Infrastructure: lock item
        com.library.shared.port.ItemSnapshot item = itemStatusPort.lockAndGet(entity.getItemId());

        // Reconstruct domain entity from persistence
        BorrowingTransaction transaction = toDomain(entity);

        // Domain: confirmPickup contains invariant (status must be WAITING_FOR_PICKUP)
        LocalDate actualDueDate = LocalDate.now(ZONE).plusDays(policyService.getPolicy().defaultLoanDays());
        transaction.confirmPickup(UserId.of(librarianId), actualDueDate);

        // Infrastructure: update item and persist transaction
        itemStatusPort.updateStatus(entity.getItemId(), "BORROWED");
        applyToEntity(transaction, entity);
        transactionJpaRepository.save(entity);

        // Publish in-app notification
        kafkaTemplate.send(KafkaTopics.NOTIFICATION_SEND, new NotificationMessage(
            entity.getUserId(),
            "PICKUP_CONFIRMED",
            "Sách đã được giao",
            String.format("Bạn đã nhận '%s'. Hạn trả: %s.",
                item.publicationTitle(),
                entity.getDueDate().format(DUE_DATE_FMT)),
            "/userpage/my-books?highlight=" + entity.getId(),
            entity.getId()
        ));

        userInteractionPort.record(entity.getUserId(), item.publicationId(), com.library.shared.port.UserInteractionPort.TYPE_BORROW);
        log.info("Pickup confirmed: transactionId={}, librarianId={}", transactionId, librarianId);

        return BorrowTransactionResponse.builder()
            .transactionId(entity.getId())
            .itemId(entity.getItemId())
            .barcode(item.barcode())
            .publicationId(item.publicationId())
            .publicationTitle(item.publicationTitle())
            .branch(item.branch())
            .location(item.location())
            .dueDate(entity.getDueDate())
            .status(entity.getStatus())
            .build();
    }

    private BorrowingTransaction toDomain(BorrowingTransactionEntity e) {
        return BorrowingTransaction.of(
            TransactionId.of(e.getId()),
            UserId.of(e.getUserId()),
            ItemId.of(e.getItemId()),
            e.getLibrarianIdIssue() != null ? UserId.of(e.getLibrarianIdIssue()) : null,
            e.getLibrarianIdReturn() != null ? UserId.of(e.getLibrarianIdReturn()) : null,
            e.getBorrowedDate(),
            e.getDueDate(),
            e.getReturnedDate(),
            e.getPickedUpDeadline(),
            e.getStatus(),
            e.getRenewalCount() != null ? e.getRenewalCount() : 0
        );
    }

    private void applyToEntity(BorrowingTransaction domain, BorrowingTransactionEntity entity) {
        entity.setStatus(domain.getStatus());
        entity.setBorrowedDate(domain.getBorrowedDate());
        entity.setDueDate(domain.getDueDate());
        entity.setLibrarianIdIssue(
            domain.getLibrarianIdIssue() != null ? domain.getLibrarianIdIssue().getValue() : null);
    }
}
