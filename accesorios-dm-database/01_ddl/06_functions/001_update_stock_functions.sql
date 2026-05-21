-- =====================================================
-- FUNCIONES PARA ACTUALIZAR STOCK
-- Schema: inventario
-- =====================================================

-- Funcion: Actualizar stock cuando se inserta un movimiento
CREATE OR REPLACE FUNCTION inventario.f_update_stock_on_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS '
BEGIN
    UPDATE catalogo.producto
    SET stock = stock + NEW.cantidad
    WHERE id_producto = NEW.id_producto;
    RETURN NEW;
END;
';

-- Funcion: Actualizar stock cuando se actualiza un movimiento
CREATE OR REPLACE FUNCTION inventario.f_update_stock_on_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS '
BEGIN
    UPDATE catalogo.producto
    SET stock = stock - OLD.cantidad + NEW.cantidad
    WHERE id_producto = NEW.id_producto;
    RETURN NEW;
END;
';

-- Funcion: Revertir stock cuando se elimina un movimiento
CREATE OR REPLACE FUNCTION inventario.f_revert_stock_on_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS '
BEGIN
    UPDATE catalogo.producto
    SET stock = stock - OLD.cantidad
    WHERE id_producto = OLD.id_producto;
    RETURN OLD;
END;
';