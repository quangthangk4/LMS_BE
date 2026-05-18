package com.library.recommendation.application.rating;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.library.recommendation.application.rating.impl.CreatePublicationRatingUseCaseImpl;
import com.library.recommendation.dto.request.CreatePublicationRatingRequest;
import com.library.recommendation.infrastructure.persistence.entity.RatingEntity;
import com.library.recommendation.infrastructure.persistence.repository.RatingJpaRepository;
import com.library.shared.exception.AppException;
import com.library.shared.exception.ErrorCode;
import com.library.shared.port.BorrowingChecker;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;

@ExtendWith(MockitoExtension.class)
@DisplayName("CreatePublicationRatingUseCase — Unit Tests")
class CreatePublicationRatingUseCaseTest {

  @Mock private RatingJpaRepository ratingJpaRepository;
  @Mock private BorrowingChecker borrowingChecker;

  @InjectMocks private CreatePublicationRatingUseCaseImpl useCase;

  private static final Long USER_ID = 1001L;
  private static final Long PUBLICATION_ID = 3001L;

  @Test
  @DisplayName("Tạo đánh giá thành công khi user đã mượn ấn phẩm")
  void createRatingSuccess_whenUserBorrowedPublication() {
    CreatePublicationRatingRequest request = CreatePublicationRatingRequest.builder()
        .star(5)
        .comment("Very useful book")
        .build();
    when(borrowingChecker.hasBorrowedPublication(USER_ID, PUBLICATION_ID)).thenReturn(true);

    useCase.execute(PUBLICATION_ID, USER_ID, request);

    ArgumentCaptor<RatingEntity> ratingCaptor = ArgumentCaptor.forClass(RatingEntity.class);
    verify(ratingJpaRepository).save(ratingCaptor.capture());
    RatingEntity saved = ratingCaptor.getValue();
    assertThat(saved.getId()).isNotNull();
    assertThat(saved.getUserId()).isEqualTo(USER_ID);
    assertThat(saved.getPublicationId()).isEqualTo(PUBLICATION_ID);
    assertThat(saved.getStar()).isEqualTo(5);
    assertThat(saved.getComment()).isEqualTo("Very useful book");
  }

  @Test
  @DisplayName("Ném USER_NOT_BORROWED_PUBLICATION khi user chưa mượn sách")
  void throwNotBorrowed_whenUserHasNoCompletedBorrow() {
    CreatePublicationRatingRequest request = CreatePublicationRatingRequest.builder()
        .star(4)
        .comment("Good")
        .build();
    when(borrowingChecker.hasBorrowedPublication(USER_ID, PUBLICATION_ID)).thenReturn(false);

    assertThatThrownBy(() -> useCase.execute(PUBLICATION_ID, USER_ID, request))
        .isInstanceOf(AppException.class)
        .satisfies(ex -> assertThat(((AppException) ex).getErrorCode())
            .isEqualTo(ErrorCode.USER_NOT_BORROWED_PUBLICATION));

    verify(ratingJpaRepository, never()).save(any());
  }

  @Test
  @DisplayName("Ném RATING_ALREADY_EXISTS khi user đánh giá trùng ấn phẩm")
  void throwRatingAlreadyExists_whenUniqueConstraintViolated() {
    CreatePublicationRatingRequest request = CreatePublicationRatingRequest.builder()
        .star(3)
        .comment("Duplicate")
        .build();
    when(borrowingChecker.hasBorrowedPublication(USER_ID, PUBLICATION_ID)).thenReturn(true);
    when(ratingJpaRepository.save(any(RatingEntity.class)))
        .thenThrow(new DataIntegrityViolationException("uk_user_publication"));

    assertThatThrownBy(() -> useCase.execute(PUBLICATION_ID, USER_ID, request))
        .isInstanceOf(AppException.class)
        .satisfies(ex -> assertThat(((AppException) ex).getErrorCode())
            .isEqualTo(ErrorCode.RATING_ALREADY_EXISTS));
  }
}
