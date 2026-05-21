-- =====================================================
-- ROLLBACK: Eliminar tablas de catálogo
-- =====================================================

-- Eliminar llaves foráneas primero
ALTER TABLE IF EXISTS catalogo.producto DROP CONSTRAINT IF EXISTS fk_producto_categoria;
ALTER TABLE IF EXISTS catalogo.producto DROP CONSTRAINT IF EXISTS fk_producto_material;

-- Eliminar tablas (orden inverso al de creación)
DROP TABLE IF EXISTS catalogo.producto CASCADE;
DROP TABLE IF EXISTS catalogo.material CASCADE;
DROP TABLE IF EXISTS catalogo.categoria CASCADE;