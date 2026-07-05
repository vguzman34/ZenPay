package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Respuesta de retiro sin tarjeta")
public record CashWithdrawalResponse(
    UUID id,
    String code,
    BigDecimal amount,
    String qrCode,
    String status,
    LocalDateTime expiresAt,
    LocalDateTime createdAt
) {}
