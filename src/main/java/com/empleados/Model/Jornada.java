package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Entity
@Data
@Table(name = "\"Jornada\"")
@AllArgsConstructor
@NoArgsConstructor
public class Jornada {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"JorIdJornada\"")
    private Integer idjornada;

    @Column(name = "\"JorTipo\"", nullable = false, length = 20)
    private String tipo;

    @OneToMany(mappedBy = "jornada", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Contrato> contratos;
}