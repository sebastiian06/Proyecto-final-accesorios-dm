package com.accesoriosdm.inventory.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductoDTO {
    private Integer idProducto;
    private String nombre;
    private String descripcion;
    private BigDecimal precio;
    private Integer stock;
    private LocalDateTime fechaCreacion;
    private Boolean estado;
    private CategoriaDTO categoria;
    private MaterialDTO material;
    private List<ImagenProductoDTO> imagenes;
    private PromocionDTO promocionActiva;
    private BigDecimal precioConDescuento;
}