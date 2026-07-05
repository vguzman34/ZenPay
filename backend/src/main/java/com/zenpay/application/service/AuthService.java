package com.zenpay.application.service;

import com.zenpay.application.dto.*;
import com.zenpay.config.JwtConfig;
import com.zenpay.domain.model.*;
import com.zenpay.domain.repository.SessionRepository;
import com.zenpay.domain.repository.UserRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import com.zenpay.infrastructure.security.JwtTokenProvider;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final SessionRepository sessionRepository;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new BusinessException("EMAIL_EXISTS", "Email already registered");
        }

        User user = User.builder()
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .fullName(request.fullName())
                .phone(request.phone())
                .role(Role.ROLE_USER)
                .build();

        user = userRepository.save(user);

        String accessToken = jwtTokenProvider.generateAccessToken(
                user.getId(), user.getEmail(), List.of(user.getRole().name()));
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId());

        saveSession(user, refreshToken, null);

        return new AuthResponse(accessToken, refreshToken, "Bearer", jwtTokenProvider.getAccessTokenExpiration());
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password()));

        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        String accessToken = jwtTokenProvider.generateAccessToken(
                user.getId(), user.getEmail(), List.of(user.getRole().name()));
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId());

        saveSession(user, refreshToken, null);

        return new AuthResponse(accessToken, refreshToken, "Bearer", jwtTokenProvider.getAccessTokenExpiration());
    }

    public AuthResponse refreshToken(RefreshTokenRequest request) {
        String refreshToken = request.refreshToken();

        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new BusinessException("INVALID_TOKEN", "Invalid or expired refresh token");
        }

        var session = sessionRepository.findByRefreshToken(refreshToken)
                .orElseThrow(() -> new BusinessException("SESSION_NOT_FOUND", "Session not found"));

        User user = session.getUser();

        String newAccessToken = jwtTokenProvider.generateAccessToken(
                user.getId(), user.getEmail(), List.of(user.getRole().name()));
        String newRefreshToken = jwtTokenProvider.generateRefreshToken(user.getId());

        session.setRefreshToken(newRefreshToken);
        session.setLastActivityAt(LocalDateTime.now());
        sessionRepository.save(session);

        return new AuthResponse(newAccessToken, newRefreshToken, "Bearer", jwtTokenProvider.getAccessTokenExpiration());
    }

    @Transactional
    public void logout(String refreshToken, HttpServletRequest request) {
        if (refreshToken != null) {
            sessionRepository.findByRefreshToken(refreshToken)
                    .ifPresent(sessionRepository::delete);
        }
    }

    private void saveSession(User user, String refreshToken, HttpServletRequest request) {
        Session session = Session.builder()
                .user(user)
                .refreshToken(refreshToken)
                .ipAddress(request != null ? request.getRemoteAddr() : "unknown")
                .deviceInfo(request != null ? request.getHeader("User-Agent") : "unknown")
                .expiresAt(LocalDateTime.now().plusDays(7))
                .build();
        sessionRepository.save(session);
    }
}
