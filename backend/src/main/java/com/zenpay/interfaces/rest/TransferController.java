package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.*;
import com.zenpay.application.service.TransferService;
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
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/transfers")
@RequiredArgsConstructor
@Tag(name = "Transfers", description = "Transfer endpoints")
public class TransferController {

    private final TransferService transferService;
    private final UserRepository userRepository;

    @PostMapping
    @Operation(summary = "Create transfer")
    public ResponseEntity<TransferResponse> createTransfer(@AuthenticationPrincipal UserDetails userDetails,
                                                            @Valid @RequestBody TransferRequest request) {
        return ResponseEntity.ok(transferService.createTransfer(getUserId(userDetails), request));
    }

    @GetMapping
    @Operation(summary = "Get transfers")
    public ResponseEntity<List<TransferResponse>> getTransfers(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(transferService.getTransfers(getUserId(userDetails)));
    }

    @PostMapping("/beneficiaries")
    @Operation(summary = "Create beneficiary")
    public ResponseEntity<BeneficiaryResponse> createBeneficiary(@AuthenticationPrincipal UserDetails userDetails,
                                                                  @Valid @RequestBody BeneficiaryRequest request) {
        return ResponseEntity.ok(transferService.createBeneficiary(getUserId(userDetails), request));
    }

    @GetMapping("/beneficiaries")
    @Operation(summary = "Get beneficiaries")
    public ResponseEntity<List<BeneficiaryResponse>> getBeneficiaries(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(transferService.getBeneficiaries(getUserId(userDetails)));
    }

    @PutMapping("/{id}/cancel")
    @Operation(summary = "Cancel a scheduled transfer")
    public ResponseEntity<Void> cancelTransfer(@AuthenticationPrincipal UserDetails userDetails,
                                                @PathVariable UUID id) {
        transferService.cancelTransfer(id, getUserId(userDetails));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/execute")
    @Operation(summary = "Execute a scheduled transfer immediately")
    public ResponseEntity<Void> executeScheduled(@AuthenticationPrincipal UserDetails userDetails,
                                                  @PathVariable UUID id) {
        transferService.executeScheduled(id, getUserId(userDetails));
        return ResponseEntity.noContent().build();
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
