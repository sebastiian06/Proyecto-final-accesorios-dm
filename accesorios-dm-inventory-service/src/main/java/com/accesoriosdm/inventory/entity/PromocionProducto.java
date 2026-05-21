package com.accesoriosdm.inventory.entity;

import java.math.BigDecimal;

import jakarta.persistence.*;

@Entity
@Table(name = "promocion_producto", schema = "promociones")
public class PromocionProducto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_promocion_producto")
    private Integer idPromocionProducto;

    @ManyToOne
    @JoinColumn(name = "id_promocion")

    private Promocion promocion;

    @Column(name = "id_producto", nullable = false)
    private Integer idProducto;

    @Column(name = "precio_promocional", nullable = false, precision = 10, scale = 2)
    private BigDecimal precioPromocional;

    public Integer getIdPromocionProducto() {
        return idPromocionProducto;
    }

    public void setIdPromocionProducto(Integer idPromocionProducto) {
        this.idPromocionProducto = idPromocionProducto;
    }

    public Promocion getPromocion() {
        return promocion;
    }

    public void setPromocion(Promocion promocion) {
        this.promocion = promocion;
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