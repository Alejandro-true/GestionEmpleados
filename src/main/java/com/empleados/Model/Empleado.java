package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.util.List;

@Entity
@Data
@Table(name = "\"Empleado\"")
@AllArgsConstructor
@NoArgsConstructor
public class Empleado {

    @Id
    @Column(name = "\"EmpCodigo\"", length = 8)
    private String codigo;

    @Column(name = "\"EmpFechaIngreso\"", nullable = false)
    private LocalDate fechaingreso;

    @ManyToOne
    @JoinColumn(name = "\"EmpIdUsuario\"", nullable = false)
    private Usuario usuario;

    @ManyToOne
    @JoinColumn(name = "\"EmpIdArea\"")
    private Area area;

    @OneToMany(mappedBy = "empleado", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Contrato> contratos;

    @OneToMany(mappedBy = "empleado", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Boleta> boletas;
}