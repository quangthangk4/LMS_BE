package com.library.user.application.mapper;

import com.library.user.application.dto.request.UpdateUserProfileCommand;
import com.library.user.application.dto.response.RoleResponse;
import com.library.user.application.dto.response.UserResponse;
import com.library.user.domain.entities.Role;
import com.library.user.domain.entities.User;
import com.library.user.domain.valueobject.UserProfile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface UserMapper {

  /**
   * Map UserAggregate to UserResponse
   */
  @Mapping(target = "id", source = "id.value")
  @Mapping(target = "email", source = "email.value")
  @Mapping(target = "fullName", source = "profile.fullName")
  @Mapping(target = "dateOfBirth", source = "profile.dateOfBirth")
  @Mapping(target = "phoneNumber", source = "profile.phoneNumber")
  @Mapping(target = "address", source = "profile.address")
  @Mapping(target = "profilePictureUrl", source = "profile.profilePictureUrl")
  @Mapping(target = "studentId", source = "profile.studentId")
  @Mapping(target = "faculty", source = "profile.faculty")
  @Mapping(target = "status", source = "status")
  @Mapping(target = "roles", source = "roles")
  @Mapping(target = "creditScore", source = "creditScore")
  @Mapping(target = "contributionScore", source = "contributionScore")
  UserResponse toResponse(User user);

  @Mapping(target = "id", source = "id.value")
  RoleResponse toRoleResponse(Role role);

  /**
   * Helper method to create UserProfile from update
   */
  default UserProfile mergeAndMapToUserProfile(UserProfile currentProfile,
      UpdateUserProfileCommand request) {
    if (request == null) {
      return null;
    }

    return UserProfile.of(
        request.fullName() != null ? request.fullName() : currentProfile.getFullName(),
        request.dateOfBirth() != null ? request.dateOfBirth() : currentProfile.getDateOfBirth(),
        request.phoneNumber() != null ? request.phoneNumber() : currentProfile.getPhoneNumber(),
        request.address() != null ? request.address() : currentProfile.getAddress(),
        currentProfile.getProfilePictureUrl(),
        currentProfile.getStudentId(),
        request.faculty() != null ? request.faculty() : currentProfile.getFaculty()
    );
  }

}
