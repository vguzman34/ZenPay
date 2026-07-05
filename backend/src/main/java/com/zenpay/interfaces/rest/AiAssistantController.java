package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.AiChatRequest;
import com.zenpay.application.dto.AiChatResponse;
import com.zenpay.application.service.AiAssistantService;
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

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
@Tag(name = "AI Assistant", description = "AI-powered financial assistant")
public class AiAssistantController {

    private final AiAssistantService aiAssistantService;
    private final UserRepository userRepository;

    @PostMapping("/chat")
    @Operation(summary = "Chat with AI assistant")
    public ResponseEntity<AiChatResponse> chat(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody AiChatRequest request) {
        UUID userId = getUserId(userDetails);
        return ResponseEntity.ok(aiAssistantService.chat(userId, request));
    }

    private UUID getUserId(UserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getId();
    }
}
