-- =====================================================
-- Tabla: PROMOCION
-- Descripción: Almacena las promociones del sistema
-- Schema: promociones
-- =====================================================

CREATE TABLE IF NOT EXISTS promociones.promocion (
    id_promocion SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    porcentaje_descuento NUMERIC(5,2) NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE promociones.promocion IS 'Promociones y descuentos aplicables a productos';
COMMENT ON COLUMN promociones.promocion.id_promocion IS 'Identificador único de la promoción';
COMMENT ON COLUMN promociones.promocion.nombre IS 'Nombre descriptivo de la promoción';
COMMENT ON COLUMN promociones.promocion.descripcion IS 'Descripción detallada de la promoción';
COMMENT ON COLUMN promociones.promocion.porcentaje_descuento IS 'Porcentaje de descuento (ej: 15.00 para 15%)';
COMMENT ON COLUMN promociones.promocion.fecha_inicio IS 'Fecha y hora de inicio de la promoción';
COMMENT ON COLUMN promociones.promocion.fecha_fin IS 'Fecha y hora de finalización de la promoción';
COMMENT ON COLUMN promociones.promocion.activo IS 'TRUE=Promoción activa, FALSE=Inactiva';
COMMENT ON COLUMN promociones.promocion.fecha_creacion IS 'Fecha de creación del registro';

-- =====================================================
-- Tabla: PROMOCION_PRODUCTO
-- Descripción: Relación entre promociones y productos
-- Schema: promociones
-- =====================================================

CREATE TABLE IF NOT EXISTS promociones.promocion_producto (
    id_promocion_producto SERIAL PRIMARY KEY,
    precio_promocional NUMERIC(10,2) NOT NULL,
    id_promocion INTEGER NOT NULL,
    id_producto INTEGER NOT NULL
);

COMMENT ON TABLE promociones.promocion_producto IS 'Relación muchos a muchos entre promociones y productos';
COMMENT ON COLUMN promociones.promocion_producto.id_promocion_producto IS 'Identificador único de la relación';
COMMENT ON COLUMN promociones.promocion_producto.precio_promocional IS 'Precio con descuento aplicado';
COMMENT ON COLUMN promociones.promocion_producto.id_promocion IS 'Llave foránea a promoción';
COMMENT ON COLUMN promociones.promocion_producto.id_producto IS 'Llave foránea a producto';

-- =====================================================
-- Llaves Foráneas
-- =====================================================

-- Relación: PROMOCION_PRODUCTO pertenece a una PROMOCION
ALTER TABLE promociones.promocion_producto
    ADD CONSTRAINT fk_promocion_producto_promocion
    FOREIGN KEY (id_promocion)
    REFERENCES promociones.promocion(id_promocion)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Relación: PROMOCION_PRODUCTO pertenece a un PRODUCTO
ALTER TABLE promociones.promocion_producto
    ADD CONSTRAINT fk_promocion_producto_producto
    FOREIGN KEY (id_producto)
    REFERENCES catalogo.producto(id_producto)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- =====================================================
-- Índices para mejorar rendimiento
-- =====================================================

-- Índice para búsquedas por fecha de promoción
CREATE INDEX idx_promocion_fechas ON promociones.promocion(fecha_inicio, fecha_fin);

-- Índice para búsquedas por promoción activa
CREATE INDEX idx_promocion_activo ON promociones.promocion(activo);

-- Índice compuesto para la tabla relación
CREATE INDEX idx_promocion_producto_ids ON promociones.promocion_producto(id_promocion, id_producto);