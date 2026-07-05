package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "Device response")
public record DeviceResponse(
        UUID id,
        String deviceName,
        String deviceType,
        String os,
        String browser,
        String ipAddress,
        String location,
        Boolean isTrusted,
        LocalDateTime lastUsedAt
) {}
