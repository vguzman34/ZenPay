package com.zenpay.application.service;

import com.zenpay.application.dto.RechargeRequest;
import com.zenpay.application.dto.RechargeResponse;
import com.zenpay.domain.model.*;
import com.zenpay.domain.repository.AccountRepository;
import com.zenpay.domain.repository.RechargeRepository;
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
public class RechargeService {

    private final RechargeRepository rechargeRepository;
    private final AccountRepository accountRepository;

    @Transactional
    public RechargeResponse createRecharge(UUID userId, RechargeRequest request) {
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

        Recharge recharge = Recharge.builder()
                .user(User.builder().id(userId).build())
                .operator(request.operator())
                .phoneNumber(request.phoneNumber())
                .amount(request.amount())
                .status(RechargeStatus.COMPLETED)
                .completedAt(LocalDateTime.now())
                .build();

        recharge = rechargeRepository.save(recharge);

        return new RechargeResponse(
                recharge.getId(), recharge.getOperator(), recharge.getPhoneNumber(),
                recharge.getAmount(), recharge.getStatus(), recharge.getCreatedAt());
    }

    public List<RechargeResponse> getRecharges(UUID userId) {
        return rechargeRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(r -> new RechargeResponse(
                        r.getId(), r.getOperator(), r.getPhoneNumber(),
                        r.getAmount(), r.getStatus(), r.getCreatedAt()))
                .collect(Collectors.toList());
    }
}
