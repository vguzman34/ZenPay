package com.zenpay.application.dto;

import com.zenpay.domain.model.TransferFrequency;
import com.zenpay.domain.model.TransferStatus;
import com.zenpay.domain.model.TransferType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Transfer response")
public record TransferResponse(
        UUID id,
        BigDecimal amount,
        String description,
        TransferType type,
        TransferStatus status,
        String destinationName,
        String destinationBank,
        String destinationAccountNumber,
        LocalDateTime scheduledDate,
        TransferFrequency frequency,
        LocalDateTime createdAt
) {}
