package com.accesoriosdm.inventory.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MaterialDTO {
    private Integer idMaterial;
    private String nombre;
    private String descripcion;
}