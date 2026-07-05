package com.zenpay.application.service;

import com.zenpay.application.dto.DashboardResponse;
import com.zenpay.domain.model.User;
import com.zenpay.domain.repository.UserRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final AccountService accountService;
    private final UserRepository userRepository;

    public DashboardResponse getDashboardData(UUID userId) {
        if (!userRepository.existsById(userId)) {
            throw new BusinessException("USER_NOT_FOUND", "User not found");
        }
        return accountService.getDashboard(userId);
    }
}
