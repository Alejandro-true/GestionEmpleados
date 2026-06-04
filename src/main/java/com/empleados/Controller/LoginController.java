package com.empleados.Controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LoginController {

    @GetMapping("/")
    public String inicio() {
        return "redirect:/login";
    }

    @GetMapping("/login")
    public String loginForm() {
        return "login";
    }

    @GetMapping("/inicio")
    public String inicio(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        String rolCompleto = auth.getAuthorities().iterator().next().getAuthority();
        // ROLE_ADMINISTRADOR -> administrador
        // ROLE_RECURSOS_HUMANOS -> recursos humanos  
        // ROLE_EMPLEADO_REGULAR -> empleado regular
        String rol = rolCompleto
                        .replace("ROLE_", "")
                        .toLowerCase()
                        .replace("_", " ");
        model.addAttribute("usuarioNombre", username);
        model.addAttribute("rolUsuario", rol);
        return "inicio";
    }

    @GetMapping("/logout")
    public String logout() {
        return "redirect:/login";
    }

    @GetMapping("/acceso-denegado")
    public String accesoDenegado() {
        return "acceso-denegado";
    }
}