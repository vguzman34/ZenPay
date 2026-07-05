package com.zenpay.application.dto;

import com.zenpay.domain.model.CardStatus;
import com.zenpay.domain.model.CardType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Card response")
public record CardResponse(
        UUID id,
        CardType cardType,
        CardStatus status,
        String cardNumber,
        String cardHolderName,
        String expirationDate,
        BigDecimal creditLimit,
        BigDecimal usedLimit,
        BigDecimal availableLimit,
        BigDecimal currentBalance,
        Integer paymentDate,
        Integer cutoffDate,
        Boolean isVirtual,
        LocalDateTime issuedAt
) {}
