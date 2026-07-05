package com.zenpay.domain.repository;

import com.zenpay.domain.model.GoalMovement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface GoalMovementRepository extends JpaRepository<GoalMovement, UUID> {
    List<GoalMovement> findByGoalIdOrderByCreatedAtDesc(UUID goalId);
}
