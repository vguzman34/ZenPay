package com.zenpay.application.service;

import com.zenpay.application.dto.ChangePasswordRequest;
import com.zenpay.application.dto.UpdateProfileRequest;
import com.zenpay.application.dto.UserResponse;
import com.zenpay.domain.model.User;
import com.zenpay.domain.repository.UserRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserResponse getProfile(UUID userId) {
        User user = findUserById(userId);
        return toUserResponse(user);
    }

    @Transactional
    public UserResponse updateProfile(UUID userId, UpdateProfileRequest request) {
        User user = findUserById(userId);

        if (request.fullName() != null) {
            user.setFullName(request.fullName());
        }
        if (request.phone() != null) {
            user.setPhone(request.phone());
        }
        if (request.photoUrl() != null) {
            user.setPhotoUrl(request.photoUrl());
        }

        user = userRepository.save(user);
        return toUserResponse(user);
    }

    @Transactional
    public void changePassword(UUID userId, ChangePasswordRequest request) {
        User user = findUserById(userId);

        if (!passwordEncoder.matches(request.currentPassword(), user.getPassword())) {
            throw new BusinessException("INVALID_PASSWORD", "Current password is incorrect");
        }

        user.setPassword(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);
    }

    public User getCurrentUser(UUID userId) {
        return findUserById(userId);
    }

    private User findUserById(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));
    }

    private UserResponse toUserResponse(User user) {
        return new UserResponse(
                user.getId(), user.getEmail(), user.getFullName(),
                user.getPhone(), user.getPhotoUrl(), user.getRole(),
                user.isMfaEnabled(), user.getLastLoginAt(), user.getCreatedAt());
    }
}
