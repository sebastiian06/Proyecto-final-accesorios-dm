-- =====================================================
-- ROLLBACK: Eliminar tabla IMAGEN_PRODUCTO
-- =====================================================

-- Eliminar llave foránea
ALTER TABLE IF EXISTS catalogo.imagen_producto DROP CONSTRAINT IF EXISTS fk_imagen_producto;

-- Eliminar tabla
DROP TABLE IF EXISTS catalogo.imagen_producto CASCADE;