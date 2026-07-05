package com.zenpay.application.service;

import com.zenpay.application.dto.CashWithdrawalRequest;
import com.zenpay.application.dto.CashWithdrawalResponse;
import com.zenpay.domain.model.CashWithdrawal;
import com.zenpay.domain.model.CashWithdrawalStatus;
import com.zenpay.domain.model.User;
import com.zenpay.domain.repository.CashWithdrawalRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CashWithdrawalService {

    private final CashWithdrawalRepository cashWithdrawalRepository;

    @Transactional
    public CashWithdrawalResponse generateCode(UUID userId, CashWithdrawalRequest request) {
        String code = String.format("%06d", new Random().nextInt(999999));

        CashWithdrawal withdrawal = CashWithdrawal.builder()
                .user(User.builder().id(userId).build())
                .code(code)
                .amount(request.amount())
                .status(CashWithdrawalStatus.ACTIVE)
                .expiresAt(LocalDateTime.now().plusMinutes(60))
                .build();

        withdrawal = cashWithdrawalRepository.save(withdrawal);
        return toResponse(withdrawal);
    }

    public List<CashWithdrawalResponse> getWithdrawals(UUID userId) {
        return cashWithdrawalRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public CashWithdrawalResponse redeemCode(UUID id) {
        CashWithdrawal withdrawal = cashWithdrawalRepository.findById(id)
                .orElseThrow(() -> new BusinessException("WITHDRAWAL_NOT_FOUND", "Cash withdrawal not found"));

        if (withdrawal.getStatus() != CashWithdrawalStatus.ACTIVE) {
            throw new BusinessException("WITHDRAWAL_INVALID_STATUS", "Withdrawal is not active");
        }

        if (withdrawal.getExpiresAt().isBefore(LocalDateTime.now())) {
            withdrawal.setStatus(CashWithdrawalStatus.EXPIRED);
            cashWithdrawalRepository.save(withdrawal);
            throw new BusinessException("WITHDRAWAL_EXPIRED", "Cash withdrawal code has expired");
        }

        withdrawal.setStatus(CashWithdrawalStatus.COMPLETED);
        withdrawal.setCompletedAt(LocalDateTime.now());
        withdrawal = cashWithdrawalRepository.save(withdrawal);

        return toResponse(withdrawal);
    }

    @Transactional
    public CashWithdrawalResponse cancelCode(UUID id) {
        CashWithdrawal withdrawal = cashWithdrawalRepository.findById(id)
                .orElseThrow(() -> new BusinessException("WITHDRAWAL_NOT_FOUND", "Cash withdrawal not found"));

        if (withdrawal.getStatus() != CashWithdrawalStatus.ACTIVE) {
            throw new BusinessException("WITHDRAWAL_INVALID_STATUS", "Withdrawal is not active");
        }

        withdrawal.setStatus(CashWithdrawalStatus.CANCELLED);
        withdrawal = cashWithdrawalRepository.save(withdrawal);

        return toResponse(withdrawal);
    }

    private CashWithdrawalResponse toResponse(CashWithdrawal w) {
        return new CashWithdrawalResponse(
                w.getId(), w.getCode(), w.getAmount(), w.getQrCode(),
                w.getStatus().name(), w.getExpiresAt(), w.getCreatedAt());
    }
}
