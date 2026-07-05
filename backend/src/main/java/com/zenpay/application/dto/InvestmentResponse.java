package com.zenpay.application.dto;

import com.zenpay.domain.model.InvestmentStatus;
import com.zenpay.domain.model.InvestmentType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Schema(description = "Investment response")
public record InvestmentResponse(
        UUID id,
        InvestmentType type,
        String name,
        BigDecimal amount,
        BigDecimal currentValue,
        BigDecimal interestRate,
        LocalDate startDate,
        LocalDate maturityDate,
        InvestmentStatus status
) {}
