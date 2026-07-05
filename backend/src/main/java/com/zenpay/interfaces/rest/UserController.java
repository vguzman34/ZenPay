package com.zenpay.interfaces.rest;

import com.zenpay.application.dto.ChangePasswordRequest;
import com.zenpay.application.dto.UpdateProfileRequest;
import com.zenpay.application.dto.UserResponse;
import com.zenpay.application.service.UserService;
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
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User management endpoints")
public class UserController {

    private final UserService userService;
    private final UserRepository userRepository;

    @GetMapping("/me")
    @Operation(summary = "Get current user profile")
    public ResponseEntity<UserResponse> getProfile(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(userService.getProfile(getUserId(userDetails)));
    }

    @PutMapping("/profile")
    @Operation(summary = "Update profile")
    public ResponseEntity<UserResponse> updateProfile(@AuthenticationPrincipal UserDetails userDetails,
                                                       @Valid @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(userService.updateProfile(getUserId(userDetails), request));
    }

    @PostMapping("/change-password")
    @Operation(summary = "Change password")
    public ResponseEntity<Void> changePassword(@AuthenticationPrincipal UserDetails userDetails,
                                                @Valid @RequestBody ChangePasswordRequest request) {
        userService.changePassword(getUserId(userDetails), request);
        return ResponseEntity.ok().build();
    }

    private UUID getUserId(UserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getId();
    }
}
