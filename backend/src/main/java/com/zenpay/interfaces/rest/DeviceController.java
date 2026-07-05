package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.DeviceResponse;
import com.zenpay.application.service.DeviceService;
import com.zenpay.domain.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/devices")
@RequiredArgsConstructor
@Tag(name = "Devices", description = "Device management endpoints")
public class DeviceController {

    private final DeviceService deviceService;
    private final UserRepository userRepository;

    @GetMapping
    @Operation(summary = "Get devices")
    public ResponseEntity<List<DeviceResponse>> getDevices(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(deviceService.getDevices(getUserId(userDetails)));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Remove device")
    public ResponseEntity<Void> removeDevice(@PathVariable UUID id) {
        deviceService.removeDevice(id);
        return ResponseEntity.noContent().build();
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
