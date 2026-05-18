package com.library.circulation.application.transaction.impl;

import com.library.catalog.domain.valueobject.ItemId;
import com.library.circulation.application.transaction.ReturnBookUseCase;
import com.library.circulation.domain.entities.BorrowingTransaction;
import com.library.circulation.domain.valueobject.TransactionId;
import com.library.circulation.dto.request.ReturnCommand;
import com.library.circulation.dto.response.ReturnResponse;
import com.library.circulation.infrastructure.persistence.entity.BorrowingTransactionEntity;
import com.library.circulation.infrastructure.persistence.entity.FineEntity;
import com.library.circulation.infrastructure.persistence.repository.BorrowingTransactionJpaRepository;
import com.library.circulation.infrastructure.persistence.repository.FineJpaRepository;
import com.library.shared.exception.AppException;
import com.library.shared.exception.ErrorCode;
import com.library.shared.kafka.KafkaTopics;
import com.library.shared.kafka.event.LibraryEmailMessage;
import com.library.shared.kafka.event.NotificationMessage;
import com.library.shared.port.ItemSnapshot;
import com.library.shared.port.ItemStatusPort;
import com.library.circulation.infrastructure.service.ReservationAssignmentService;
import com.library.shared.util.TsIdGenerator;
import com.library.user.domain.enums.ViolationType;
import com.library.user.domain.valueobject.UserId;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReturnBookUseCaseImpl implements ReturnBookUseCase {

    private static final ZoneId ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final BigDecimal OVERDUE_FINE_PER_DAY = BigDecimal.valueOf(1_000);

    private static final String FIND_ACTIVE_TRANSACTION_SQL = """
        SELECT t.id
        FROM borrowing_transactions t
        WHERE t.item_id = :itemId
          AND t.status IN ('BORROWING', 'OVERDUE')
        ORDER BY t.borrowed_date DESC
        LIMIT 1
        """;

    private final ItemStatusPort itemStatusPort;
    private final BorrowingTransactionJpaRepository transactionJpaRepository;
    private final FineJpaRepository fineJpaRepository;
    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final ReservationAssignmentService reservationAssignmentService;

    @Override
    @Transactional
    public ReturnResponse execute(Long librarianId, ReturnCommand command) {
        // 1. Lock item by barcode
        ItemSnapshot item = itemStatusPort.lockAndGetByBarcode(command.barcode());

        // 2. Find active transaction for this item
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            FIND_ACTIVE_TRANSACTION_SQL, Map.of("itemId", item.id()));
        if (rows.isEmpty()) throw new AppException(ErrorCode.TRANSACTION_NOT_FOUND);
        Long transactionId = ((Number) rows.get(0).get("id")).longValue();

        // 3. Load JPA entity + reconstruct domain
        BorrowingTransactionEntity entity = transactionJpaRepository.findById(transactionId)
            .orElseThrow(() -> new AppException(ErrorCode.TRANSACTION_NOT_FOUND));
        BorrowingTransaction transaction = toDomain(entity);

        // 4. Domain: processReturn (checks BORROWING | OVERDUE invariant)
        Instant now = Instant.now();
        transaction.processReturn(UserId.of(librarianId), now);

        // 5. Update item → AVAILABLE, persist transaction
        itemStatusPort.updateStatus(item.id(), "AVAILABLE");
        applyToEntity(transaction, entity);
        transactionJpaRepository.save(entity);

        // 6. Auto fine if overdue
        LocalDate today = LocalDate.now(ZONE);
        boolean overdue = transaction.isOverdue(today);
        BigDecimal overdueFineAmount = null;
        if (overdue) {
            long daysLate = ChronoUnit.DAYS.between(transaction.getDueDate(), today);
            overdueFineAmount = OVERDUE_FINE_PER_DAY.multiply(BigDecimal.valueOf(daysLate));
            FineEntity fine = FineEntity.builder()
                .transactionId(transactionId)
                .fineAmount(overdueFineAmount)
                .type(ViolationType.OVERDUE_RETURN)
                .build();
            fine.setId(TsIdGenerator.next());
            fineJpaRepository.save(fine);
            log.info("Overdue fine created: transactionId={}, daysLate={}, amount={}",
                transactionId, daysLate, overdueFineAmount);
        }

        // 7. Check if any reservation is waiting for this book
        reservationAssignmentService.tryAssign(item.id(), item.publicationId(), item.branch());

        // 8. Notify + email
        LocalDate returnedDate = today;
        kafkaTemplate.send(KafkaTopics.NOTIFICATION_SEND, new NotificationMessage(
            entity.getUserId(),
            "RETURN_CONFIRMED",
            "Trả sách thành công - mời bạn đánh giá",
            String.format("Bạn đã trả sách '%s' thành công. Hãy chia sẻ trải nghiệm để nhận 5 điểm đóng góp.", item.publicationTitle()),
            String.format("/publicpage/book/%d?review=1", item.publicationId()),
            transactionId
        ));
        kafkaTemplate.send(KafkaTopics.LIBRARY_EMAIL, new LibraryEmailMessage(
            entity.getUserId(),
            LibraryEmailMessage.RETURN_CONFIRMED,
            Map.of("publicationTitle", item.publicationTitle(), "returnDate", returnedDate.toString())
        ));

        log.info("Book returned: transactionId={}, itemId={}, overdue={}", transactionId, item.id(), overdue);

        return ReturnResponse.builder()
            .transactionId(transactionId)
            .publicationTitle(item.publicationTitle())
            .barcode(item.barcode())
            .returnedDate(returnedDate)
            .overdue(overdue)
            .overdueFineAmount(overdueFineAmount)
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
        entity.setReturnedDate(domain.getReturnedDate());
        entity.setLibrarianIdReturn(
            domain.getLibrarianIdReturn() != null ? domain.getLibrarianIdReturn().getValue() : null);
    }
}
