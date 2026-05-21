-- =====================================================
-- ROLLBACK: Eliminar tabla INVENTARIO_MOVIMIENTO y TIPO_MOVIMIENTO
-- =====================================================

-- Eliminar índices
DROP INDEX IF EXISTS inventario.idx_movimiento_producto;
DROP INDEX IF EXISTS inventario.idx_movimiento_fecha;
DROP INDEX IF EXISTS inventario.idx_movimiento_tipo;
DROP INDEX IF EXISTS inventario.idx_movimiento_producto_fecha;

-- Eliminar restricciones
ALTER TABLE IF EXISTS inventario.inventario_movimiento DROP CONSTRAINT IF EXISTS chk_movimiento_cantidad_no_cero;

-- Eliminar llaves foráneas
ALTER TABLE IF EXISTS inventario.inventario_movimiento DROP CONSTRAINT IF EXISTS fk_movimiento_producto;
ALTER TABLE IF EXISTS inventario.inventario_movimiento DROP CONSTRAINT IF EXISTS fk_movimiento_tipo;

-- Eliminar tablas (orden inverso al de creación)
DROP TABLE IF EXISTS inventario.inventario_movimiento CASCADE;
DROP TABLE IF EXISTS inventario.tipo_movimiento CASCADE;