package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Beneficiary request")
public record BeneficiaryRequest(
        @NotBlank @Schema(example = "Carlos Pérez") String name,
        @NotBlank @Schema(example = "0987654321") String accountNumber,
        @Schema(example = "Davivienda") String bank,
        @Schema(example = "123456789") String documentNumber,
        @Schema(example = "carlos@email.com") String email,
        @Schema(example = "+573001234567") String phone,
        @Schema(example = "Carlos") String alias
) {}
