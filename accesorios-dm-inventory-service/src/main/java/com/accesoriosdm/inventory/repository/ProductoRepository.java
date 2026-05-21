package com.accesoriosdm.inventory.repository;

import com.accesoriosdm.inventory.entity.Producto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductoRepository extends JpaRepository<Producto, Integer> {
    
    List<Producto> findByEstadoTrue();
    
    Page<Producto> findByEstadoTrue(Pageable pageable);
    
    List<Producto> findByCategoriaIdCategoriaAndEstadoTrue(Integer categoriaId);
    
    Page<Producto> findByCategoriaIdCategoriaAndEstadoTrue(Integer categoriaId, Pageable pageable);
    
    List<Producto> findByMaterialIdMaterial(Integer materialId);
    
    List<Producto> findByNombreContainingIgnoreCase(String nombre);
    
    Optional<Producto> findByNombre(String nombre);
    
    @Query("SELECT p FROM Producto p WHERE p.estado = true AND p.stock > 0")
    List<Producto> findProductosDisponibles();
    
    @Query("SELECT p FROM Producto p WHERE p.categoria.idCategoria = :categoriaId AND p.estado = true AND p.stock > 0")
    List<Producto> findProductosDisponiblesByCategoria(@Param("categoriaId") Integer categoriaId);
}