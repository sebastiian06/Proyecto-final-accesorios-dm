package com.accesoriosdm.inventory.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PromocionDTO {
    private Integer idPromocion;
    private String nombre;
    private String descripcion;
    private BigDecimal porcentajeDescuento;
    private LocalDateTime fechaInicio;
    private LocalDateTime fechaFin;
    private Boolean activo;
    private LocalDateTime fechaCreacion;
}