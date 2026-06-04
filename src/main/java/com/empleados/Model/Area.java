package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Entity
@Data
@Table(name = "\"Area\"")
@AllArgsConstructor
@NoArgsConstructor
public class Area {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"AreIdArea\"")
    private Integer idarea;

    @Column(name = "\"AreNombreArea\"", nullable = false, length = 50)
    private String nombrearea;

    @Column(name = "\"AreSalario\"", nullable = false)
    private BigDecimal salario;
}