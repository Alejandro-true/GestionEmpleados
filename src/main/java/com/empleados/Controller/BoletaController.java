package com.empleados.Controller;

import com.empleados.Repository.BoletaPagoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/boletas")
public class BoletaController {

    @Autowired
    private BoletaPagoRepository boletaPagoRepository;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("boletas", boletaPagoRepository.findAll());
        return "boletas/lista";
    }
}