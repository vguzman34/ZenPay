package com.zenpay.domain.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.UUID;

@Entity
@Table(name = "atms")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Atm {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bank_id", nullable = false)
    @ToString.Exclude
    private Bank bank;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String address;

    private Double latitude;

    private Double longitude;

    @Column(name = "open_time")
    private String openTime;

    @Column(name = "close_time")
    private String closeTime;

    @Column(name = "is_open_24_hours")
    @Builder.Default
    private Boolean isOpen24Hours = false;

    @Column(name = "has_withdrawal")
    @Builder.Default
    private Boolean hasWithdrawal = true;

    @Column(name = "has_deposit")
    @Builder.Default
    private Boolean hasDeposit = true;

    private String level;
}
