package com.empleados.Repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.empleados.Model.Contrato;
import com.empleados.Model.Empleado;

import java.util.List;

public interface ContratoRepository extends JpaRepository<Contrato, Integer> {
	List<Contrato> findByEmpleado(Empleado empleado);
}