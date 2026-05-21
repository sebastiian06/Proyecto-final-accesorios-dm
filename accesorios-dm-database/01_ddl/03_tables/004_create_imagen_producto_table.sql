-- =====================================================
-- Tabla: IMAGEN_PRODUCTO
-- Descripción: Almacena las imágenes de los productos
-- Schema: catalogo
-- =====================================================

CREATE TABLE IF NOT EXISTS catalogo.imagen_producto (
    id_imagen SERIAL PRIMARY KEY,
    url_imagen TEXT NOT NULL,
    orden INTEGER DEFAULT 1,
    id_producto INTEGER NOT NULL
);

COMMENT ON TABLE catalogo.imagen_producto IS 'Imágenes asociadas a los productos';
COMMENT ON COLUMN catalogo.imagen_producto.id_imagen IS 'Identificador único de la imagen';
COMMENT ON COLUMN catalogo.imagen_producto.url_imagen IS 'URL o ruta de la imagen';
COMMENT ON COLUMN catalogo.imagen_producto.orden IS 'Orden de visualización (menor número = aparece primero)';
COMMENT ON COLUMN catalogo.imagen_producto.id_producto IS 'Llave foránea al producto';

-- =====================================================
-- Llaves Foráneas
-- =====================================================

ALTER TABLE catalogo.imagen_producto
    ADD CONSTRAINT fk_imagen_producto
    FOREIGN KEY (id_producto)
    REFERENCES catalogo.producto(id_producto)
    ON DELETE CASCADE
    ON UPDATE CASCADE;