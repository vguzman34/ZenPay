package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.InstallmentResponse;
import com.zenpay.application.dto.LoanResponse;
import com.zenpay.application.service.LoanService;
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
@RequestMapping("/api/v1/loans")
@RequiredArgsConstructor
@Tag(name = "Loans", description = "Loan endpoints")
public class LoanController {

    private final LoanService loanService;
    private final UserRepository userRepository;

    @GetMapping
    @Operation(summary = "Get all loans")
    public ResponseEntity<List<LoanResponse>> getLoans(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(loanService.getLoans(getUserId(userDetails)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get loan by ID")
    public ResponseEntity<LoanResponse> getLoanById(@PathVariable UUID id) {
        return ResponseEntity.ok(loanService.getLoanById(id));
    }

    @GetMapping("/{id}/installments")
    @Operation(summary = "Get loan installments")
    public ResponseEntity<List<InstallmentResponse>> getInstallments(@PathVariable UUID id) {
        return ResponseEntity.ok(loanService.getInstallments(id));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
