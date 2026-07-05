package com.zenpay.domain.repository;

import com.zenpay.domain.model.Bank;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface BankRepository extends JpaRepository<Bank, UUID> {
    Optional<Bank> findByCode(String code);
}
