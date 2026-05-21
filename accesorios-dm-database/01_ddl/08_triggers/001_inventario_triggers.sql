-- =====================================================
-- TRIGGERS PARA INVENTARIO
-- =====================================================

-- Eliminar triggers si existen
DROP TRIGGER IF EXISTS trg_update_stock_on_insert ON inventario.inventario_movimiento;
DROP TRIGGER IF EXISTS trg_update_stock_on_update ON inventario.inventario_movimiento;
DROP TRIGGER IF EXISTS trg_revert_stock_on_delete ON inventario.inventario_movimiento;

-- Crear triggers
CREATE TRIGGER trg_update_stock_on_insert
    AFTER INSERT ON inventario.inventario_movimiento
    FOR EACH ROW
    EXECUTE FUNCTION inventario.f_update_stock_on_insert();

CREATE TRIGGER trg_update_stock_on_update
    AFTER UPDATE OF cantidad ON inventario.inventario_movimiento
    FOR EACH ROW
    EXECUTE FUNCTION inventario.f_update_stock_on_update();

CREATE TRIGGER trg_revert_stock_on_delete
    BEFORE DELETE ON inventario.inventario_movimiento
    FOR EACH ROW
    EXECUTE FUNCTION inventario.f_revert_stock_on_delete();