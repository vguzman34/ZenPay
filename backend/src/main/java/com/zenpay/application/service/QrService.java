package com.zenpay.application.service;

import com.zenpay.application.dto.QrGenerateRequest;
import com.zenpay.application.dto.QrResponse;
import com.zenpay.domain.model.*;
import com.zenpay.domain.repository.QrPaymentRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QrService {

    private final QrPaymentRepository qrPaymentRepository;

    @Transactional
    public QrResponse generateQr(UUID userId, QrGenerateRequest request) {
        String qrCode = UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase();

        QrPayment qrPayment = QrPayment.builder()
                .user(User.builder().id(userId).build())
                .amount(request.amount())
                .concept(request.concept())
                .qrCode(qrCode)
                .expiresAt(LocalDateTime.now().plusHours(24))
                .build();

        qrPayment = qrPaymentRepository.save(qrPayment);

        return new QrResponse(
                qrPayment.getId(), qrPayment.getQrCode(), qrPayment.getAmount(),
                qrPayment.getConcept(), qrPayment.getStatus(), qrPayment.getExpiresAt());
    }

    @Transactional
    public QrResponse scanQr(UUID userId, String qrCode) {
        List<QrPayment> qrPayments = qrPaymentRepository.findByUserIdOrderByCreatedAtDesc(userId);
        QrPayment qrPayment = qrPayments.stream()
                .filter(q -> q.getQrCode().equals(qrCode) && q.getStatus() == QrStatus.ACTIVE)
                .findFirst()
                .orElseThrow(() -> new BusinessException("QR_NOT_FOUND", "Invalid or expired QR code"));

        if (qrPayment.getExpiresAt() != null && qrPayment.getExpiresAt().isBefore(LocalDateTime.now())) {
            qrPayment.setStatus(QrStatus.EXPIRED);
            qrPaymentRepository.save(qrPayment);
            throw new BusinessException("QR_EXPIRED", "QR code has expired");
        }

        qrPayment.setStatus(QrStatus.USED);
        qrPayment.setCompletedAt(LocalDateTime.now());
        qrPayment = qrPaymentRepository.save(qrPayment);

        return new QrResponse(
                qrPayment.getId(), qrPayment.getQrCode(), qrPayment.getAmount(),
                qrPayment.getConcept(), qrPayment.getStatus(), qrPayment.getExpiresAt());
    }

    public List<QrResponse> getQrHistory(UUID userId) {
        return qrPaymentRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(q -> new QrResponse(
                        q.getId(), q.getQrCode(), q.getAmount(),
                        q.getConcept(), q.getStatus(), q.getExpiresAt()))
                .collect(Collectors.toList());
    }
}
