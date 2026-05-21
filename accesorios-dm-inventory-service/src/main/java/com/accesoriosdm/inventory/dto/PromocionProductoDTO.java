package com.accesoriosdm.inventory.dto;

import java.math.BigDecimal;

public class PromocionProductoDTO {

    private Integer idPromocionProducto;
    private Integer idPromocion;
    private Integer idProducto;
    private BigDecimal precioPromocional;

    public Integer getIdPromocionProducto() {
        return idPromocionProducto;
    }

    public void setIdPromocionProducto(Integer idPromocionProducto) {
        this.idPromocionProducto = idPromocionProducto;
    }

    public Integer getIdPromocion() {
        return idPromocion;
    }

    public void setIdPromocion(Integer idPromocion) {
        this.idPromocion = idPromocion;
    }

    public Integer getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(Integer idProducto) {
        this.idProducto = idProducto;
    }

    public BigDecimal getPrecioPromocional() {
        return precioPromocional;
    }

    public void setPrecioPromocional(BigDecimal precioPromocional) {
        this.precioPromocional = precioPromocional;
    }
}