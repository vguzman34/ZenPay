package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Authentication response")
public record AuthResponse(
        @Schema(example = "eyJhbGciOiJIUzI1NiJ9...") String accessToken,
        @Schema(example = "eyJhbGciOiJIUzI1NiJ9...") String refreshToken,
        @Schema(example = "Bearer") String tokenType,
        @Schema(example = "86400000") long expiresIn
) {}
