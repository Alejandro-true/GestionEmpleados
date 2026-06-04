package com.empleados.config;

import com.empleados.Model.Usuario;
import com.empleados.Repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        System.out.println("=== Buscando usuario: " + username + " ===");
        Optional<Usuario> usuario = usuarioRepository.findByNombreusuario(username);
        System.out.println("=== Usuario encontrado: " + usuario.isPresent() + " ===");

        if (usuario.isEmpty()) {
            throw new UsernameNotFoundException("Usuario no encontrado: " + username);
        }

        Usuario u = usuario.get();
        System.out.println("=== Rol: " + u.getRol().getNombrerol() + " ===");

        String rol = u.getRol().getNombrerol()
                      .toUpperCase()
                      .replace(" ", "_");

        return User.builder()
                .username(u.getNombreusuario())
                .password(u.getContrasenia())
                .authorities(new SimpleGrantedAuthority("ROLE_" + rol))
                .build();
    }
}