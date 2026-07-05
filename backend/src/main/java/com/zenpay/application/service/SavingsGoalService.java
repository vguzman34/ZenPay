package com.zenpay.application.service;

import com.zenpay.application.dto.GoalContributeRequest;
import com.zenpay.application.dto.SavingsGoalResponse;
import com.zenpay.domain.model.*;
import com.zenpay.domain.repository.GoalMovementRepository;
import com.zenpay.domain.repository.SavingsGoalRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SavingsGoalService {

    private final SavingsGoalRepository savingsGoalRepository;
    private final GoalMovementRepository goalMovementRepository;

    public List<SavingsGoalResponse> getGoals(UUID userId) {
        return savingsGoalRepository.findByUserId(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public SavingsGoalResponse createGoal(UUID userId, String name, BigDecimal targetAmount,
                                           LocalDate deadline, String icon, String colorHex,
                                           SavingsCategory category) {
        SavingsGoal goal = SavingsGoal.builder()
                .user(User.builder().id(userId).build())
                .name(name)
                .targetAmount(targetAmount)
                .deadline(deadline)
                .icon(icon)
                .colorHex(colorHex)
                .category(category)
                .build();

        goal = savingsGoalRepository.save(goal);
        return toResponse(goal);
    }

    @Transactional
    public SavingsGoalResponse contributeToGoal(UUID goalId, GoalContributeRequest request) {
        SavingsGoal goal = savingsGoalRepository.findById(goalId)
                .orElseThrow(() -> new BusinessException("GOAL_NOT_FOUND", "Savings goal not found"));

        if (goal.getStatus() != SavingsGoalStatus.ACTIVE) {
            throw new BusinessException("GOAL_NOT_ACTIVE", "Goal is not active");
        }

        BigDecimal newAmount = goal.getCurrentAmount().add(request.amount());
        goal.setCurrentAmount(newAmount);

        if (newAmount.compareTo(goal.getTargetAmount()) >= 0) {
            goal.setStatus(SavingsGoalStatus.COMPLETED);
        }

        goal = savingsGoalRepository.save(goal);

        GoalMovement movement = GoalMovement.builder()
                .goal(goal)
                .amount(request.amount())
                .type(GoalMovementType.DEPOSIT)
                .description(request.description())
                .build();
        goalMovementRepository.save(movement);

        return toResponse(goal);
    }

    public List<?> getGoalMovements(UUID goalId) {
        return goalMovementRepository.findByGoalIdOrderByCreatedAtDesc(goalId);
    }

    private SavingsGoalResponse toResponse(SavingsGoal goal) {
        String progress = goal.getTargetAmount().compareTo(BigDecimal.ZERO) > 0
                ? goal.getCurrentAmount()
                    .multiply(BigDecimal.valueOf(100))
                    .divide(goal.getTargetAmount(), 2, RoundingMode.HALF_UP)
                    .toString() + "%"
                : "0%";

        return new SavingsGoalResponse(
                goal.getId(), goal.getName(), goal.getTargetAmount(),
                goal.getCurrentAmount(), goal.getDeadline(), goal.getIcon(),
                goal.getColorHex(), goal.getCategory(), goal.getStatus(), progress);
    }
}
