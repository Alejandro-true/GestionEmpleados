package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Entity
@Data
@Table(name = "\"DetalleBoleta\"")
@AllArgsConstructor
@NoArgsConstructor
public class DetalleBoleta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"DetIdDetalle\"")
    private Integer iddetalle;

    @Column(name = "\"DetConcepto\"", nullable = false, length = 255)
    private String concepto;

    @Column(name = "\"DetMonto\"", nullable = false)
    private BigDecimal monto;

    @ManyToOne
    @JoinColumn(name = "\"DetIdBoleta\"")
    private Boleta boleta;
}