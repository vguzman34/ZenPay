package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.CashWithdrawalRequest;
import com.zenpay.application.dto.CashWithdrawalResponse;
import com.zenpay.application.service.CashWithdrawalService;
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
@RequestMapping("/api/v1/cash-withdrawals")
@RequiredArgsConstructor
@Tag(name = "Cash Withdrawals", description = "Cash withdrawal (retiro sin tarjeta) endpoints")
public class CashWithdrawalController {

    private final CashWithdrawalService cashWithdrawalService;
    private final UserRepository userRepository;

    @PostMapping("/generate")
    @Operation(summary = "Generate cash withdrawal code")
    public ResponseEntity<CashWithdrawalResponse> generateCode(@AuthenticationPrincipal UserDetails userDetails,
                                                                @Valid @RequestBody CashWithdrawalRequest request) {
        return ResponseEntity.ok(cashWithdrawalService.generateCode(getUserId(userDetails), request));
    }

    @GetMapping
    @Operation(summary = "Get cash withdrawal history")
    public ResponseEntity<List<CashWithdrawalResponse>> getWithdrawals(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(cashWithdrawalService.getWithdrawals(getUserId(userDetails)));
    }

    @PostMapping("/{id}/redeem")
    @Operation(summary = "Redeem cash withdrawal code")
    public ResponseEntity<CashWithdrawalResponse> redeemCode(@PathVariable UUID id) {
        return ResponseEntity.ok(cashWithdrawalService.redeemCode(id));
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "Cancel cash withdrawal")
    public ResponseEntity<CashWithdrawalResponse> cancelCode(@PathVariable UUID id) {
        return ResponseEntity.ok(cashWithdrawalService.cancelCode(id));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
