package com.empleados.Controller;

import com.empleados.Repository.AreaRepository;
import com.empleados.Service.EmpleadoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;

@Controller
@RequestMapping("/salarios")
public class SalarioController {

    @Autowired
    private AreaRepository areaRepository;

    @Autowired
    private EmpleadoService empleadoService;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("areas", areaRepository.findAll());
        return "salarios/lista";
    }

    @PostMapping("/actualizar/{idarea}")
    public String actualizar(@PathVariable Integer idarea,
                             @RequestParam BigDecimal nuevoSalario) {
        empleadoService.modificarSalarioPorArea(idarea, nuevoSalario,
            SecurityContextHolder.getContext().getAuthentication().getName());
        return "redirect:/salarios";
    }
}