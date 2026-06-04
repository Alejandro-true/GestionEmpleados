package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Entity
@Data
@Table(name = "\"Rol\"")
@AllArgsConstructor
@NoArgsConstructor
public class Rol {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"RolIdRol\"")
    private Integer idrol;

    @Column(name = "\"RolNombreRol\"", length = 50, unique = true)
    private String nombrerol;

    @OneToMany(mappedBy = "rol")
    private List<Usuario> usuarios;
}