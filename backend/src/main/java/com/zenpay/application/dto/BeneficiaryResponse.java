package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Beneficiary response")
public record BeneficiaryResponse(
        UUID id,
        String name,
        String accountNumber,
        String bank,
        String alias,
        LocalDateTime createdAt
) {}
