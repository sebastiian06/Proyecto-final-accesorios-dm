package com.accesoriosdm.inventory.repository;

import com.accesoriosdm.inventory.entity.Material;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MaterialRepository extends JpaRepository<Material, Integer> {
    Optional<Material> findByNombre(String nombre);
}