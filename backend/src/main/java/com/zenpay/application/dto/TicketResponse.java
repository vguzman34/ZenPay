package com.zenpay.application.dto;

import com.zenpay.domain.model.TicketPriority;
import com.zenpay.domain.model.TicketStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Ticket response")
public record TicketResponse(
        UUID id,
        String subject,
        String description,
        TicketStatus status,
        TicketPriority priority,
        String category,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {}
