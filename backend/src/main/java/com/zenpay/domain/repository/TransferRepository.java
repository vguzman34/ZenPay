package com.zenpay.domain.repository;

import com.zenpay.domain.model.Transfer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TransferRepository extends JpaRepository<Transfer, UUID> {
    List<Transfer> findByOriginAccountUserIdOrderByCreatedAtDesc(UUID userId);
    List<Transfer> findByOriginAccountUserId(UUID userId);
}
