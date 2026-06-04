package com.empleados.Service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.empleados.DTO.EmpleadosFormDTO;
import com.empleados.Model.Area;
import com.empleados.Model.AuditoriaSalario;
import com.empleados.Model.Boleta;
import com.empleados.Model.Empleado;
import com.empleados.Model.Rol;
import com.empleados.Model.Usuario;
import com.empleados.Repository.AreaRepository;
import com.empleados.Repository.AuditoriaSalarioRepository;
import com.empleados.Repository.BoletaPagoRepository;
import com.empleados.Repository.EmpleadoRepository;
import com.empleados.Repository.UsuarioRepository;

import java.time.LocalDate;
import java.time.Period;
import java.util.List;
import java.util.Optional;
import java.time.LocalDateTime;
import java.math.BigDecimal;

@Service
public class EmpleadoService {

    @Autowired
    private EmpleadoRepository empleadoRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private AreaRepository areaRepository;

    @Autowired
    private BoletaPagoRepository boletaPagoRepository;

    @Autowired
    private AuditoriaSalarioRepository auditoriaRepository;

    // Listar todos los empleados
    public List<Empleado> listarEmpleados() {
        return empleadoRepository.findAll();
    }

    // Buscar empleado por codigo
    public Optional<Empleado> buscarPorId(String codigo) {
        return empleadoRepository.findById(codigo);
    }

    // Guardar empleado
    public Empleado guardarEmpleado(Empleado empleado) {
        return empleadoRepository.save(empleado);
    }

    // Eliminar empleado
    public void eliminarEmpleado(String codigo) {
        Optional<Empleado> emp = empleadoRepository.findById(codigo);
        if (emp.isPresent()) {
            /*Integer idUsuario = emp.get().getUsuario().getIdusuario();
            empleadoRepository.deleteById(codigo);
            usuarioRepository.deleteById(idUsuario);*/
            Usuario usuario = usuarioRepository.findById(emp.get().getUsuario().getIdusuario()).orElseThrow();
            usuario.setUsuEstado("Inactivo");
            usuarioRepository.save(usuario);
        }
    }

    // Calcular edad
    public int calcularEdad(LocalDate fechaNacimiento) {
        return Period.between(fechaNacimiento, LocalDate.now()).getYears();
    }

    // Calcular antigüedad
    public String calcularAntiguedad(LocalDate fechaIngreso) {
        Period periodo = Period.between(fechaIngreso, LocalDate.now());
        return periodo.getYears() + " años, " + periodo.getMonths() + " meses";
    }

    // Listar áreas
    public List<Area> listarAreas() {
        return areaRepository.findAll();
    }

    // Buscar área por ID
    public Optional<Area> buscarAreaPorId(Integer id) {
        return areaRepository.findById(id);
    }

    // Modificar salario con auditoría
    public boolean modificarSalario(String codigoEmpleado, BigDecimal nuevoSalario, String usuarioModifico) {
        Optional<Empleado> emp = empleadoRepository.findById(codigoEmpleado);
        if (emp.isPresent()) {
            Area area = emp.get().getArea();
            BigDecimal salarioAnterior = area.getSalario();

            // Guardar auditoría
            AuditoriaSalario auditoria = new AuditoriaSalario();
            auditoria.setUsuarioModifico(usuarioModifico);
            auditoria.setFechaModificacion(LocalDateTime.now());
            auditoria.setAudAreIdArea(area.getIdarea());
            auditoria.setAudNombreArea(area.getNombrearea());
            auditoria.setSalarioAnterior(salarioAnterior);
            auditoria.setSalarioNuevo(nuevoSalario);
            auditoriaRepository.save(auditoria);

            // Actualizar salario
            area.setSalario(nuevoSalario);
            areaRepository.save(area);
            return true;
        }
        return false;
    }
    
    public boolean modificarSalarioPorArea(Integer idArea, BigDecimal nuevoSalario, String usuarioModifico) {
        Optional<Area> areaOpt = areaRepository.findById(idArea);
        if (areaOpt.isPresent()) {
            Area area = areaOpt.get();
            BigDecimal salarioAnterior = area.getSalario();

            AuditoriaSalario auditoria = new AuditoriaSalario();
            auditoria.setUsuarioModifico(usuarioModifico);
            auditoria.setFechaModificacion(LocalDateTime.now());
            auditoria.setAudAreIdArea(area.getIdarea());
            auditoria.setAudNombreArea(area.getNombrearea());
            auditoria.setSalarioAnterior(salarioAnterior);
            auditoria.setSalarioNuevo(nuevoSalario);
            auditoriaRepository.save(auditoria);

            area.setSalario(nuevoSalario);
            areaRepository.save(area);
            return true;
        }
        return false;
    }

    // Listar boletas por empleado
    public List<Boleta> listarBoletas(Empleado empleado) {
        return boletaPagoRepository.findByEmpleado(empleado);
    }

    // Listar auditoría por área
    public List<AuditoriaSalario> listarAuditoria(Empleado empleado) {
        if (empleado.getArea() != null) {
            return auditoriaRepository.findByAudAreIdAreaOrderByFechaModificacionDesc(
                empleado.getArea().getIdarea());
        }
        return List.of();
    }

    // Guardar nuevo empleado
    public boolean guardarNuevoEmpleado(EmpleadosFormDTO dto) {
        // Validar que no exista un empleado o usuario con el mismo código, DNI o correo
        if (empleadoRepository.existsByCodigo(dto.getCodigoEmpleado())
                || empleadoRepository.existsByUsuarioDni(dto.getUsuario_dni())
                || empleadoRepository.existsByUsuarioEmail(dto.getUsuario_correoElectronico())) {
            return false;
        }

        // Determinar ID del rol según nombre
        Integer idRol = 3; // Empleado Regular por defecto
        if ("Administrador".equals(dto.getUsuario_rol())) idRol = 1;
        else if ("Recursos Humanos".equals(dto.getUsuario_rol())) idRol = 2;

        // Buscar el Rol
        Rol rol = new Rol();
        rol.setIdrol(idRol);

        // Generar nombre de usuario automáticamente del correo
        String nombreUsuario = dto.getUsuario_correoElectronico().split("@")[0];

        // Guardar Usuario
        Usuario usuario = new Usuario();
        usuario.setNombreusuario(nombreUsuario);
        usuario.setDni(dto.getUsuario_dni());
        usuario.setNombre(dto.getUsuario_nombres());
        usuario.setApellidopaterno(dto.getUsuario_apellidoPaterno());
        usuario.setApellidomaterno(dto.getUsuario_apellidoMaterno());
        usuario.setEmail(dto.getUsuario_correoElectronico());
        usuario.setFechanacimiento(LocalDate.parse(dto.getUsuario_fechaNacimiento()));
        usuario.setContrasenia(dto.getCodigoEmpleado());
        usuario.setUsuEstado("Activo");
        usuario.setRol(rol);

        // Buscar Área
        Area area = areaRepository.findById(dto.getArea_idarea()).orElseThrow();

        // Guardar Empleado
        Empleado empleado = new Empleado();
        empleado.setCodigo(dto.getCodigoEmpleado());
        empleado.setFechaingreso(dto.getFechaIngreso().isEmpty() ? LocalDate.now() : LocalDate.parse(dto.getFechaIngreso()));
        empleado.setUsuario(usuarioRepository.save(usuario));
        empleado.setArea(area);
        empleadoRepository.save(empleado);
        return true;
    }
}