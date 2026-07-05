package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.AtmResponse;
import com.zenpay.application.service.AtmService;
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
@RequestMapping("/api/v1/atms")
@RequiredArgsConstructor
@Tag(name = "ATMs", description = "ATM locator endpoints")
public class AtmController {

    private final AtmService atmService;
    private final UserRepository userRepository;

    @GetMapping("/nearest")
    @Operation(summary = "Find nearby ATMs")
    public ResponseEntity<List<AtmResponse>> getNearbyAtms(@RequestParam Double lat,
                                                            @RequestParam Double lng) {
        return ResponseEntity.ok(atmService.getNearestAtms(lat, lng));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get ATM details")
    public ResponseEntity<AtmResponse> getAtmById(@PathVariable UUID id) {
        return ResponseEntity.ok(atmService.getAtmById(id));
    }

    @PostMapping("/{id}/favorite")
    @Operation(summary = "Toggle ATM favorite")
    public ResponseEntity<Void> toggleFavorite(@AuthenticationPrincipal UserDetails userDetails,
                                                @PathVariable UUID id) {
        atmService.toggleFavorite(getUserId(userDetails), id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/favorites")
    @Operation(summary = "Get favorite ATMs")
    public ResponseEntity<List<AtmResponse>> getFavorites(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(atmService.getFavorites(getUserId(userDetails)));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
