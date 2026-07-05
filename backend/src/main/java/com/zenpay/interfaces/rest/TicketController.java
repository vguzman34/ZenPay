package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.*;
import com.zenpay.application.service.TicketService;
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
@RequestMapping("/api/v1/tickets")
@RequiredArgsConstructor
@Tag(name = "Tickets", description = "Support ticket endpoints")
public class TicketController {

    private final TicketService ticketService;
    private final UserRepository userRepository;

    @GetMapping
    @Operation(summary = "Get tickets")
    public ResponseEntity<List<TicketResponse>> getTickets(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ticketService.getTickets(getUserId(userDetails)));
    }

    @PostMapping
    @Operation(summary = "Create ticket")
    public ResponseEntity<TicketResponse> createTicket(@AuthenticationPrincipal UserDetails userDetails,
                                                        @Valid @RequestBody TicketRequest request) {
        return ResponseEntity.ok(ticketService.createTicket(getUserId(userDetails), request));
    }

    @GetMapping("/{id}/messages")
    @Operation(summary = "Get ticket messages")
    public ResponseEntity<List<TicketMessageResponse>> getMessages(@PathVariable UUID id) {
        return ResponseEntity.ok(ticketService.getMessages(id));
    }

    @PostMapping("/{id}/messages")
    @Operation(summary = "Send ticket message")
    public ResponseEntity<TicketMessageResponse> sendMessage(@AuthenticationPrincipal UserDetails userDetails,
                                                              @PathVariable UUID id,
                                                              @Valid @RequestBody TicketMessageRequest request) {
        return ResponseEntity.ok(ticketService.sendMessage(
                id, request, userDetails.getUsername()));
    }

    private UUID getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")).getId();
    }
}
