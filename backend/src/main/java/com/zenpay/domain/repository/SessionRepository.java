package com.zenpay.domain.repository;

import com.zenpay.domain.model.Session;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SessionRepository extends JpaRepository<Session, UUID> {
    Optional<Session> findByRefreshToken(String refreshToken);
    Optional<Session> findByUserIdAndRefreshToken(UUID userId, String refreshToken);
    List<Session> findByUserId(UUID userId);
    void deleteByUserId(UUID userId);
}
