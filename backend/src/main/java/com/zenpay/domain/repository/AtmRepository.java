package com.zenpay.domain.repository;

import com.zenpay.domain.model.Atm;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AtmRepository extends JpaRepository<Atm, UUID> {
    List<Atm> findByBankId(UUID bankId);
}
