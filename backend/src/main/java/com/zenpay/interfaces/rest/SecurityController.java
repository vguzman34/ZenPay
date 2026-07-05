package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.*;
import com.zenpay.application.service.SecurityService;
import com.zenpay.domain.model.User;
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
@RequestMapping("/api/v1/security")
@RequiredArgsConstructor
@Tag(name = "Security", description = "Security management endpoints")
public class SecurityController {

    private final SecurityService securityService;
    private final UserRepository userRepository;

    @GetMapping("/overview")
    @Operation(summary = "Get security overview")
    public ResponseEntity<SecurityOverviewResponse> getOverview(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(securityService.getSecurityOverview(getUserId(userDetails)));
    }

    @GetMapping("/sessions")
    @Operation(summary = "Get active sessions")
    public ResponseEntity<List<ActiveSessionResponse>> getActiveSessions(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(securityService.getActiveSessions(getUserId(userDetails)));
    }

    @GetMapping("/alerts")
    @Operation(summary = "Get security alerts")
    public ResponseEntity<List<SecurityAlertResponse>> getSecurityAlerts(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(securityService.getSecurityAlerts(getUserId(userDetails)));
    }

    @DeleteMapping("/sessions/{id}")
    @Operation(summary = "Close a specific session")
    public ResponseEntity<Void> closeSession(@PathVariable UUID id, @AuthenticationPrincipal UserDetails userDetails) {
        securityService.closeSession(id, getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/sessions")
    @Operation(summary = "Close all sessions")
    public ResponseEntity<Void> closeAllSessions(@AuthenticationPrincipal UserDetails userDetails) {
        securityService.closeAllSessions(getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    @PutMapping("/mfa")
    @Operation(summary = "Toggle MFA")
    public ResponseEntity<Void> toggleMfa(@AuthenticationPrincipal UserDetails userDetails) {
        securityService.toggleMfa(getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    private UUID getUserId(UserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getId();
    }
}
