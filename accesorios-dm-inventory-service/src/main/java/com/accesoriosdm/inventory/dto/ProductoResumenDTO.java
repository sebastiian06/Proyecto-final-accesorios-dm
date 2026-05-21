package com.accesoriosdm.inventory.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductoResumenDTO {
    private Integer idProducto;
    private String nombre;
    private BigDecimal precio;
    private BigDecimal precioConDescuento;
    private String imagenPrincipal;
    private String categoriaNombre;
}