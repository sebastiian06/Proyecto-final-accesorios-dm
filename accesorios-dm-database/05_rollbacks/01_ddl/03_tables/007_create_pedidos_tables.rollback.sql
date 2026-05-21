-- =====================================================
-- ROLLBACK: Eliminar tablas de pedidos
-- =====================================================

-- Eliminar índices de DETALLE_PEDIDO
DROP INDEX IF EXISTS ventas.idx_detalle_pedido;
DROP INDEX IF EXISTS ventas.idx_detalle_producto;
DROP INDEX IF EXISTS ventas.idx_detalle_pedido_producto;

-- Eliminar índices de HISTORIAL
DROP INDEX IF EXISTS logistica.idx_historial_pedido;
DROP INDEX IF EXISTS logistica.idx_historial_fecha;

-- Eliminar índices de PEDIDO
DROP INDEX IF EXISTS ventas.idx_pedido_cliente;
DROP INDEX IF EXISTS ventas.idx_pedido_fecha;
DROP INDEX IF EXISTS ventas.idx_pedido_estado_actual;

-- Eliminar restricciones CHECK
ALTER TABLE IF EXISTS ventas.detalle_pedido DROP CONSTRAINT IF EXISTS chk_detalle_cantidad_positiva;
ALTER TABLE IF EXISTS ventas.detalle_pedido DROP CONSTRAINT IF EXISTS chk_detalle_precio_positivo;
ALTER TABLE IF EXISTS ventas.pedido DROP CONSTRAINT IF EXISTS chk_pedido_total_positivo;

-- Eliminar llaves foráneas de DETALLE_PEDIDO
ALTER TABLE IF EXISTS ventas.detalle_pedido DROP CONSTRAINT IF EXISTS fk_detalle_pedido;
ALTER TABLE IF EXISTS ventas.detalle_pedido DROP CONSTRAINT IF EXISTS fk_detalle_producto;

-- Eliminar llaves foráneas de HISTORIAL
ALTER TABLE IF EXISTS logistica.historial_estado_pedido DROP CONSTRAINT IF EXISTS fk_historial_pedido;
ALTER TABLE IF EXISTS logistica.historial_estado_pedido DROP CONSTRAINT IF EXISTS fk_historial_estado;

-- Eliminar llaves foráneas de PEDIDO
ALTER TABLE IF EXISTS ventas.pedido DROP CONSTRAINT IF EXISTS fk_pedido_cliente;
ALTER TABLE IF EXISTS ventas.pedido DROP CONSTRAINT IF EXISTS fk_pedido_estado_actual;

-- Eliminar tablas (orden inverso al de creación)
DROP TABLE IF EXISTS ventas.detalle_pedido CASCADE;
DROP TABLE IF EXISTS logistica.historial_estado_pedido CASCADE;
DROP TABLE IF EXISTS ventas.pedido CASCADE;
DROP TABLE IF EXISTS logistica.estado_pedido CASCADE;