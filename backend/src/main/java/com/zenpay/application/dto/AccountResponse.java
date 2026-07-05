package com.zenpay.application.dto;

import com.zenpay.domain.model.AccountStatus;
import com.zenpay.domain.model.AccountType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Account response")
public record AccountResponse(
        UUID id,
        String accountNumber,
        AccountType accountType,
        String currency,
        BigDecimal balance,
        BigDecimal availableBalance,
        AccountStatus status,
        LocalDateTime createdAt
) {}
