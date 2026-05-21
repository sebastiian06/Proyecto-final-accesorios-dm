-- Eliminar funciones
DROP FUNCTION IF EXISTS inventario.f_update_stock_on_insert() CASCADE;
DROP FUNCTION IF EXISTS inventario.f_update_stock_on_update() CASCADE;
DROP FUNCTION IF EXISTS inventario.f_revert_stock_on_delete() CASCADE;