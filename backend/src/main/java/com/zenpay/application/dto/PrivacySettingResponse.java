package com.zenpay.application.dto;

public record PrivacySettingResponse(
        String id,
        String label,
        boolean enabled
) {}
