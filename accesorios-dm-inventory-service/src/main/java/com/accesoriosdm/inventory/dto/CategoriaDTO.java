package com.accesoriosdm.inventory.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoriaDTO {
    private Integer idCategoria;
    private String nombre;
    private String descripcion;
    private Boolean estado;
}