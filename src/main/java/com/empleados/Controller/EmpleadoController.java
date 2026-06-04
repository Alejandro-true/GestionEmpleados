package com.empleados.Controller;

import com.empleados.DTO.EmpleadosFormDTO;
import com.empleados.Model.*;
import com.empleados.Service.EmpleadoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.empleados.Repository.BoletaPagoRepository;
import com.empleados.Service.ExcelService;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

@Controller
@RequestMapping("/empleados")
public class EmpleadoController {

    @Autowired
    private EmpleadoService empleadoService;

    @Autowired
    private ExcelService excelService;

    @Autowired
    private BoletaPagoRepository boletaPagoRepository;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("empleados", empleadoService.listarEmpleados());
        model.addAttribute("rolUsuario", getRolActual());
        return "empleados/lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        model.addAttribute("empleado", new Empleado());
        model.addAttribute("areas", empleadoService.listarAreas());
        return "empleados/formulario";
    }

    @PostMapping("/guardar")
    public String guardar(
            @ModelAttribute EmpleadosFormDTO form,
            org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes) {
        boolean creado = empleadoService.guardarNuevoEmpleado(form);
        if (!creado) {
            redirectAttributes.addFlashAttribute("mensajeError", "Ya existe un empleado con ese código, DNI o correo.");
            return "redirect:/empleados/nuevo";
        }
        return "redirect:/empleados";
    }

    @GetMapping("/detalle/{codigo}")
    public String detalle(@PathVariable String codigo, Model model) {
        Optional<Empleado> empleado = empleadoService.buscarPorId(codigo);
        if (empleado.isPresent()) {
            Empleado emp = empleado.get();
            model.addAttribute("empleado", emp);
            model.addAttribute("edad", empleadoService.calcularEdad(emp.getUsuario().getFechanacimiento()));
            model.addAttribute("antiguedad", empleadoService.calcularAntiguedad(emp.getFechaingreso()));
            model.addAttribute("boletas", empleadoService.listarBoletas(emp));
            model.addAttribute("auditoria", empleadoService.listarAuditoria(emp));
        }
        return "empleados/detalle";
    }

    @GetMapping("/salario/{codigo}")
    public String editarSalario(@PathVariable String codigo, Model model) {
        Optional<Empleado> empleado = empleadoService.buscarPorId(codigo);
        empleado.ifPresent(e -> model.addAttribute("empleado", e));
        return "empleados/salario";
    }

    @PostMapping("/salario/{codigo}")
    public String confirmarSalario(@PathVariable String codigo,
            @RequestParam BigDecimal nuevoSalario) {
        String usuarioNombre = SecurityContextHolder.getContext()
                .getAuthentication().getName();
        empleadoService.modificarSalario(codigo, nuevoSalario, usuarioNombre);
        return "redirect:/empleados/detalle/" + codigo;
    }

    @GetMapping("/eliminar/{codigo}")
    public String eliminar(@PathVariable String codigo) {
        empleadoService.eliminarEmpleado(codigo);
        return "redirect:/empleados";
    }

    @GetMapping("/boleta/{idboleta}/excel")
    public void descargarBoleta(@PathVariable Integer idboleta,
            HttpServletResponse response) throws IOException {
        Boleta boleta = boletaPagoRepository.findById(idboleta).orElse(null);
        if (boleta == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition",
                "attachment; filename=boleta_" + boleta.getPeriodo() + ".xlsx");
        byte[] excelBytes = excelService.generarBoletaExcel(boleta);
        response.getOutputStream().write(excelBytes);
    }

    private String getRolActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth.getAuthorities().iterator().next().getAuthority()
                .replace("ROLE_", "").toLowerCase().replace("_", " ");
    }
}