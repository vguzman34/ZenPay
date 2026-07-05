package com.zenpay.application.dto;

import com.zenpay.domain.model.Role;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "User response")
public record UserResponse(
        UUID id,
        String email,
        String fullName,
        String phone,
        String photoUrl,
        Role role,
        boolean mfaEnabled,
        LocalDateTime lastLoginAt,
        LocalDateTime createdAt
) {}
