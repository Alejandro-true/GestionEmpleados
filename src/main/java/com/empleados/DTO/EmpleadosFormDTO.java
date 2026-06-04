package com.empleados.DTO;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EmpleadosFormDTO {
    private String codigoEmpleado;
    private String fechaIngreso;
    private String usuario_dni;
    private String usuario_nombres;
    private String usuario_apellidoPaterno;
    private String usuario_apellidoMaterno;
    private String usuario_genero;
    private String usuario_correoElectronico;
    private String usuario_fechaNacimiento;
    private String usuario_contrasenia;
    private String usuario_rol;
    private Integer area_idarea;
}
