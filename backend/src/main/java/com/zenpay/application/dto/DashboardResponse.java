package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;

@Schema(description = "Dashboard response")
public record DashboardResponse(
        BigDecimal totalBalance,
        BigDecimal availableBalance,
        BigDecimal savingsBalance,
        BigDecimal monthlyIncome,
        BigDecimal monthlyExpenses,
        BigDecimal cashFlow,
        Integer financialScore,
        List<AccountMovementResponse> recentActivity
) {}
