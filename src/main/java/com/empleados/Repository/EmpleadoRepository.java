package com.empleados.Repository;

import com.empleados.Model.Empleado;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmpleadoRepository extends JpaRepository<Empleado, String> {

    boolean existsByCodigo(String codigoEmpleado);
    boolean existsByUsuarioDni(String dni);
    boolean existsByUsuarioEmail(String correo);
}