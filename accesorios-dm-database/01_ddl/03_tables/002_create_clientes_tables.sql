-- =====================================================
-- Tabla: CLIENTE
-- Descripción: Almacena los clientes del sistema
-- Schema: clientes
-- =====================================================

CREATE TABLE IF NOT EXISTS clientes.cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(120) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE clientes.cliente IS 'Almacena los clientes del sistema';
COMMENT ON COLUMN clientes.cliente.id_cliente IS 'Identificador único del cliente (autoincremental)';
COMMENT ON COLUMN clientes.cliente.nombre IS 'Nombre completo del cliente';
COMMENT ON COLUMN clientes.cliente.correo IS 'Correo electrónico del cliente - Debe ser único';
COMMENT ON COLUMN clientes.cliente.telefono IS 'Número de teléfono del cliente (opcional)';
COMMENT ON COLUMN clientes.cliente.fecha_registro IS 'Fecha y hora de registro del cliente';