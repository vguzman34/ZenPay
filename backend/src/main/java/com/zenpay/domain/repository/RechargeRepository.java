package com.zenpay.domain.repository;

import com.zenpay.domain.model.Recharge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RechargeRepository extends JpaRepository<Recharge, UUID> {
    List<Recharge> findByUserIdOrderByCreatedAtDesc(UUID userId);
}
