package com.empleados.Repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.empleados.Model.Usuario;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {
	Optional<Usuario> findByDni(String dni);
	Optional<Usuario> findByNombreusuario(String nombreusuario);
	Optional<Usuario> findByEmail(String correo);
}