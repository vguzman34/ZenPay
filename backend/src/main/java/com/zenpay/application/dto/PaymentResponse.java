package com.zenpay.application.dto;

import com.zenpay.domain.model.PaymentCategory;
import com.zenpay.domain.model.PaymentStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Payment response")
public record PaymentResponse(
        UUID id,
        PaymentCategory category,
        String provider,
        String referenceCode,
        BigDecimal amount,
        PaymentStatus status,
        LocalDateTime paidAt
) {}
