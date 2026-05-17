package com.library.catalog.application.impl;

import com.library.catalog.application.SaveDocumentUrlUseCase;
import com.library.catalog.infrastructure.persistence.entity.PublicationEntity;
import com.library.catalog.infrastructure.persistence.repository.PublicationJpaRepository;
import com.library.shared.exception.AppException;
import com.library.shared.exception.ErrorCode;
import com.library.shared.port.AiPublicationProcessingPort;
import com.library.shared.port.StoragePort;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

@Slf4j
@Service
@RequiredArgsConstructor
public class SaveDocumentUrlUseCaseImpl implements SaveDocumentUrlUseCase {

    private final PublicationJpaRepository publicationRepository;
    private final StoragePort storagePort;
    private final AiPublicationProcessingPort aiPublicationProcessingPort;
    private final JdbcTemplate jdbcTemplate;

    @Override
    @Transactional
    public String execute(Long publicationId, String s3Key) {
        PublicationEntity publication = publicationRepository.findById(publicationId)
            .orElseThrow(() -> new AppException(ErrorCode.PUBLICATION_NOT_FOUND));

        String fileUrl = storagePort.buildPublicUrl(s3Key);
        publication.setFileUrl(fileUrl);
        publicationRepository.save(publication);
        markAiQueued(publicationId);

        triggerAiProcessingAfterCommit(publicationId, fileUrl);

        log.info("Document URL saved for publication={}: {}", publicationId, fileUrl);
        return fileUrl;
    }

    private void triggerAiProcessingAfterCommit(Long publicationId, String fileUrl) {
        if (!TransactionSynchronizationManager.isSynchronizationActive()) {
            aiPublicationProcessingPort.processPublication(publicationId, fileUrl, true);
            return;
        }

        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                aiPublicationProcessingPort.processPublication(publicationId, fileUrl, true);
            }
        });
    }

    private void markAiQueued(Long publicationId) {
        jdbcTemplate.update(
            """
            INSERT INTO ai_engine.publication_etl_runs (
                publication_id,
                file_hash,
                status,
                error_message,
                chunks_count,
                vectors_count,
                updated_at
            )
            VALUES (?, NULL, 'QUEUED', NULL, 0, 0, CURRENT_TIMESTAMP)
            ON CONFLICT (publication_id)
            DO UPDATE SET
                status = 'QUEUED',
                error_message = NULL,
                chunks_count = 0,
                vectors_count = 0,
                updated_at = CURRENT_TIMESTAMP
            """,
            publicationId
        );
    }
}
