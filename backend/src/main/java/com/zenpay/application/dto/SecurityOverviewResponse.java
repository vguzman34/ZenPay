package com.zenpay.application.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record SecurityOverviewResponse(
        String securityLevel,
        String protectionStatus,
        LocalDateTime lastAccess,
        String lastActivity,
        int securityScore,
        boolean mfaEnabled,
        String mfaMethod,
        String phoneBackup,
        LocalDateTime passwordLastUpdated,
        String passwordStrength
) {}
