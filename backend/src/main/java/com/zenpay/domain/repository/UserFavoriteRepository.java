package com.zenpay.domain.repository;

import com.zenpay.domain.model.UserFavorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserFavoriteRepository extends JpaRepository<UserFavorite, UUID> {
    List<UserFavorite> findByUserId(UUID userId);
    Optional<UserFavorite> findByUserIdAndAtmId(UUID userId, UUID atmId);
    boolean existsByUserIdAndAtmId(UUID userId, UUID atmId);
    void deleteByUserIdAndAtmId(UUID userId, UUID atmId);
}
