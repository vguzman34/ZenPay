package com.zenpay.application.dto;

import com.zenpay.domain.model.InstallmentStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Schema(description = "Installment response")
public record InstallmentResponse(
        UUID id,
        Integer number,
        BigDecimal amount,
        LocalDate dueDate,
        LocalDate paidDate,
        InstallmentStatus status
) {}
