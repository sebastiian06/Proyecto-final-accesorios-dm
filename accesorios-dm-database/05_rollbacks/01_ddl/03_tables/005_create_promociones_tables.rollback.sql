-- =====================================================
-- ROLLBACK: Eliminar tablas de promociones
-- =====================================================

-- Eliminar índices
DROP INDEX IF EXISTS promociones.idx_promocion_fechas;
DROP INDEX IF EXISTS promociones.idx_promocion_activo;
DROP INDEX IF EXISTS promociones.idx_promocion_producto_ids;

-- Eliminar llaves foráneas
ALTER TABLE IF EXISTS promociones.promocion_producto DROP CONSTRAINT IF EXISTS fk_promocion_producto_promocion;
ALTER TABLE IF EXISTS promociones.promocion_producto DROP CONSTRAINT IF EXISTS fk_promocion_producto_producto;

-- Eliminar tablas (orden inverso al de creación)
DROP TABLE IF EXISTS promociones.promocion_producto CASCADE;
DROP TABLE IF EXISTS promociones.promocion CASCADE;