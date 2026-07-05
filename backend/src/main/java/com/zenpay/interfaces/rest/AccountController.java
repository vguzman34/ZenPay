package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.AccountMovementResponse;
import com.zenpay.application.dto.AccountResponse;
import com.zenpay.application.service.AccountService;
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
@RequestMapping("/api/v1/accounts")
@RequiredArgsConstructor
@Tag(name = "Accounts", description = "Account management endpoints")
public class AccountController {

    private final AccountService accountService;
    private final UserRepository userRepository;

    @GetMapping
    @Operation(summary = "Get all user accounts")
    public ResponseEntity<List<AccountResponse>> getAccounts(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(accountService.getAccounts(getUserId(userDetails)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get account by ID")
    public ResponseEntity<AccountResponse> getAccountById(@PathVariable UUID id) {
        return ResponseEntity.ok(accountService.getAccountById(id));
    }

    @GetMapping("/{id}/movements")
    @Operation(summary = "Get account movements")
    public ResponseEntity<List<AccountMovementResponse>> getMovements(@PathVariable UUID id) {
        return ResponseEntity.ok(accountService.getAccountMovements(id));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
