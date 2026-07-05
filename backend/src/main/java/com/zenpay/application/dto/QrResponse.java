package com.zenpay.application.dto;

import com.zenpay.domain.model.QrStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "QR response")
public record QrResponse(
        UUID id,
        String qrCode,
        BigDecimal amount,
        String concept,
        QrStatus status,
        LocalDateTime expiresAt
) {}
