package com.zenpay.application.dto;

import com.zenpay.domain.model.Operator;
import com.zenpay.domain.model.RechargeStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Recharge response")
public record RechargeResponse(
        UUID id,
        Operator operator,
        String phoneNumber,
        BigDecimal amount,
        RechargeStatus status,
        LocalDateTime createdAt
) {}
