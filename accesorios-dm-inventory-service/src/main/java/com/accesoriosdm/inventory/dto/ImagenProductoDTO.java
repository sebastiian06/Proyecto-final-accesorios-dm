package com.accesoriosdm.inventory.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ImagenProductoDTO {
    private Integer idImagen;
    private String urlImagen;
    private Integer orden;
}