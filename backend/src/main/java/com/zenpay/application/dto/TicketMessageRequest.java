package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Ticket message request")
public record TicketMessageRequest(
        @NotBlank @Schema(example = "Necesito ayuda con este problema...") String message
) {}
