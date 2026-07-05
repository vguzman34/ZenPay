package com.zenpay.application.dto;

import com.zenpay.domain.model.TransferType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Schema(description = "Transfer request")
public record TransferRequest(
        @NotBlank @Schema(example = "1234567890") String destinationAccountNumber,
        @Schema(example = "Bancolombia") String destinationBank,
        @Schema(example = "Carlos Pérez") String destinationName,
        @Positive @Schema(example = "50000") BigDecimal amount,
        @Schema(example = "Pago de servicios") String description,
        TransferType type,
        LocalDateTime scheduledDate
) {}
