package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "\"AuditoriaLog\"")
@AllArgsConstructor
@NoArgsConstructor
public class AuditoriaSalario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"AudIdLog\"")
    private Integer idauditoria;

    @Column(name = "\"AudFecha\"")
    private LocalDateTime fechaModificacion;

    @Column(name = "\"AudUsuario\"", nullable = false, length = 50)
    private String usuarioModifico;

    @Column(name = "\"AudAreIdArea\"", nullable = false)
    private Integer audAreIdArea;

    @Column(name = "\"AudNombreArea\"", nullable = false, length = 50)
    private String audNombreArea;

    @Column(name = "\"AudMontoAnterior\"", nullable = false)
    private BigDecimal salarioAnterior;

    @Column(name = "\"AudMontoNuevo\"", nullable = false)
    private BigDecimal salarioNuevo;
}