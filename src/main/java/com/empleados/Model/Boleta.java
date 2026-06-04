package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Data
@Table(name = "\"Boleta\"")
@AllArgsConstructor
@NoArgsConstructor
public class Boleta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"BolIdBoleta\"")
    private Integer idboleta;

    @Column(name = "\"BolPeriodo\"", nullable = false, length = 20)
    private String periodo;

    @Column(name = "\"BolFechaEmision\"", nullable = false)
    private LocalDate fechaemision;

    @Column(name = "\"BolTotal\"", nullable = false)
    private BigDecimal total;

    @ManyToOne
    @JoinColumn(name = "\"BolCodEmpleado\"")
    private Empleado empleado;

    @OneToMany(mappedBy = "boleta", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<DetalleBoleta> detalles = new ArrayList<>();
}