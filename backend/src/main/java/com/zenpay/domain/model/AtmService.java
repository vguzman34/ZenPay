package com.zenpay.domain.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.UUID;

@Entity
@Table(name = "atm_services")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AtmService {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "atm_id", nullable = false)
    @ToString.Exclude
    private Atm atm;

    @Column(nullable = false)
    private String service;
}
