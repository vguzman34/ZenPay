package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.PaymentRequest;
import com.zenpay.application.dto.PaymentResponse;
import com.zenpay.application.service.PaymentService;
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
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Tag(name = "Payments", description = "Payment endpoints")
public class PaymentController {

    private final PaymentService paymentService;
    private final UserRepository userRepository;

    @PostMapping
    @Operation(summary = "Create payment")
    public ResponseEntity<PaymentResponse> createPayment(@AuthenticationPrincipal UserDetails userDetails,
                                                          @Valid @RequestBody PaymentRequest request) {
        return ResponseEntity.ok(paymentService.createPayment(getUserId(userDetails), request));
    }

    @GetMapping
    @Operation(summary = "Get payments")
    public ResponseEntity<List<PaymentResponse>> getPayments(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(paymentService.getPayments(getUserId(userDetails)));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
