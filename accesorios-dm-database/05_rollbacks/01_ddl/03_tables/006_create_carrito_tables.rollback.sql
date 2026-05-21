-- =====================================================
-- ROLLBACK: Eliminar tablas de carrito
-- =====================================================

-- Eliminar índices
DROP INDEX IF EXISTS ventas.idx_carrito_cliente;
DROP INDEX IF EXISTS ventas.idx_carrito_estado;
DROP INDEX IF EXISTS ventas.idx_item_carrito_carrito;
DROP INDEX IF EXISTS ventas.idx_item_carrito_carrito_producto;

-- Eliminar restricciones CHECK
ALTER TABLE IF EXISTS ventas.item_carrito DROP CONSTRAINT IF EXISTS chk_item_carrito_cantidad_positiva;
ALTER TABLE IF EXISTS ventas.item_carrito DROP CONSTRAINT IF EXISTS chk_item_carrito_precio_positivo;
ALTER TABLE IF EXISTS ventas.carrito DROP CONSTRAINT IF EXISTS chk_carrito_estado_valido;

-- Eliminar llaves foráneas
ALTER TABLE IF EXISTS ventas.item_carrito DROP CONSTRAINT IF EXISTS fk_item_carrito_carrito;
ALTER TABLE IF EXISTS ventas.item_carrito DROP CONSTRAINT IF EXISTS fk_item_carrito_producto;
ALTER TABLE IF EXISTS ventas.carrito DROP CONSTRAINT IF EXISTS fk_carrito_cliente;

-- Eliminar tablas (orden inverso al de creación)
DROP TABLE IF EXISTS ventas.item_carrito CASCADE;
DROP TABLE IF EXISTS ventas.carrito CASCADE;