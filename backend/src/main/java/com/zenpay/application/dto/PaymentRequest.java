package com.zenpay.application.dto;

import com.zenpay.domain.model.PaymentCategory;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

@Schema(description = "Payment request")
public record PaymentRequest(
        PaymentCategory category,
        @NotBlank @Schema(example = "Enelar") String provider,
        @Schema(example = "REF-001-2024") String referenceCode,
        @Positive @Schema(example = "85000") BigDecimal amount
) {}
