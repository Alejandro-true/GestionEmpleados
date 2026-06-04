package com.empleados.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.util.List;

@Entity
@Data
@Table(name = "\"Usuario\"")
@AllArgsConstructor
@NoArgsConstructor
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"UsuIdUsuario\"")
    private Integer idusuario;

    @Column(name = "\"UsuNombreUsuario\"", unique = true, nullable = false, length = 50)
    private String nombreusuario;

    @Column(name = "\"UsuContrasenia\"", nullable = false, length = 50)
    private String contrasenia;

    @Column(name = "\"UsuDni\"", nullable = false, unique = true, length = 8)
    private String dni;

    @Column(name = "\"UsuNombre\"", nullable = false, length = 50)
    private String nombre;

    @Column(name = "\"UsuApellidoPaterno\"", nullable = false, length = 20)
    private String apellidopaterno;

    @Column(name = "\"UsuApellidoMaterno\"", nullable = false, length = 20)
    private String apellidomaterno;

    @Column(name = "\"UsuEmail\"", nullable = false, unique = true, length = 50)
    private String email;

    @Column(name = "\"UsuFechaNacimiento\"", nullable = false)
    private LocalDate fechanacimiento;

    @Column(name = "\"UsuEstado\"", length = 10)
    private String usuEstado;

    @ManyToOne
    @JoinColumn(name = "\"UsuIdRol\"")
    private Rol rol;

    @ManyToOne
    @JoinColumn(name = "\"UsuIdGenero\"")
    private Genero genero;

    @OneToMany(mappedBy = "usuario", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Empleado> empleados;
}