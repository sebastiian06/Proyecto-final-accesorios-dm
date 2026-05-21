-- Crear los esquemas de la base de datos
-- Cada esquema agrupa tablas relacionadas

-- Esquema de seguridad (roles y empleados)
CREATE SCHEMA IF NOT EXISTS security;

-- Esquema de clientes
CREATE SCHEMA IF NOT EXISTS clientes;

-- Esquema de catálogo (categorías, materiales, productos, imágenes)
CREATE SCHEMA IF NOT EXISTS catalogo;

-- Esquema de promociones
CREATE SCHEMA IF NOT EXISTS promociones;

-- Esquema de ventas (carritos, pedidos, detalles)
CREATE SCHEMA IF NOT EXISTS ventas;

-- Esquema de logística (estados de pedido, historial)
CREATE SCHEMA IF NOT EXISTS logistica;

-- Esquema de inventario (movimientos)
CREATE SCHEMA IF NOT EXISTS inventario;