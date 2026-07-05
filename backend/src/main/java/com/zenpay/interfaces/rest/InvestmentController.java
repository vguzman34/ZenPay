package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.InvestmentResponse;
import com.zenpay.application.service.InvestmentService;
import com.zenpay.domain.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/investments")
@RequiredArgsConstructor
@Tag(name = "Investments", description = "Investment endpoints")
public class InvestmentController {

    private final InvestmentService investmentService;
    private final UserRepository userRepository;

    @GetMapping
    @Operation(summary = "Get all investments")
    public ResponseEntity<List<InvestmentResponse>> getInvestments(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(investmentService.getInvestments(getUserId(userDetails)));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
