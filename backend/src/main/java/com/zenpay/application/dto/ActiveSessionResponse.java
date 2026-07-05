package com.zenpay.application.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record ActiveSessionResponse(
        UUID id,
        String type,
        String device,
        String ip,
        String location,
        LocalDateTime startedAt,
        String icon
) {}
