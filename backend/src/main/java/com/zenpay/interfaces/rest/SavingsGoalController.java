package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.GoalContributeRequest;
import com.zenpay.application.dto.SavingsGoalResponse;
import com.zenpay.application.service.SavingsGoalService;
import com.zenpay.domain.model.SavingsCategory;
import com.zenpay.domain.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/savings-goals")
@RequiredArgsConstructor
@Tag(name = "Savings Goals", description = "Savings goal endpoints")
public class SavingsGoalController {

    private final SavingsGoalService savingsGoalService;
    private final UserRepository userRepository;

    @GetMapping
    @Operation(summary = "Get all savings goals")
    public ResponseEntity<List<SavingsGoalResponse>> getGoals(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(savingsGoalService.getGoals(getUserId(userDetails)));
    }

    @PostMapping
    @Operation(summary = "Create savings goal")
    public ResponseEntity<SavingsGoalResponse> createGoal(@AuthenticationPrincipal UserDetails userDetails,
                                                           @RequestBody Map<String, Object> body) {
        UUID userId = getUserId(userDetails);
        String name = (String) body.get("name");
        BigDecimal targetAmount = new BigDecimal(body.get("targetAmount").toString());
        LocalDate deadline = body.get("deadline") != null ? LocalDate.parse((String) body.get("deadline")) : null;
        String icon = (String) body.get("icon");
        String colorHex = (String) body.get("colorHex");
        SavingsCategory category = SavingsCategory.valueOf((String) body.get("category"));
        return ResponseEntity.ok(savingsGoalService.createGoal(
                userId, name, targetAmount, deadline, icon, colorHex, category));
    }

    @PostMapping("/{id}/contribute")
    @Operation(summary = "Contribute to goal")
    public ResponseEntity<SavingsGoalResponse> contribute(@PathVariable UUID id,
                                                           @Valid @RequestBody GoalContributeRequest request) {
        return ResponseEntity.ok(savingsGoalService.contributeToGoal(id, request));
    }

    @GetMapping("/{id}/movements")
    @Operation(summary = "Get goal movements")
    public ResponseEntity<List<?>> getMovements(@PathVariable UUID id) {
        return ResponseEntity.ok(savingsGoalService.getGoalMovements(id));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
