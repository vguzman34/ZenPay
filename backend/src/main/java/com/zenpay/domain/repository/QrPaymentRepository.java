package com.zenpay.domain.repository;

import com.zenpay.domain.model.QrPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface QrPaymentRepository extends JpaRepository<QrPayment, UUID> {
    List<QrPayment> findByUserIdOrderByCreatedAtDesc(UUID userId);
}
