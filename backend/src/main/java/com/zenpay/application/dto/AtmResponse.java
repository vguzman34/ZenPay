package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

@Schema(description = "ATM response")
public record AtmResponse(
        UUID id,
        String name,
        String bankName,
        String bankLogo,
        String address,
        Double latitude,
        Double longitude,
        Double distance,
        String walkingTime,
        String drivingTime,
        Boolean isOpen24Hours,
        String openTime,
        String closeTime,
        Boolean isOpen,
        List<String> services,
        String level
) {}
