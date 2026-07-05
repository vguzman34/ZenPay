package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.RechargeRequest;
import com.zenpay.application.dto.RechargeResponse;
import com.zenpay.application.service.RechargeService;
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
@RequestMapping("/api/v1/recharges")
@RequiredArgsConstructor
@Tag(name = "Recharges", description = "Mobile recharge endpoints")
public class RechargeController {

    private final RechargeService rechargeService;
    private final UserRepository userRepository;

    @PostMapping
    @Operation(summary = "Create recharge")
    public ResponseEntity<RechargeResponse> createRecharge(@AuthenticationPrincipal UserDetails userDetails,
                                                            @Valid @RequestBody RechargeRequest request) {
        return ResponseEntity.ok(rechargeService.createRecharge(getUserId(userDetails), request));
    }

    @GetMapping
    @Operation(summary = "Get recharges")
    public ResponseEntity<List<RechargeResponse>> getRecharges(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(rechargeService.getRecharges(getUserId(userDetails)));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
