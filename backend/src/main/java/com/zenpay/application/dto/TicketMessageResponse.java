package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Ticket message response")
public record TicketMessageResponse(
        UUID id,
        String message,
        String sender,
        LocalDateTime createdAt
) {}
