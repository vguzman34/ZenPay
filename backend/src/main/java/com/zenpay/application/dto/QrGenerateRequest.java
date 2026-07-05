package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

@Schema(description = "QR generate request")
public record QrGenerateRequest(
        @Positive @Schema(example = "25000") BigDecimal amount,
        @Schema(example = "Pago de almuerzo") String concept
) {}
