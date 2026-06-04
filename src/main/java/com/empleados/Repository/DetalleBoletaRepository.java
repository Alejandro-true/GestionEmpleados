package com.empleados.Repository;

import com.empleados.Model.Boleta;
import com.empleados.Model.DetalleBoleta;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface DetalleBoletaRepository extends JpaRepository<DetalleBoleta, Integer> {
    List<DetalleBoleta> findByBoleta(Boleta boleta);
}