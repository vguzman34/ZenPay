package com.zenpay.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Update profile request")
public record UpdateProfileRequest(
        String fullName,
        String phone,
        String photoUrl
) {}
