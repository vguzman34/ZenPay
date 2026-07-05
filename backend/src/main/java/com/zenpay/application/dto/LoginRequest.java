package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Login request")
public record LoginRequest(
        @NotBlank @Email @Schema(example = "user@zenpay.com") String email,
        @NotBlank @Schema(example = "password123") String password
) {}
