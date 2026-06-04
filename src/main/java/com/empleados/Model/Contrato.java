package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Entity
@Data
@Table(name = "\"Contrato\"")
@AllArgsConstructor
@NoArgsConstructor
public class Contrato {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"ConIdContrato\"")
    private Integer idcontrato;

    @Column(name = "\"ConFechaInicio\"", nullable = false)
    private LocalDate fechaInicio;

    @Column(name = "\"ConFechaFin\"")
    private LocalDate fechaFin;

    @Column(name = "\"ConEstado\"", length = 20)
    private String estado;

    @ManyToOne
    @JoinColumn(name = "\"ConIdJornada\"")
    private Jornada jornada;

    @ManyToOne
    @JoinColumn(name = "\"ConCodEmpleado\"")
    private Empleado empleado;

    @ManyToOne
    @JoinColumn(name = "\"ConIdModalidad\"")
    private Modalidad modalidad;
}