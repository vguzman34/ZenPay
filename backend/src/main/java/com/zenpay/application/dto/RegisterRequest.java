package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Register request")
public record RegisterRequest(
        @NotBlank @Email @Schema(example = "user@zenpay.com") String email,
        @NotBlank @Size(min = 6, message = "Password must be at least 6 characters") @Schema(example = "password123") String password,
        @NotBlank @Schema(example = "Vanessa") String fullName,
        @Schema(example = "+573001234567") String phone
) {}
