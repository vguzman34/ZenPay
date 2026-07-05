package com.zenpay.application.service;

import com.zenpay.application.dto.*;
import com.zenpay.domain.model.*;
import com.zenpay.domain.repository.AccountRepository;
import com.zenpay.domain.repository.BeneficiaryRepository;
import com.zenpay.domain.repository.TransferRepository;
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
public class TransferService {

    private final TransferRepository transferRepository;
    private final AccountRepository accountRepository;
    private final BeneficiaryRepository beneficiaryRepository;

    @Transactional
    public TransferResponse createTransfer(UUID userId, TransferRequest request) {
        List<Account> accounts = accountRepository.findByUserId(userId);
        Account originAccount = accounts.stream()
                .filter(a -> a.getStatus() == AccountStatus.ACTIVE)
                .findFirst()
                .orElseThrow(() -> new BusinessException("NO_ACTIVE_ACCOUNT", "No active account found"));

        if (originAccount.getAvailableBalance().compareTo(request.amount()) < 0) {
            throw new BusinessException("INSUFFICIENT_BALANCE", "Insufficient available balance");
        }

        originAccount.setBalance(originAccount.getBalance().subtract(request.amount()));
        originAccount.setAvailableBalance(originAccount.getAvailableBalance().subtract(request.amount()));
        accountRepository.save(originAccount);

        Transfer transfer = Transfer.builder()
                .originAccount(originAccount)
                .destinationAccountNumber(request.destinationAccountNumber())
                .destinationBank(request.destinationBank())
                .destinationName(request.destinationName())
                .amount(request.amount())
                .description(request.description())
                .type(request.type() != null ? request.type() : TransferType.THIRD_PARTY)
                .status(TransferStatus.COMPLETED)
                .scheduledDate(request.scheduledDate())
                .completedAt(LocalDateTime.now())
                .build();

        transfer = transferRepository.save(transfer);

        return new TransferResponse(
                transfer.getId(), transfer.getAmount(), transfer.getDescription(),
                transfer.getType(), transfer.getStatus(),
                transfer.getDestinationName(), transfer.getDestinationBank(),
                transfer.getDestinationAccountNumber(), transfer.getScheduledDate(),
                transfer.getFrequency(), transfer.getCreatedAt());
    }

    public List<TransferResponse> getTransfers(UUID userId) {
        return transferRepository.findByOriginAccountUserIdOrderByCreatedAtDesc(userId).stream()
                .map(t -> new TransferResponse(
                        t.getId(), t.getAmount(), t.getDescription(),
                        t.getType(), t.getStatus(),
                        t.getDestinationName(), t.getDestinationBank(),
                        t.getDestinationAccountNumber(), t.getScheduledDate(),
                        t.getFrequency(), t.getCreatedAt()))
                .collect(Collectors.toList());
    }

    @Transactional
    public void cancelTransfer(UUID transferId, UUID userId) {
        Transfer transfer = transferRepository.findById(transferId)
                .orElseThrow(() -> new BusinessException("TRANSFER_NOT_FOUND", "Transfer not found"));
        if (!transfer.getOriginAccount().getUser().getId().equals(userId)) {
            throw new BusinessException("UNAUTHORIZED", "Not authorized to cancel this transfer");
        }
        transfer.setStatus(TransferStatus.CANCELLED);
        transferRepository.save(transfer);
    }

    @Transactional
    public void executeScheduled(UUID transferId, UUID userId) {
        Transfer transfer = transferRepository.findById(transferId)
                .orElseThrow(() -> new BusinessException("TRANSFER_NOT_FOUND", "Transfer not found"));
        if (!transfer.getOriginAccount().getUser().getId().equals(userId)) {
            throw new BusinessException("UNAUTHORIZED", "Not authorized to execute this transfer");
        }
        transfer.setStatus(TransferStatus.COMPLETED);
        transfer.setCompletedAt(LocalDateTime.now());
        transferRepository.save(transfer);
    }

    @Transactional
    public BeneficiaryResponse createBeneficiary(UUID userId, BeneficiaryRequest request) {
        User user = User.builder().id(userId).build();
        Beneficiary beneficiary = Beneficiary.builder()
                .user(user)
                .name(request.name())
                .accountNumber(request.accountNumber())
                .bank(request.bank())
                .documentNumber(request.documentNumber())
                .email(request.email())
                .phone(request.phone())
                .alias(request.alias())
                .build();

        beneficiary = beneficiaryRepository.save(beneficiary);

        return new BeneficiaryResponse(
                beneficiary.getId(), beneficiary.getName(), beneficiary.getAccountNumber(),
                beneficiary.getBank(), beneficiary.getAlias(), beneficiary.getCreatedAt());
    }

    public List<BeneficiaryResponse> getBeneficiaries(UUID userId) {
        return beneficiaryRepository.findByUserId(userId).stream()
                .map(b -> new BeneficiaryResponse(
                        b.getId(), b.getName(), b.getAccountNumber(),
                        b.getBank(), b.getAlias(), b.getCreatedAt()))
                .collect(Collectors.toList());
    }
}
