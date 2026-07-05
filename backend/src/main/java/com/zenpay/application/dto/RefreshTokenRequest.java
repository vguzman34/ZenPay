package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Refresh token request")
public record RefreshTokenRequest(
        @NotBlank @Schema(example = "eyJhbGciOiJIUzI1NiJ9...") String refreshToken
) {}
