package com.zenpay.application.service;

import com.zenpay.application.dto.AiChatRequest;
import com.zenpay.application.dto.AiChatResponse;
import com.zenpay.application.dto.SavingsGoalResponse;
import com.zenpay.domain.model.Account;
import com.zenpay.domain.model.AccountMovement;
import com.zenpay.domain.model.Card;
import com.zenpay.domain.model.Investment;
import com.zenpay.domain.model.MovementType;
import com.zenpay.domain.model.Payment;
import com.zenpay.domain.model.SavingsGoal;
import com.zenpay.domain.model.Transfer;
import com.zenpay.domain.repository.AccountMovementRepository;
import com.zenpay.domain.repository.AccountRepository;
import com.zenpay.domain.repository.CardRepository;
import com.zenpay.domain.repository.InvestmentRepository;
import com.zenpay.domain.repository.PaymentRepository;
import com.zenpay.domain.repository.SavingsGoalRepository;
import com.zenpay.domain.repository.TransferRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AiAssistantService {

    private final AccountRepository accountRepository;
    private final AccountMovementRepository accountMovementRepository;
    private final CardRepository cardRepository;
    private final TransferRepository transferRepository;
    private final PaymentRepository paymentRepository;
    private final SavingsGoalRepository savingsGoalRepository;
    private final InvestmentRepository investmentRepository;

    public AiChatResponse chat(UUID userId, AiChatRequest request) {
        String message = request.message().toLowerCase();
        
        if (message.contains("saldo") || message.contains("balance")) {
            return getBalanceInfo(userId);
        } else if (message.contains("gast") || message.contains("expense")) {
            return getSpendingAnalysis(userId);
        } else if (message.contains("ingreso") || message.contains("income")) {
            return getIncomeAnalysis(userId);
        } else if (message.contains("transferencia")) {
            return getTransferSummary(userId);
        } else if (message.contains("meta") || message.contains("ahorro")) {
            return getSavingsGoalsSummary(userId);
        } else if (message.contains("inversión") || message.contains("investment")) {
            return getInvestmentSummary(userId);
        } else if (message.contains("tarjeta") || message.contains("card")) {
            return getCardSummary(userId);
        } else if (message.contains("pago") || message.contains("payment")) {
            return getPaymentSummary(userId);
        } else {
            return getGeneralHelp();
        }
    }

    private AiChatResponse getBalanceInfo(UUID userId) {
        List<Account> accounts = accountRepository.findByUserId(userId);
        BigDecimal totalBalance = accounts.stream()
            .map(Account::getBalance)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        Map<String, Object> data = new HashMap<>();
        data.put("totalBalance", totalBalance);
        data.put("accounts", accounts.stream().map(a -> Map.of(
            "type", a.getAccountType().name(),
            "balance", a.getBalance(),
            "currency", a.getCurrency()
        )).collect(Collectors.toList()));
        
        String response = String.format(
            "Tu saldo total es $%,.0f COP distribuido en %d cuentas.",
            totalBalance, accounts.size()
        );
        
        return new AiChatResponse(response, data);
    }

    private AiChatResponse getSpendingAnalysis(UUID userId) {
        List<Account> accounts = accountRepository.findByUserId(userId);
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        
        List<AccountMovement> movements = accounts.stream()
            .flatMap(a -> accountMovementRepository.findByAccountIdAndCreatedAtAfter(a.getId(), monthStart).stream())
            .filter(m -> m.getType() == MovementType.EXPENSE || m.getType() == MovementType.PAYMENT)
            .collect(Collectors.toList());
        
        BigDecimal totalSpent = movements.stream()
            .map(AccountMovement::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        Map<String, BigDecimal> byCategory = movements.stream()
            .collect(Collectors.groupingBy(
                m -> m.getCategory() != null ? m.getCategory() : "Otros",
                Collectors.reducing(BigDecimal.ZERO, AccountMovement::getAmount, BigDecimal::add)
            ));
        
        Map<String, Object> data = new HashMap<>();
        data.put("totalSpent", totalSpent);
        data.put("byCategory", byCategory);
        data.put("transactionCount", movements.size());
        
        String topCategory = byCategory.entrySet().stream()
            .max(Map.Entry.comparingByValue())
            .map(Map.Entry::getKey)
            .orElse("N/A");
        
        String response = String.format(
            "Este mes has gastado $%,.0f COP en %d transacciones. Tu mayor gasto fue en %s.",
            totalSpent, movements.size(), topCategory
        );
        
        return new AiChatResponse(response, data);
    }

    private AiChatResponse getIncomeAnalysis(UUID userId) {
        List<Account> accounts = accountRepository.findByUserId(userId);
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        
        List<AccountMovement> movements = accounts.stream()
            .flatMap(a -> accountMovementRepository.findByAccountIdAndCreatedAtAfter(a.getId(), monthStart).stream())
            .filter(m -> m.getType() == MovementType.INCOME || m.getType() == MovementType.TRANSFER_IN)
            .collect(Collectors.toList());
        
        BigDecimal totalIncome = movements.stream()
            .map(AccountMovement::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        Map<String, Object> data = new HashMap<>();
        data.put("totalIncome", totalIncome);
        data.put("transactionCount", movements.size());
        
        String response = String.format(
            "Este mes has recibido $%,.0f COP en %d transacciones.",
            totalIncome, movements.size()
        );
        
        return new AiChatResponse(response, data);
    }

    private AiChatResponse getTransferSummary(UUID userId) {
        List<Transfer> transfers = transferRepository.findByOriginAccountUserIdOrderByCreatedAtDesc(userId);
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        
        List<Transfer> monthTransfers = transfers.stream()
            .filter(t -> t.getCreatedAt().isAfter(monthStart))
            .collect(Collectors.toList());
        
        BigDecimal totalTransferred = monthTransfers.stream()
            .map(Transfer::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        Map<String, Object> data = new HashMap<>();
        data.put("totalTransferred", totalTransferred);
        data.put("transferCount", monthTransfers.size());
        
        String response = String.format(
            "Este mes has realizado %d transferencias por un total de $%,.0f COP.",
            monthTransfers.size(), totalTransferred
        );
        
        return new AiChatResponse(response, data);
    }

    private AiChatResponse getSavingsGoalsSummary(UUID userId) {
        List<SavingsGoal> goals = savingsGoalRepository.findByUserId(userId);
        
        BigDecimal totalTarget = goals.stream()
            .map(SavingsGoal::getTargetAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal totalSaved = goals.stream()
            .map(SavingsGoal::getCurrentAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal progress = totalTarget.compareTo(BigDecimal.ZERO) > 0
            ? totalSaved.multiply(BigDecimal.valueOf(100)).divide(totalTarget, 2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO;
        
        Map<String, Object> data = new HashMap<>();
        data.put("totalTarget", totalTarget);
        data.put("totalSaved", totalSaved);
        data.put("progress", progress);
        data.put("goalsCount", goals.size());
        
        String response = String.format(
            "Tienes %d metas de ahorro. Has ahorrado $%,.0f COP de $%,.0f COP (%.1f%% completado).",
            goals.size(), totalSaved, totalTarget, progress
        );
        
        return new AiChatResponse(response, data);
    }

    private AiChatResponse getInvestmentSummary(UUID userId) {
        List<Investment> investments = investmentRepository.findByUserId(userId);
        
        BigDecimal totalInvested = investments.stream()
            .map(Investment::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal currentValue = investments.stream()
            .map(Investment::getCurrentValue)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal profit = currentValue.subtract(totalInvested);
        BigDecimal profitPercent = totalInvested.compareTo(BigDecimal.ZERO) > 0
            ? profit.multiply(BigDecimal.valueOf(100)).divide(totalInvested, 2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO;
        
        Map<String, Object> data = new HashMap<>();
        data.put("totalInvested", totalInvested);
        data.put("currentValue", currentValue);
        data.put("profit", profit);
        data.put("profitPercent", profitPercent);
        
        String response = String.format(
            "Tienes $%,.0f COP invertidos con un valor actual de $%,.0f COP (%.1f%% de rendimiento).",
            totalInvested, currentValue, profitPercent
        );
        
        return new AiChatResponse(response, data);
    }

    private AiChatResponse getCardSummary(UUID userId) {
        List<Card> cards = cardRepository.findByUserId(userId);
        
        BigDecimal totalLimit = cards.stream()
            .map(Card::getCreditLimit)
            .filter(Objects::nonNull)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal totalUsed = cards.stream()
            .map(Card::getUsedLimit)
            .filter(Objects::nonNull)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        Map<String, Object> data = new HashMap<>();
        data.put("cardsCount", cards.size());
        data.put("totalLimit", totalLimit);
        data.put("totalUsed", totalUsed);
        
        String response = String.format(
            "Tienes %d tarjetas con un límite total de $%,.0f COP y has usado $%,.0f COP.",
            cards.size(), totalLimit, totalUsed
        );
        
        return new AiChatResponse(response, data);
    }

    private AiChatResponse getPaymentSummary(UUID userId) {
        List<Payment> payments = paymentRepository.findByUserIdOrderByCreatedAtDesc(userId);
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        
        List<Payment> monthPayments = payments.stream()
            .filter(p -> p.getCreatedAt().isAfter(monthStart))
            .collect(Collectors.toList());
        
        BigDecimal totalPaid = monthPayments.stream()
            .map(Payment::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        Map<String, Object> data = new HashMap<>();
        data.put("totalPaid", totalPaid);
        data.put("paymentCount", monthPayments.size());
        
        String response = String.format(
            "Este mes has realizado %d pagos por un total de $%,.0f COP.",
            monthPayments.size(), totalPaid
        );
        
        return new AiChatResponse(response, data);
    }

    private AiChatResponse getGeneralHelp() {
        String response = "Puedo ayudarte con información sobre tu saldo, gastos, ingresos, transferencias, metas de ahorro, inversiones, tarjetas y pagos. ¿Qué te gustaría saber?";
        return new AiChatResponse(response, null);
    }
}
