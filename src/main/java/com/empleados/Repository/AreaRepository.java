package com.empleados.Repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.empleados.Model.Area;

public interface AreaRepository extends JpaRepository<Area, Integer> {
	

}