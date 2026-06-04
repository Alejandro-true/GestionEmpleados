package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Entity
@Data
@Table(name = "\"Modalidad\"")
@AllArgsConstructor
@NoArgsConstructor
public class Modalidad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"ModIdModalidad\"")
    private Integer idmodalidad;

    @Column(name = "\"ModTipo\"", length = 20)
    private String tipo;

    @OneToMany(mappedBy = "modalidad", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Contrato> contratos;
}