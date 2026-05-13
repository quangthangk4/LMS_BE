package com.library.recommendation.infrastructure.port;

import com.library.recommendation.infrastructure.persistence.entity.UserInteractionEntity;
import com.library.recommendation.infrastructure.persistence.repository.UserInteractionJpaRepository;
import com.library.shared.port.UserInteractionPort;
import com.library.shared.util.TsIdGenerator;
import com.library.user.domain.enums.InteractionType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserInteractionPortImpl implements UserInteractionPort {

    private final UserInteractionJpaRepository interactionRepository;

    @Override
    @Async("interactionExecutor")
    public void record(Long userId, Long publicationId, String interactionType) {
        try {
            InteractionType type = InteractionType.valueOf(interactionType);
            UserInteractionEntity entity = UserInteractionEntity.builder()
                .userId(userId)
                .publicationId(publicationId)
                .type(type)
                .build();
            entity.setId(TsIdGenerator.next());
            interactionRepository.save(entity);
            log.debug("Recorded interaction: userId={}, pubId={}, type={}", userId, publicationId, interactionType);
        } catch (IllegalArgumentException e) {
            log.warn("Unknown interaction type: {}", interactionType);
        }
    }
}
