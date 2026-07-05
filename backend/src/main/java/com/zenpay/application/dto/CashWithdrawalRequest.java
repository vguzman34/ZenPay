package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;

@Schema(description = "Solicitud de retiro sin tarjeta")
public record CashWithdrawalRequest(
    @Schema(description = "Monto a retirar", example = "200000")
    @Positive(message = "El monto debe ser positivo")
    BigDecimal amount
) {}
