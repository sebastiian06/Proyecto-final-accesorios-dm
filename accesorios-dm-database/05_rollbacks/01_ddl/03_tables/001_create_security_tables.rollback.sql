-- =====================================================
-- ROLLBACK: Eliminar tablas de seguridad
-- =====================================================

-- Eliminar la llave foránea primero
ALTER TABLE IF EXISTS security.empleado DROP CONSTRAINT IF EXISTS fk_empleado_rol;

-- Eliminar las tablas (orden inverso al de creación)
DROP TABLE IF EXISTS security.empleado CASCADE;
DROP TABLE IF EXISTS security.rol CASCADE;