-- =====================================================
-- Tabla: TIPO_MOVIMIENTO
-- Descripción: Catálogo de tipos de movimiento de inventario
-- Schema: inventario
-- =====================================================

CREATE TABLE IF NOT EXISTS inventario.tipo_movimiento (
    id_tipo_movimiento SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

COMMENT ON TABLE inventario.tipo_movimiento IS 'Tipos de movimientos de inventario (entrada, salida, ajuste)';
COMMENT ON COLUMN inventario.tipo_movimiento.id_tipo_movimiento IS 'Identificador único del tipo de movimiento';
COMMENT ON COLUMN inventario.tipo_movimiento.nombre IS 'Nombre del tipo (entrada, salida, ajuste)';
COMMENT ON COLUMN inventario.tipo_movimiento.descripcion IS 'Descripción del tipo de movimiento';

-- =====================================================
-- Tabla: INVENTARIO_MOVIMIENTO
-- Descripción: Registro de movimientos de inventario
-- Schema: inventario
-- =====================================================

CREATE TABLE IF NOT EXISTS inventario.inventario_movimiento (
    id_movimiento SERIAL PRIMARY KEY,
    cantidad INTEGER NOT NULL,
    fecha_movimiento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    referencia VARCHAR(100),
    id_producto INTEGER NOT NULL,
    id_tipo_movimiento INTEGER NOT NULL
);

COMMENT ON TABLE inventario.inventario_movimiento IS 'Registro de movimientos de inventario';
COMMENT ON COLUMN inventario.inventario_movimiento.id_movimiento IS 'Identificador único del movimiento';
COMMENT ON COLUMN inventario.inventario_movimiento.cantidad IS 'Cantidad movida (positiva para entrada, negativa para salida)';
COMMENT ON COLUMN inventario.inventario_movimiento.fecha_movimiento IS 'Fecha y hora del movimiento';
COMMENT ON COLUMN inventario.inventario_movimiento.referencia IS 'Referencia del movimiento (ej: Pedido #123, Compra #456)';
COMMENT ON COLUMN inventario.inventario_movimiento.id_producto IS 'Llave foránea al producto';
COMMENT ON COLUMN inventario.inventario_movimiento.id_tipo_movimiento IS 'Llave foránea al tipo de movimiento';

-- =====================================================
-- Llaves Foráneas
-- =====================================================

-- Relación: MOVIMIENTO pertenece a un PRODUCTO
ALTER TABLE inventario.inventario_movimiento
    ADD CONSTRAINT fk_movimiento_producto
    FOREIGN KEY (id_producto)
    REFERENCES catalogo.producto(id_producto)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Relación: MOVIMIENTO tiene un TIPO
ALTER TABLE inventario.inventario_movimiento
    ADD CONSTRAINT fk_movimiento_tipo
    FOREIGN KEY (id_tipo_movimiento)
    REFERENCES inventario.tipo_movimiento(id_tipo_movimiento)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- =====================================================
-- Índices para mejorar rendimiento
-- =====================================================

-- Índice para búsquedas por producto
CREATE INDEX idx_movimiento_producto ON inventario.inventario_movimiento(id_producto);

-- Índice para búsquedas por fecha
CREATE INDEX idx_movimiento_fecha ON inventario.inventario_movimiento(fecha_movimiento);

-- Índice para búsquedas por tipo de movimiento
CREATE INDEX idx_movimiento_tipo ON inventario.inventario_movimiento(id_tipo_movimiento);

-- Índice compuesto para producto y fecha
CREATE INDEX idx_movimiento_producto_fecha ON inventario.inventario_movimiento(id_producto, fecha_movimiento);

-- =====================================================
-- Restricciones adicionales
-- =====================================================

-- Asegurar que la cantidad no sea cero
ALTER TABLE inventario.inventario_movimiento
    ADD CONSTRAINT chk_movimiento_cantidad_no_cero
    CHECK (cantidad != 0);