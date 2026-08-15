package com.library.user.presentation.controller;

import com.library.shared.constant.RoleConstants;
import com.library.shared.dto.ApiResponseApp;
import com.library.shared.util.RequiresAuthentication;
import com.library.shared.util.RequiresRole;
import com.library.shared.util.SecurityEvaluator;
import com.library.user.application.dto.request.ChangePasswordRequest;
import com.library.user.application.dto.request.CreateUserRequest;
import com.library.user.application.dto.request.UpdateUserProfileRequest;
import com.library.user.application.dto.response.UserResponse;
import com.library.user.application.usecase.user.AssignRoleToUserUseCase;
import com.library.user.application.usecase.user.ChangePasswordUseCase;
import com.library.user.application.usecase.user.CreateUserUseCase;
import com.library.user.application.usecase.user.GetUserByIdUseCase;
import com.library.user.application.usecase.user.UpdateUserProfileUseCase;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST Controller for User management
 * Follows RESTFUL API design principles
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final CreateUserUseCase createUserUseCase;
    private final GetUserByIdUseCase getUserByIdUseCase;
    private final UpdateUserProfileUseCase updateUserProfileUseCase;
    private final ChangePasswordUseCase changePasswordUseCase;
    private final AssignRoleToUserUseCase assignRoleToUserUseCase;
    private final SecurityEvaluator security;

    /**
     * Create a new user
     * POST /api/v1/users
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponseApp<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        log.info("REST request to create user: {}", request.email());
        UserResponse response = createUserUseCase.execute(request);
        return ApiResponseApp.created("create user successfully", response);
    }

    /**
     * Get user by ID
     * GET /api/v1/users/{id}
     */
    @GetMapping("/my-profile")
    @RequiresAuthentication()
    public ApiResponseApp<UserResponse> getUserById() {
        Long userId = security.getCurrentUserId();
        UserResponse response = getUserByIdUseCase.execute(userId);
        return ApiResponseApp.success(response);
    }

    /**
     * Update user profile
     * PUT /api/v1/users/{id}/profile
     */
    @PutMapping("/my-profile")
    @RequiresAuthentication()
    @ResponseStatus(HttpStatus.OK)
    public ApiResponseApp<UserResponse> updateUserProfile(
            @Valid @RequestBody UpdateUserProfileRequest request) {
        Long id = security.getCurrentUserId();
        log.info("REST request to update profile for user ID: {}", id);
        UserResponse response = updateUserProfileUseCase.execute(id, request);
        return ApiResponseApp.success(response);
    }

    @PutMapping("/my-profile/change-password")
    @RequiresAuthentication()
    @ResponseStatus(HttpStatus.OK)
    public ApiResponseApp<Void> changePassword(
            @Valid @RequestBody ChangePasswordRequest request) {
        Long userId = security.getCurrentUserId();
        log.info("REST request to change password for user ID: {}", userId);
        changePasswordUseCase.execute(request, userId);
        return ApiResponseApp.success("Change password successfully");
    }

    @PutMapping("avatar")
    @RequiresAuthentication()
    public ApiResponseApp<String> updateAvatar(){
        return ApiResponseApp.success("update avatar successfully");
    }

    /**
     * Assign a role to user
     * POST /api/v1/users/{userId}/roles/{roleId}
     */
    @PostMapping("/{userId}/roles/{roleId}")
    @RequiresRole(RoleConstants.ADMIN)
    public ApiResponseApp<UserResponse> assignRoleToUser(
            @PathVariable Long userId,
            @PathVariable Long roleId) {
        log.info("REST request to assign role {} to user {}", roleId, userId);
        UserResponse response = assignRoleToUserUseCase.execute(userId, roleId);
        return ApiResponseApp.success(response);
    }
}
