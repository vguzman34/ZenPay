package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Change password request")
public record ChangePasswordRequest(
        @NotBlank @Schema(example = "currentPassword123") String currentPassword,
        @NotBlank @Size(min = 6, message = "New password must be at least 6 characters") @Schema(example = "newPassword456") String newPassword
) {}
