package com.zenpay.application.service;

import com.zenpay.application.dto.*;
import com.zenpay.domain.model.*;
import com.zenpay.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SecurityService {

    private final UserRepository userRepository;
    private final SessionRepository sessionRepository;
    private final NotificationRepository notificationRepository;
    private final DeviceRepository deviceRepository;

    public SecurityOverviewResponse getSecurityOverview(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        int score = calculateSecurityScore(user);
        String level = score >= 80 ? "Alto" : score >= 60 ? "Medio" : "Bajo";
        String protection = score >= 80 ? "Protegida" : score >= 60 ? "Parcial" : "Vulnerable";
        String strength = score >= 80 ? "Fuerte" : score >= 60 ? "Moderada" : "Débil";

        return new SecurityOverviewResponse(
                level,
                protection,
                user.getLastLoginAt(),
                "Último acceso: " + (user.getLastLoginAt() != null ? "Hoy" : "N/A"),
                score,
                user.isMfaEnabled(),
                user.isMfaEnabled() ? "Autenticador (Google Authenticator)" : "No configurado",
                maskPhone(user.getPhone()),
                user.getUpdatedAt(),
                strength
        );
    }

    public List<ActiveSessionResponse> getActiveSessions(UUID userId) {
        return sessionRepository.findByUserId(userId).stream()
                .map(s -> new ActiveSessionResponse(
                        s.getId(),
                        parseDeviceType(s.getDeviceInfo()),
                        parseDeviceName(s.getDeviceInfo()),
                        s.getIpAddress(),
                        "Bogotá, Colombia",
                        s.getCreatedAt(),
                        getDeviceIcon(parseDeviceType(s.getDeviceInfo()))
                ))
                .collect(Collectors.toList());
    }

    public List<SecurityAlertResponse> getSecurityAlerts(UUID userId) {
        return notificationRepository.findByUserIdAndTypeOrderByCreatedAtDesc(userId, NotificationType.SECURITY).stream()
                .map(n -> new SecurityAlertResponse(
                        n.getId(),
                        mapAlertType(n.getTitle()),
                        n.getTitle(),
                        n.getCreatedAt(),
                        "Bogotá, Colombia",
                        mapAlertIcon(n.getTitle())
                ))
                .collect(Collectors.toList());
    }

    public void closeSession(UUID sessionId, UUID userId) {
        sessionRepository.findById(sessionId).ifPresent(session -> {
            if (session.getUser().getId().equals(userId)) {
                sessionRepository.delete(session);
            }
        });
    }

    public void closeAllSessions(UUID userId) {
        List<Session> sessions = sessionRepository.findByUserId(userId);
        sessionRepository.deleteAll(sessions);
    }

    public void toggleMfa(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setMfaEnabled(!user.isMfaEnabled());
        userRepository.save(user);
    }

    private int calculateSecurityScore(User user) {
        int score = 50;
        if (user.isMfaEnabled()) score += 20;
        if (user.getPassword() != null && user.getPassword().length() > 10) score += 15;
        if (user.isAccountNonLocked()) score += 10;
        if (user.isEnabled()) score += 5;
        return Math.min(score, 100);
    }

    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) return "***";
        return phone.substring(0, 4) + " *** *** " + phone.substring(phone.length() - 4);
    }

    private String parseDeviceType(String deviceInfo) {
        if (deviceInfo == null) return "Desconocido";
        if (deviceInfo.toLowerCase().contains("mobile") || deviceInfo.toLowerCase().contains("iphone") || deviceInfo.toLowerCase().contains("android")) return "MOBILE";
        if (deviceInfo.toLowerCase().contains("tablet") || deviceInfo.toLowerCase().contains("ipad")) return "TABLET";
        return "DESKTOP";
    }

    private String parseDeviceName(String deviceInfo) {
        if (deviceInfo == null) return "Dispositivo desconocido";
        if (deviceInfo.toLowerCase().contains("chrome")) return "Navegador Chrome";
        if (deviceInfo.toLowerCase().contains("safari")) return "Navegador Safari";
        if (deviceInfo.toLowerCase().contains("iphone")) return "App Móvil iOS";
        if (deviceInfo.toLowerCase().contains("android")) return "App Móvil Android";
        return deviceInfo;
    }

    private String getDeviceIcon(String deviceType) {
        return switch (deviceType) {
            case "MOBILE" -> "smartphone";
            case "TABLET" -> "tablet";
            default -> "desktop_windows";
        };
    }

    private String mapAlertType(String title) {
        if (title == null) return "info";
        if (title.contains("sospechoso") || title.contains("bloqueó")) return "warning";
        if (title.contains("exitoso") || title.contains("activado")) return "success";
        return "info";
    }

    private String mapAlertIcon(String title) {
        if (title == null) return "info";
        if (title.contains("inicio de sesión")) return "login";
        if (title.contains("contraseña")) return "lock";
        if (title.contains("MFA") || title.contains("dos factores")) return "verified_user";
        if (title.contains("dispositivo")) return "devices";
        if (title.contains("ubicación")) return "location_on";
        return "shield";
    }
}
