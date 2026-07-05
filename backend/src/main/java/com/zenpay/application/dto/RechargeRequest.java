package com.zenpay.application.dto;

import com.zenpay.domain.model.Operator;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

@Schema(description = "Recharge request")
public record RechargeRequest(
        Operator operator,
        @NotBlank @Schema(example = "+573001234567") String phoneNumber,
        @Positive @Schema(example = "10000") BigDecimal amount
) {}
