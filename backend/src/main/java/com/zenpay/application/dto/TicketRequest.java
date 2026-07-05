package com.zenpay.application.dto;

import com.zenpay.domain.model.TicketPriority;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Ticket request")
public record TicketRequest(
        @NotBlank @Schema(example = "Problema con transferencia") String subject,
        @NotBlank @Schema(example = "No puedo realizar una transferencia...") String description,
        TicketPriority priority,
        @Schema(example = "transferencias") String category
) {}
