-- =====================================================
-- ROLLBACK: Eliminar índices de rendimiento
-- =====================================================

-- Security
DROP INDEX IF EXISTS security.idx_empleado_correo;
DROP INDEX IF EXISTS security.idx_empleado_id_rol;
DROP INDEX IF EXISTS security.idx_empleado_estado;

-- Clientes
DROP INDEX IF EXISTS clientes.idx_cliente_correo;
DROP INDEX IF EXISTS clientes.idx_cliente_nombre;

-- Catálogo
DROP INDEX IF EXISTS catalogo.idx_producto_nombre;
DROP INDEX IF EXISTS catalogo.idx_producto_id_categoria;
DROP INDEX IF EXISTS catalogo.idx_producto_id_material;
DROP INDEX IF EXISTS catalogo.idx_producto_precio;
DROP INDEX IF EXISTS catalogo.idx_producto_estado;
DROP INDEX IF EXISTS catalogo.idx_producto_categoria_precio;
DROP INDEX IF EXISTS catalogo.idx_producto_estado_precio;
DROP INDEX IF EXISTS catalogo.idx_imagen_producto_id_producto;
DROP INDEX IF EXISTS catalogo.idx_imagen_producto_orden;

-- Promociones
DROP INDEX IF EXISTS promociones.idx_promocion_activa_fechas;
DROP INDEX IF EXISTS promociones.idx_promocion_vigencia;
DROP INDEX IF EXISTS promociones.idx_promocion_producto_id_producto;
DROP INDEX IF EXISTS promociones.idx_promocion_producto_promocion_producto;

-- Ventas (Carrito)
DROP INDEX IF EXISTS ventas.idx_carrito_cliente_estado;
DROP INDEX IF EXISTS ventas.idx_item_carrito_carrito;
DROP INDEX IF EXISTS ventas.idx_item_carrito_carrito_producto;

-- Ventas (Pedidos)
DROP INDEX IF EXISTS ventas.idx_pedido_id_cliente;
DROP INDEX IF EXISTS ventas.idx_pedido_fecha_pedido;
DROP INDEX IF EXISTS ventas.idx_pedido_id_estado_actual;
DROP INDEX IF EXISTS ventas.idx_pedido_cliente_fecha;
DROP INDEX IF EXISTS ventas.idx_detalle_pedido_id_pedido;
DROP INDEX IF EXISTS ventas.idx_detalle_pedido_pedido_producto;

-- Logística
DROP INDEX IF EXISTS logistica.idx_historial_id_pedido;
DROP INDEX IF EXISTS logistica.idx_historial_fecha_cambio;
DROP INDEX IF EXISTS logistica.idx_historial_pedido_estado;

-- Inventario
DROP INDEX IF EXISTS inventario.idx_inventario_movimiento_id_producto;
DROP INDEX IF EXISTS inventario.idx_inventario_movimiento_fecha;
DROP INDEX IF EXISTS inventario.idx_inventario_movimiento_id_tipo;
DROP INDEX IF EXISTS inventario.idx_inventario_producto_fecha;