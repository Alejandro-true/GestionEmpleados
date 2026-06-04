package com.empleados.Repository;

import com.empleados.Model.Boleta;
import com.empleados.Model.Empleado;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BoletaPagoRepository extends JpaRepository<Boleta, Integer> {
    List<Boleta> findByEmpleado(Empleado empleado);
}