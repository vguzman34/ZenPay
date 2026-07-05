package com.zenpay.application.dto;

import com.zenpay.domain.model.MovementStatus;
import com.zenpay.domain.model.MovementType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Account movement response")
public record AccountMovementResponse(
        UUID id,
        MovementType type,
        MovementStatus status,
        BigDecimal amount,
        BigDecimal balanceBefore,
        BigDecimal balanceAfter,
        String description,
        String category,
        String reference,
        String counterparty,
        LocalDateTime createdAt
) {}
