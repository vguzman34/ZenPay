package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

@Schema(description = "Card limit adjustment request")
public record CardLimitRequest(
        @Positive @Schema(example = "5000000") BigDecimal creditLimit
) {}
