package com.zenpay.application.service;

import com.zenpay.application.dto.PaymentRequest;
import com.zenpay.application.dto.PaymentResponse;
import com.zenpay.domain.model.*;
import com.zenpay.domain.repository.AccountRepository;
import com.zenpay.domain.repository.PaymentRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final AccountRepository accountRepository;

    @Transactional
    public PaymentResponse createPayment(UUID userId, PaymentRequest request) {
        List<Account> accounts = accountRepository.findByUserId(userId);
        Account account = accounts.stream()
                .filter(a -> a.getStatus() == AccountStatus.ACTIVE)
                .findFirst()
                .orElseThrow(() -> new BusinessException("NO_ACTIVE_ACCOUNT", "No active account found"));

        if (account.getAvailableBalance().compareTo(request.amount()) < 0) {
            throw new BusinessException("INSUFFICIENT_BALANCE", "Insufficient balance");
        }

        account.setBalance(account.getBalance().subtract(request.amount()));
        account.setAvailableBalance(account.getAvailableBalance().subtract(request.amount()));
        accountRepository.save(account);

        User userRef = User.builder().id(userId).build();
        Payment payment = Payment.builder()
                .user(userRef)
                .category(request.category())
                .provider(request.provider())
                .referenceCode(request.referenceCode())
                .amount(request.amount())
                .status(PaymentStatus.COMPLETED)
                .paidAt(LocalDateTime.now())
                .build();

        payment = paymentRepository.save(payment);

        return new PaymentResponse(
                payment.getId(), payment.getCategory(), payment.getProvider(),
                payment.getReferenceCode(), payment.getAmount(),
                payment.getStatus(), payment.getPaidAt());
    }

    public List<PaymentResponse> getPayments(UUID userId) {
        return paymentRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(p -> new PaymentResponse(
                        p.getId(), p.getCategory(), p.getProvider(),
                        p.getReferenceCode(), p.getAmount(),
                        p.getStatus(), p.getPaidAt()))
                .collect(Collectors.toList());
    }
}
