package com.zenpay.domain.repository;

import com.zenpay.domain.model.AccountMovement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface AccountMovementRepository extends JpaRepository<AccountMovement, UUID> {
    List<AccountMovement> findByAccountIdOrderByCreatedAtDesc(UUID accountId);
    List<AccountMovement> findByAccountIdAndCreatedAtAfter(UUID accountId, LocalDateTime after);
}
