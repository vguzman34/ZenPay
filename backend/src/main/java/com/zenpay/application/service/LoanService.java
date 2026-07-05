package com.zenpay.application.service;

import com.zenpay.application.dto.InstallmentResponse;
import com.zenpay.application.dto.LoanResponse;
import com.zenpay.domain.model.Loan;
import com.zenpay.domain.repository.InstallmentRepository;
import com.zenpay.domain.repository.LoanRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LoanService {

    private final LoanRepository loanRepository;
    private final InstallmentRepository installmentRepository;

    public List<LoanResponse> getLoans(UUID userId) {
        return loanRepository.findByUserId(userId).stream()
                .map(this::toLoanResponse)
                .collect(Collectors.toList());
    }

    public LoanResponse getLoanById(UUID loanId) {
        Loan loan = loanRepository.findById(loanId)
                .orElseThrow(() -> new BusinessException("LOAN_NOT_FOUND", "Loan not found"));
        return toLoanResponse(loan);
    }

    public List<InstallmentResponse> getInstallments(UUID loanId) {
        return installmentRepository.findByLoanIdOrderByNumberAsc(loanId).stream()
                .map(i -> new InstallmentResponse(
                        i.getId(), i.getNumber(), i.getAmount(),
                        i.getDueDate(), i.getPaidDate(), i.getStatus()))
                .collect(Collectors.toList());
    }

    private LoanResponse toLoanResponse(Loan loan) {
        return new LoanResponse(
                loan.getId(), loan.getType(), loan.getStatus(),
                loan.getTotalAmount(), loan.getPaidAmount(), loan.getRemainingAmount(),
                loan.getTotalInstallments(), loan.getPaidInstallments(),
                loan.getInterestRate(), loan.getNextPaymentDate(),
                loan.getNextPaymentAmount(), loan.getPurpose());
    }
}
