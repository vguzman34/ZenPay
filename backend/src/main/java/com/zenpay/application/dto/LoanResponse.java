package com.zenpay.application.dto;

import com.zenpay.domain.model.LoanStatus;
import com.zenpay.domain.model.LoanType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Schema(description = "Loan response")
public record LoanResponse(
        UUID id,
        LoanType type,
        LoanStatus status,
        BigDecimal totalAmount,
        BigDecimal paidAmount,
        BigDecimal remainingAmount,
        Integer totalInstallments,
        Integer paidInstallments,
        BigDecimal interestRate,
        LocalDate nextPaymentDate,
        BigDecimal nextPaymentAmount,
        String purpose
) {}
