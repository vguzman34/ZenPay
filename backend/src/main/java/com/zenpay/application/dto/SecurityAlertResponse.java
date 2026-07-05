package com.zenpay.application.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record SecurityAlertResponse(
        UUID id,
        String type,
        String description,
        LocalDateTime date,
        String location,
        String icon
) {}
