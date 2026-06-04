package com.empleados.Repository;

import com.empleados.Model.AuditoriaSalario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AuditoriaSalarioRepository extends JpaRepository<AuditoriaSalario, Integer> {
    List<AuditoriaSalario> findByAudAreIdAreaOrderByFechaModificacionDesc(Integer idArea);
}