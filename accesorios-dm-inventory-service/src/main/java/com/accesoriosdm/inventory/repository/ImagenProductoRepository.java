package com.accesoriosdm.inventory.repository;

import com.accesoriosdm.inventory.entity.ImagenProducto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ImagenProductoRepository extends JpaRepository<ImagenProducto, Integer> {
    List<ImagenProducto> findByProductoIdProductoOrderByOrdenAsc(Integer productoId);
    void deleteByProductoIdProducto(Integer productoId);
}