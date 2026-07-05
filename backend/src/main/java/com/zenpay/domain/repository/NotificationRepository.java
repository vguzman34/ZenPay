package com.zenpay.domain.repository;

import com.zenpay.domain.model.Notification;
import com.zenpay.domain.model.NotificationType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByUserIdOrderByCreatedAtDesc(UUID userId);
    List<Notification> findByUserIdAndTypeOrderByCreatedAtDesc(UUID userId, NotificationType type);
    long countByUserIdAndReadFalse(UUID userId);
}
