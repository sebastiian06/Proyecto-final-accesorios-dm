-- Eliminar triggers
DROP TRIGGER IF EXISTS trg_update_stock_on_insert ON inventario.inventario_movimiento;
DROP TRIGGER IF EXISTS trg_update_stock_on_update ON inventario.inventario_movimiento;
DROP TRIGGER IF EXISTS trg_revert_stock_on_delete ON inventario.inventario_movimiento;