package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.QrGenerateRequest;
import com.zenpay.application.dto.QrResponse;
import com.zenpay.application.service.QrService;
import com.zenpay.domain.model.User;
import com.zenpay.domain.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/qr")
@RequiredArgsConstructor
@Tag(name = "QR Payments", description = "QR payment endpoints")
public class QrController {

    private final QrService qrService;
    private final UserRepository userRepository;

    @PostMapping("/generate")
    @Operation(summary = "Generate QR code")
    public ResponseEntity<QrResponse> generateQr(@AuthenticationPrincipal UserDetails userDetails,
                                                   @Valid @RequestBody QrGenerateRequest request) {
        return ResponseEntity.ok(qrService.generateQr(getUserId(userDetails), request));
    }

    @PostMapping("/scan")
    @Operation(summary = "Scan QR code")
    public ResponseEntity<QrResponse> scanQr(@AuthenticationPrincipal UserDetails userDetails,
                                               @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(qrService.scanQr(getUserId(userDetails), body.get("qrCode")));
    }

    @GetMapping("/history")
    @Operation(summary = "Get QR history")
    public ResponseEntity<List<QrResponse>> getHistory(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(qrService.getQrHistory(getUserId(userDetails)));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
