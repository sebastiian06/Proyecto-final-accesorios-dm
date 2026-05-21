-- =====================================================
-- Tabla: ESTADO_PEDIDO
-- Descripción: Catálogo de estados posibles para un pedido
-- Schema: logistica
-- =====================================================

CREATE TABLE IF NOT EXISTS logistica.estado_pedido (
    id_estado SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

COMMENT ON TABLE logistica.estado_pedido IS 'Catálogo de estados de pedido';
COMMENT ON COLUMN logistica.estado_pedido.id_estado IS 'Identificador único del estado';
COMMENT ON COLUMN logistica.estado_pedido.nombre IS 'Nombre del estado (pendiente, pagado, enviado, entregado, cancelado)';
COMMENT ON COLUMN logistica.estado_pedido.descripcion IS 'Descripción del estado';

-- =====================================================
-- Tabla: PEDIDO
-- Descripción: Almacena los pedidos realizados por clientes
-- Schema: ventas
-- =====================================================

CREATE TABLE IF NOT EXISTS ventas.pedido (
    id_pedido SERIAL PRIMARY KEY,
    direccion_envio VARCHAR(255) NOT NULL,
    telefono_contacto VARCHAR(20) NOT NULL,
    total NUMERIC(10,2) NOT NULL,
    fecha_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente INTEGER NOT NULL,
    id_estado_actual INTEGER NOT NULL
);

COMMENT ON TABLE ventas.pedido IS 'Pedidos realizados por clientes';
COMMENT ON COLUMN ventas.pedido.id_pedido IS 'Identificador único del pedido';
COMMENT ON COLUMN ventas.pedido.direccion_envio IS 'Dirección de envío del pedido';
COMMENT ON COLUMN ventas.pedido.telefono_contacto IS 'Teléfono de contacto para el envío';
COMMENT ON COLUMN ventas.pedido.total IS 'Monto total del pedido';
COMMENT ON COLUMN ventas.pedido.fecha_pedido IS 'Fecha y hora del pedido';
COMMENT ON COLUMN ventas.pedido.id_cliente IS 'Llave foránea al cliente';
COMMENT ON COLUMN ventas.pedido.id_estado_actual IS 'Estado actual del pedido';

-- =====================================================
-- Tabla: HISTORIAL_ESTADO_PEDIDO
-- Descripción: Historial de cambios de estado de cada pedido
-- Schema: logistica
-- =====================================================

CREATE TABLE IF NOT EXISTS logistica.historial_estado_pedido (
    id_historial SERIAL PRIMARY KEY,
    fecha_cambio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacion TEXT,
    id_pedido INTEGER NOT NULL,
    id_estado INTEGER NOT NULL
);

COMMENT ON TABLE logistica.historial_estado_pedido IS 'Historial de cambios de estado de los pedidos';
COMMENT ON COLUMN logistica.historial_estado_pedido.id_historial IS 'Identificador único del registro de historial';
COMMENT ON COLUMN logistica.historial_estado_pedido.fecha_cambio IS 'Fecha y hora del cambio de estado';
COMMENT ON COLUMN logistica.historial_estado_pedido.observacion IS 'Observación sobre el cambio de estado';
COMMENT ON COLUMN logistica.historial_estado_pedido.id_pedido IS 'Llave foránea al pedido';
COMMENT ON COLUMN logistica.historial_estado_pedido.id_estado IS 'Llave foránea al estado';

-- =====================================================
-- Tabla: DETALLE_PEDIDO
-- Descripción: Detalle de productos en cada pedido
-- Schema: ventas
-- =====================================================

CREATE TABLE IF NOT EXISTS ventas.detalle_pedido (
    id_detalle SERIAL PRIMARY KEY,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    id_pedido INTEGER NOT NULL,
    id_producto INTEGER NOT NULL
);

COMMENT ON TABLE ventas.detalle_pedido IS 'Detalle de productos en cada pedido';
COMMENT ON COLUMN ventas.detalle_pedido.id_detalle IS 'Identificador único del detalle';
COMMENT ON COLUMN ventas.detalle_pedido.cantidad IS 'Cantidad del producto';
COMMENT ON COLUMN ventas.detalle_pedido.precio_unitario IS 'Precio unitario al momento del pedido';
COMMENT ON COLUMN ventas.detalle_pedido.subtotal IS 'Subtotal calculado (cantidad * precio_unitario)';
COMMENT ON COLUMN ventas.detalle_pedido.id_pedido IS 'Llave foránea al pedido';
COMMENT ON COLUMN ventas.detalle_pedido.id_producto IS 'Llave foránea al producto';

-- =====================================================
-- Llaves Foráneas
-- =====================================================

-- Relación: PEDIDO pertenece a un CLIENTE
ALTER TABLE ventas.pedido
    ADD CONSTRAINT fk_pedido_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES clientes.cliente(id_cliente)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Relación: PEDIDO tiene un ESTADO actual
ALTER TABLE ventas.pedido
    ADD CONSTRAINT fk_pedido_estado_actual
    FOREIGN KEY (id_estado_actual)
    REFERENCES logistica.estado_pedido(id_estado)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Relación: HISTORIAL pertenece a un PEDIDO
ALTER TABLE logistica.historial_estado_pedido
    ADD CONSTRAINT fk_historial_pedido
    FOREIGN KEY (id_pedido)
    REFERENCES ventas.pedido(id_pedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Relación: HISTORIAL tiene un ESTADO
ALTER TABLE logistica.historial_estado_pedido
    ADD CONSTRAINT fk_historial_estado
    FOREIGN KEY (id_estado)
    REFERENCES logistica.estado_pedido(id_estado)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Relación: DETALLE pertenece a un PEDIDO
ALTER TABLE ventas.detalle_pedido
    ADD CONSTRAINT fk_detalle_pedido
    FOREIGN KEY (id_pedido)
    REFERENCES ventas.pedido(id_pedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Relación: DETALLE pertenece a un PRODUCTO
ALTER TABLE ventas.detalle_pedido
    ADD CONSTRAINT fk_detalle_producto
    FOREIGN KEY (id_producto)
    REFERENCES catalogo.producto(id_producto)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- =====================================================
-- Índices para mejorar rendimiento
-- =====================================================

-- Índices para PEDIDO
CREATE INDEX idx_pedido_cliente ON ventas.pedido(id_cliente);
CREATE INDEX idx_pedido_fecha ON ventas.pedido(fecha_pedido);
CREATE INDEX idx_pedido_estado_actual ON ventas.pedido(id_estado_actual);

-- Índices para HISTORIAL
CREATE INDEX idx_historial_pedido ON logistica.historial_estado_pedido(id_pedido);
CREATE INDEX idx_historial_fecha ON logistica.historial_estado_pedido(fecha_cambio);

-- Índices para DETALLE
CREATE INDEX idx_detalle_pedido ON ventas.detalle_pedido(id_pedido);
CREATE INDEX idx_detalle_producto ON ventas.detalle_pedido(id_producto);

-- Índice compuesto para detalles
CREATE INDEX idx_detalle_pedido_producto ON ventas.detalle_pedido(id_pedido, id_producto);

-- =====================================================
-- Restricciones adicionales
-- =====================================================

-- Asegurar que la cantidad sea positiva
ALTER TABLE ventas.detalle_pedido
    ADD CONSTRAINT chk_detalle_cantidad_positiva
    CHECK (cantidad > 0);

-- Asegurar que el precio_unitario sea positivo
ALTER TABLE ventas.detalle_pedido
    ADD CONSTRAINT chk_detalle_precio_positivo
    CHECK (precio_unitario > 0);

-- Asegurar que el total del pedido sea positivo
ALTER TABLE ventas.pedido
    ADD CONSTRAINT chk_pedido_total_positivo
    CHECK (total > 0);