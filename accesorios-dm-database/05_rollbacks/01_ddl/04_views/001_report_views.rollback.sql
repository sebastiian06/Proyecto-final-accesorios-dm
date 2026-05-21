-- =====================================================
-- ROLLBACK: Eliminar vistas de reportes
-- =====================================================

DROP VIEW IF EXISTS catalogo.vw_producto_detalle CASCADE;
DROP VIEW IF EXISTS promociones.vw_producto_promocion_activa CASCADE;
DROP VIEW IF EXISTS ventas.vw_pedido_cliente CASCADE;
DROP VIEW IF EXISTS ventas.vw_pedido_detalle_producto CASCADE;
DROP VIEW IF EXISTS logistica.vw_pedido_historial_estados CASCADE;
DROP VIEW IF EXISTS ventas.vw_carrito_activo_cliente CASCADE;
DROP VIEW IF EXISTS inventario.vw_movimientos_producto CASCADE;
DROP VIEW IF EXISTS inventario.vw_producto_bajo_stock CASCADE;
DROP VIEW IF EXISTS ventas.vw_ventas_por_mes CASCADE;
DROP VIEW IF EXISTS ventas.vw_top_productos_vendidos CASCADE;