package com.zenpay.application.service;

import com.zenpay.application.dto.InvestmentResponse;
import com.zenpay.domain.repository.InvestmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InvestmentService {

    private final InvestmentRepository investmentRepository;

    public List<InvestmentResponse> getInvestments(UUID userId) {
        return investmentRepository.findByUserId(userId).stream()
                .map(i -> new InvestmentResponse(
                        i.getId(), i.getType(), i.getName(), i.getAmount(),
                        i.getCurrentValue(), i.getInterestRate(), i.getStartDate(),
                        i.getMaturityDate(), i.getStatus()))
                .collect(Collectors.toList());
    }
}
