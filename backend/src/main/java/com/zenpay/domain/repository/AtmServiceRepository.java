package com.zenpay.domain.repository;

import com.zenpay.domain.model.AtmService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AtmServiceRepository extends JpaRepository<AtmService, UUID> {
    List<AtmService> findByAtmId(UUID atmId);
}
