package com.zenpay.application.service;

import com.zenpay.application.dto.AtmResponse;
import com.zenpay.domain.model.*;
import com.zenpay.domain.repository.AtmRepository;
import com.zenpay.domain.repository.AtmServiceRepository;
import com.zenpay.domain.repository.UserFavoriteRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AtmService {

    private final AtmRepository atmRepository;
    private final AtmServiceRepository atmServiceRepository;
    private final UserFavoriteRepository userFavoriteRepository;

    public List<AtmResponse> getNearestAtms(Double latitude, Double longitude) {
        return atmRepository.findAll().stream()
                .map(atm -> buildAtmResponse(atm, latitude, longitude))
                .sorted((a, b) -> {
                    if (a.distance() == null) return 1;
                    if (b.distance() == null) return -1;
                    return Double.compare(a.distance(), b.distance());
                })
                .limit(50)
                .collect(Collectors.toList());
    }

    public AtmResponse getAtmById(UUID atmId) {
        Atm atm = atmRepository.findById(atmId)
                .orElseThrow(() -> new BusinessException("ATM_NOT_FOUND", "ATM not found"));
        return buildAtmResponse(atm, null, null);
    }

    @Transactional
    public void toggleFavorite(UUID userId, UUID atmId) {
        if (userFavoriteRepository.existsByUserIdAndAtmId(userId, atmId)) {
            userFavoriteRepository.deleteByUserIdAndAtmId(userId, atmId);
        } else {
            UserFavorite favorite = UserFavorite.builder()
                    .user(User.builder().id(userId).build())
                    .atm(Atm.builder().id(atmId).build())
                    .build();
            userFavoriteRepository.save(favorite);
        }
    }

    public List<AtmResponse> getFavorites(UUID userId) {
        return userFavoriteRepository.findByUserId(userId).stream()
                .map(fav -> buildAtmResponse(fav.getAtm(), null, null))
                .collect(Collectors.toList());
    }

    private AtmResponse buildAtmResponse(Atm atm, Double userLat, Double userLng) {
        List<String> services = atmServiceRepository.findByAtmId(atm.getId()).stream()
                .map(com.zenpay.domain.model.AtmService::getService)
                .collect(Collectors.toList());

        boolean isOpen = checkIfOpen(atm);
        Double distance = calculateDistance(userLat, userLng, atm.getLatitude(), atm.getLongitude());

        return new AtmResponse(
                atm.getId(), atm.getName(), atm.getBank().getName(),
                atm.getBank().getLogoUrl(), atm.getAddress(),
                atm.getLatitude(), atm.getLongitude(),
                distance, null, null,
                atm.getIsOpen24Hours(), atm.getOpenTime(), atm.getCloseTime(),
                isOpen, services, atm.getLevel());
    }

    private boolean checkIfOpen(Atm atm) {
        if (Boolean.TRUE.equals(atm.getIsOpen24Hours())) return true;
        if (atm.getOpenTime() == null || atm.getCloseTime() == null) return true;
        try {
            LocalTime now = LocalTime.now();
            LocalTime open = LocalTime.parse(atm.getOpenTime());
            LocalTime close = LocalTime.parse(atm.getCloseTime());
            return !now.isBefore(open) && !now.isAfter(close);
        } catch (Exception e) {
            return true;
        }
    }

    private Double calculateDistance(Double lat1, Double lng1, Double lat2, Double lng2) {
        if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) return null;
        final int R = 6371;
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lng2 - lng1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
