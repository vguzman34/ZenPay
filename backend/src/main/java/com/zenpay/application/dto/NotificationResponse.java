package com.zenpay.application.dto;

import com.zenpay.domain.model.NotificationType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Notification response")
public record NotificationResponse(
        UUID id,
        String title,
        String message,
        NotificationType type,
        Boolean read,
        String referenceId,
        String referenceType,
        LocalDateTime createdAt
) {}
