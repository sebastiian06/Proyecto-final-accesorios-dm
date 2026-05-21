-- =====================================================
-- Tabla: CARRITO
-- Descripción: Almacena los carritos de compra de los clientes
-- Schema: ventas
-- =====================================================

CREATE TABLE IF NOT EXISTS ventas.carrito (
    id_carrito SERIAL PRIMARY KEY,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    id_cliente INTEGER NOT NULL
);

COMMENT ON TABLE ventas.carrito IS 'Carritos de compra de los clientes';
COMMENT ON COLUMN ventas.carrito.id_carrito IS 'Identificador único del carrito';
COMMENT ON COLUMN ventas.carrito.fecha_creacion IS 'Fecha y hora de creación del carrito';
COMMENT ON COLUMN ventas.carrito.estado IS 'Estado del carrito: activo, procesado, abandonado';
COMMENT ON COLUMN ventas.carrito.id_cliente IS 'Llave foránea al cliente propietario del carrito';

-- =====================================================
-- Tabla: ITEM_CARRITO
-- Descripción: Almacena los productos agregados al carrito
-- Schema: ventas
-- =====================================================

CREATE TABLE IF NOT EXISTS ventas.item_carrito (
    id_item_carrito SERIAL PRIMARY KEY,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,
    id_carrito INTEGER NOT NULL,
    id_producto INTEGER NOT NULL
);

COMMENT ON TABLE ventas.item_carrito IS 'Ítems (productos) agregados al carrito';
COMMENT ON COLUMN ventas.item_carrito.id_item_carrito IS 'Identificador único del ítem';
COMMENT ON COLUMN ventas.item_carrito.cantidad IS 'Cantidad del producto seleccionado';
COMMENT ON COLUMN ventas.item_carrito.precio_unitario IS 'Precio unitario del producto al momento de agregar al carrito';
COMMENT ON COLUMN ventas.item_carrito.id_carrito IS 'Llave foránea al carrito';
COMMENT ON COLUMN ventas.item_carrito.id_producto IS 'Llave foránea al producto';

-- =====================================================
-- Llaves Foráneas
-- =====================================================

-- Relación: CARRITO pertenece a un CLIENTE
ALTER TABLE ventas.carrito
    ADD CONSTRAINT fk_carrito_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES clientes.cliente(id_cliente)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Relación: ITEM_CARRITO pertenece a un CARRITO
ALTER TABLE ventas.item_carrito
    ADD CONSTRAINT fk_item_carrito_carrito
    FOREIGN KEY (id_carrito)
    REFERENCES ventas.carrito(id_carrito)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Relación: ITEM_CARRITO pertenece a un PRODUCTO
ALTER TABLE ventas.item_carrito
    ADD CONSTRAINT fk_item_carrito_producto
    FOREIGN KEY (id_producto)
    REFERENCES catalogo.producto(id_producto)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- =====================================================
-- Índices para mejorar rendimiento
-- =====================================================

-- Índice para búsquedas de carritos por cliente
CREATE INDEX idx_carrito_cliente ON ventas.carrito(id_cliente);

-- Índice para búsquedas de carritos por estado
CREATE INDEX idx_carrito_estado ON ventas.carrito(estado);

-- Índice para búsquedas de ítems por carrito
CREATE INDEX idx_item_carrito_carrito ON ventas.item_carrito(id_carrito);

-- Índice compuesto para ítems por carrito y producto
CREATE INDEX idx_item_carrito_carrito_producto ON ventas.item_carrito(id_carrito, id_producto);

-- =====================================================
-- Restricciones adicionales
-- =====================================================

-- Asegurar que la cantidad sea positiva
ALTER TABLE ventas.item_carrito
    ADD CONSTRAINT chk_item_carrito_cantidad_positiva
    CHECK (cantidad > 0);

-- Asegurar que el precio_unitario sea positivo
ALTER TABLE ventas.item_carrito
    ADD CONSTRAINT chk_item_carrito_precio_positivo
    CHECK (precio_unitario > 0);

-- Asegurar que el estado del carrito sea válido
ALTER TABLE ventas.carrito
    ADD CONSTRAINT chk_carrito_estado_valido
    CHECK (estado IN ('activo', 'procesado', 'abandonado'));