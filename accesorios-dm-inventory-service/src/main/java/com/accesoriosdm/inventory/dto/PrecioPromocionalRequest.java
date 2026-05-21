package com.accesoriosdm.inventory.dto;

import java.math.BigDecimal;

public class PrecioPromocionalRequest {

    private BigDecimal precioPromocional;

    public BigDecimal getPrecioPromocional() {
        return precioPromocional;
    }

    public void setPrecioPromocional(BigDecimal precioPromocional) {
        this.precioPromocional = precioPromocional;
    }
}