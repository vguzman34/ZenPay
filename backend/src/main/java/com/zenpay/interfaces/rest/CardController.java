package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.CardLimitRequest;
import com.zenpay.application.dto.CardResponse;
import com.zenpay.application.service.CardService;
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
@RequestMapping("/api/v1/cards")
@RequiredArgsConstructor
@Tag(name = "Cards", description = "Card management endpoints")
public class CardController {

    private final CardService cardService;
    private final UserRepository userRepository;

    @GetMapping
    @Operation(summary = "Get all cards")
    public ResponseEntity<List<CardResponse>> getCards(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(cardService.getCards(getUserId(userDetails)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get card by ID")
    public ResponseEntity<CardResponse> getCardById(@PathVariable UUID id) {
        return ResponseEntity.ok(cardService.getCardById(id));
    }

    @PatchMapping("/{id}/block")
    @Operation(summary = "Block card")
    public ResponseEntity<CardResponse> blockCard(@PathVariable UUID id) {
        return ResponseEntity.ok(cardService.blockCard(id));
    }

    @PatchMapping("/{id}/unblock")
    @Operation(summary = "Unblock card")
    public ResponseEntity<CardResponse> unblockCard(@PathVariable UUID id) {
        return ResponseEntity.ok(cardService.unblockCard(id));
    }

    @PatchMapping("/{id}/limit")
    @Operation(summary = "Adjust card limit")
    public ResponseEntity<CardResponse> adjustLimit(@PathVariable UUID id,
                                                     @Valid @RequestBody CardLimitRequest request) {
        return ResponseEntity.ok(cardService.adjustLimit(id, request));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
