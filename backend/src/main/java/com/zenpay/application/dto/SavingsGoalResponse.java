package com.zenpay.application.dto;

import com.zenpay.domain.model.SavingsCategory;
import com.zenpay.domain.model.SavingsGoalStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Schema(description = "Savings goal response")
public record SavingsGoalResponse(
        UUID id,
        String name,
        BigDecimal targetAmount,
        BigDecimal currentAmount,
        LocalDate deadline,
        String icon,
        String colorHex,
        SavingsCategory category,
        SavingsGoalStatus status,
        String progress
) {}
