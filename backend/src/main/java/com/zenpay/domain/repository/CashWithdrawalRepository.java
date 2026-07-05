package com.zenpay.domain.repository;

import com.zenpay.domain.model.CashWithdrawal;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CashWithdrawalRepository extends JpaRepository<CashWithdrawal, UUID> {
    List<CashWithdrawal> findByUserIdOrderByCreatedAtDesc(UUID userId);
    Optional<CashWithdrawal> findByCode(String code);
}
