package com.zenpay.application.service;

import com.zenpay.application.dto.DeviceResponse;
import com.zenpay.domain.repository.DeviceRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DeviceService {

    private final DeviceRepository deviceRepository;

    public List<DeviceResponse> getDevices(UUID userId) {
        return deviceRepository.findByUserId(userId).stream()
                .map(d -> new DeviceResponse(
                        d.getId(), d.getDeviceName(), d.getDeviceType(), d.getOs(),
                        d.getBrowser(), d.getIpAddress(), d.getLocation(),
                        d.getIsTrusted(), d.getLastUsedAt()))
                .collect(Collectors.toList());
    }

    @Transactional
    public void removeDevice(UUID deviceId) {
        if (!deviceRepository.existsById(deviceId)) {
            throw new BusinessException("DEVICE_NOT_FOUND", "Device not found");
        }
        deviceRepository.deleteById(deviceId);
    }
}
