package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

@Schema(description = "Goal contribution request")
public record GoalContributeRequest(
        @Positive @Schema(example = "50000") BigDecimal amount,
        @Schema(example = "Ahorro semanal") String description
) {}
