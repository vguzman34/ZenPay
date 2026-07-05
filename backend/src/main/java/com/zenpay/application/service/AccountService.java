package com.zenpay.application.service;

import com.zenpay.application.dto.AccountMovementResponse;
import com.zenpay.application.dto.AccountResponse;
import com.zenpay.application.dto.DashboardResponse;
import com.zenpay.domain.model.Account;
import com.zenpay.domain.model.AccountMovement;
import com.zenpay.domain.model.MovementType;
import com.zenpay.domain.repository.AccountMovementRepository;
import com.zenpay.domain.repository.AccountRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AccountService {

    private final AccountRepository accountRepository;
    private final AccountMovementRepository accountMovementRepository;

    public List<AccountResponse> getAccounts(UUID userId) {
        return accountRepository.findByUserId(userId).stream()
                .map(this::toAccountResponse)
                .collect(Collectors.toList());
    }

    public AccountResponse getAccountByNumber(String accountNumber) {
        Account account = accountRepository.findByAccountNumber(accountNumber)
                .orElseThrow(() -> new BusinessException("ACCOUNT_NOT_FOUND", "Account not found"));
        return toAccountResponse(account);
    }

    public AccountResponse getAccountById(UUID accountId) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new BusinessException("ACCOUNT_NOT_FOUND", "Account not found"));
        return toAccountResponse(account);
    }

    public List<AccountMovementResponse> getAccountMovements(UUID accountId) {
        return accountMovementRepository.findByAccountIdOrderByCreatedAtDesc(accountId).stream()
                .map(this::toMovementResponse)
                .collect(Collectors.toList());
    }

    public DashboardResponse getDashboard(UUID userId) {
        List<Account> accounts = accountRepository.findByUserId(userId);

        BigDecimal totalBalance = accounts.stream()
                .map(Account::getBalance)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal availableBalance = accounts.stream()
                .map(Account::getAvailableBalance)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        List<AccountMovement> recentMovements = accountMovementRepository
                .findByAccountIdOrderByCreatedAtDesc(
                        accounts.isEmpty() ? null : accounts.get(0).getId())
                .stream()
                .limit(10)
                .collect(Collectors.toList());

        BigDecimal monthlyIncome = recentMovements.stream()
                .filter(m -> m.getType() == MovementType.INCOME || m.getType() == MovementType.TRANSFER_IN)
                .map(AccountMovement::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal monthlyExpenses = recentMovements.stream()
                .filter(m -> m.getType() == MovementType.EXPENSE || m.getType() == MovementType.TRANSFER_OUT
                        || m.getType() == MovementType.PAYMENT || m.getType() == MovementType.CARD_PAYMENT)
                .map(AccountMovement::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return new DashboardResponse(
                totalBalance,
                availableBalance,
                BigDecimal.ZERO,
                monthlyIncome,
                monthlyExpenses,
                monthlyIncome.subtract(monthlyExpenses),
                750,
                recentMovements.stream().map(this::toMovementResponse).collect(Collectors.toList())
        );
    }

    public Account findAccountById(UUID accountId) {
        return accountRepository.findById(accountId)
                .orElseThrow(() -> new BusinessException("ACCOUNT_NOT_FOUND", "Account not found"));
    }

    private AccountResponse toAccountResponse(Account account) {
        return new AccountResponse(
                account.getId(), account.getAccountNumber(), account.getAccountType(),
                account.getCurrency(), account.getBalance(), account.getAvailableBalance(),
                account.getStatus(), account.getCreatedAt());
    }

    private AccountMovementResponse toMovementResponse(AccountMovement m) {
        return new AccountMovementResponse(
                m.getId(), m.getType(), m.getStatus(), m.getAmount(),
                m.getBalanceBefore(), m.getBalanceAfter(), m.getDescription(),
                m.getCategory(), m.getReference(), m.getCounterparty(), m.getCreatedAt());
    }
}
