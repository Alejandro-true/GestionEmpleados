package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Entity
@Data
@Table(name = "\"Genero\"")
@AllArgsConstructor
@NoArgsConstructor
public class Genero {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"GenIdGenero\"")
    private Integer idgenero;

    @Column(name = "\"GenNombreGenero\"", length = 20, nullable = false)
    private String nombregenero;

    @OneToMany(mappedBy = "genero", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Usuario> usuarios;
}