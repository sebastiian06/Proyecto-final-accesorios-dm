-- =====================================================
-- ÍNDICES PARA RENDIMIENTO
-- =====================================================

-- =====================================================
-- 1. ÍNDICES PARA SECURITY
-- =====================================================

-- Búsqueda de empleados por correo (login)
CREATE INDEX IF NOT EXISTS idx_empleado_correo ON security.empleado(correo);

-- Búsqueda de empleados por rol
CREATE INDEX IF NOT EXISTS idx_empleado_id_rol ON security.empleado(id_rol);

-- Búsqueda de empleados activos
CREATE INDEX IF NOT EXISTS idx_empleado_estado ON security.empleado(estado);

-- =====================================================
-- 2. ÍNDICES PARA CLIENTES
-- =====================================================

-- Búsqueda de clientes por correo (login)
CREATE INDEX IF NOT EXISTS idx_cliente_correo ON clientes.cliente(correo);

-- Búsqueda de clientes por nombre
CREATE INDEX IF NOT EXISTS idx_cliente_nombre ON clientes.cliente(nombre);

-- =====================================================
-- 3. ÍNDICES PARA CATÁLOGO
-- =====================================================

-- Búsqueda de productos por nombre
CREATE INDEX IF NOT EXISTS idx_producto_nombre ON catalogo.producto(nombre);

-- Búsqueda de productos por categoría
CREATE INDEX IF NOT EXISTS idx_producto_id_categoria ON catalogo.producto(id_categoria);

-- Búsqueda de productos por material
CREATE INDEX IF NOT EXISTS idx_producto_id_material ON catalogo.producto(id_material);

-- Búsqueda de productos por precio
CREATE INDEX IF NOT EXISTS idx_producto_precio ON catalogo.producto(precio);

-- Búsqueda de productos activos
CREATE INDEX IF NOT EXISTS idx_producto_estado ON catalogo.producto(estado);

-- Índice compuesto: categoría + precio (filtros comunes)
CREATE INDEX IF NOT EXISTS idx_producto_categoria_precio ON catalogo.producto(id_categoria, precio);

-- Índice compuesto: estado + precio (productos activos ordenados por precio)
CREATE INDEX IF NOT EXISTS idx_producto_estado_precio ON catalogo.producto(estado, precio);

-- Búsqueda de imágenes por producto
CREATE INDEX IF NOT EXISTS idx_imagen_producto_id_producto ON catalogo.imagen_producto(id_producto);

-- Índice para ordenamiento de imágenes
CREATE INDEX IF NOT EXISTS idx_imagen_producto_orden ON catalogo.imagen_producto(id_producto, orden);

-- =====================================================
-- 4. ÍNDICES PARA PROMOCIONES
-- =====================================================

-- Búsqueda de promociones activas por fechas
CREATE INDEX IF NOT EXISTS idx_promocion_activa_fechas ON promociones.promocion(activo, fecha_inicio, fecha_fin);

-- Búsqueda de promociones vigentes en fecha actual
CREATE INDEX IF NOT EXISTS idx_promocion_vigencia ON promociones.promocion(fecha_inicio, fecha_fin);

-- Búsqueda de productos en promoción
CREATE INDEX IF NOT EXISTS idx_promocion_producto_id_producto ON promociones.promocion_producto(id_producto);

-- Índice compuesto para aplicar promociones rápidamente
CREATE INDEX IF NOT EXISTS idx_promocion_producto_promocion_producto ON promociones.promocion_producto(id_promocion, id_producto);

-- =====================================================
-- 5. ÍNDICES PARA VENTAS (CARRITO)
-- =====================================================

-- Búsqueda de carritos activos por cliente
CREATE INDEX IF NOT EXISTS idx_carrito_cliente_estado ON ventas.carrito(id_cliente, estado);

-- Búsqueda de ítems por carrito (muy usado al mostrar carrito)
CREATE INDEX IF NOT EXISTS idx_item_carrito_carrito ON ventas.item_carrito(id_carrito);

-- Índice compuesto carrito-producto (evita duplicados en el carrito)
CREATE INDEX IF NOT EXISTS idx_item_carrito_carrito_producto ON ventas.item_carrito(id_carrito, id_producto);

-- =====================================================
-- 6. ÍNDICES PARA VENTAS (PEDIDOS)
-- =====================================================

-- Búsqueda de pedidos por cliente
CREATE INDEX IF NOT EXISTS idx_pedido_id_cliente ON ventas.pedido(id_cliente);

-- Búsqueda de pedidos por fecha (reportes)
CREATE INDEX IF NOT EXISTS idx_pedido_fecha_pedido ON ventas.pedido(fecha_pedido);

-- Búsqueda de pedidos por estado actual
CREATE INDEX IF NOT EXISTS idx_pedido_id_estado_actual ON ventas.pedido(id_estado_actual);

-- Índice compuesto: cliente + fecha (pedidos recientes de un cliente)
CREATE INDEX IF NOT EXISTS idx_pedido_cliente_fecha ON ventas.pedido(id_cliente, fecha_pedido);

-- Búsqueda de detalles por pedido
CREATE INDEX IF NOT EXISTS idx_detalle_pedido_id_pedido ON ventas.detalle_pedido(id_pedido);

-- Índice compuesto: pedido + producto
CREATE INDEX IF NOT EXISTS idx_detalle_pedido_pedido_producto ON ventas.detalle_pedido(id_pedido, id_producto);

-- =====================================================
-- 7. ÍNDICES PARA LOGISTICA
-- =====================================================

-- Búsqueda de historial por pedido
CREATE INDEX IF NOT EXISTS idx_historial_id_pedido ON logistica.historial_estado_pedido(id_pedido);

-- Búsqueda de historial por fecha (auditoría)
CREATE INDEX IF NOT EXISTS idx_historial_fecha_cambio ON logistica.historial_estado_pedido(fecha_cambio);

-- Índice compuesto: pedido + estado (evita duplicados en historial)
CREATE INDEX IF NOT EXISTS idx_historial_pedido_estado ON logistica.historial_estado_pedido(id_pedido, id_estado);

-- =====================================================
-- 8. ÍNDICES PARA INVENTARIO
-- =====================================================

-- Búsqueda de movimientos por producto
CREATE INDEX IF NOT EXISTS idx_inventario_movimiento_id_producto ON inventario.inventario_movimiento(id_producto);

-- Búsqueda de movimientos por fecha (reportes de inventario)
CREATE INDEX IF NOT EXISTS idx_inventario_movimiento_fecha ON inventario.inventario_movimiento(fecha_movimiento);

-- Búsqueda de movimientos por tipo
CREATE INDEX IF NOT EXISTS idx_inventario_movimiento_id_tipo ON inventario.inventario_movimiento(id_tipo_movimiento);

-- Índice compuesto: producto + fecha (movimientos por producto en un período)
CREATE INDEX IF NOT EXISTS idx_inventario_producto_fecha ON inventario.inventario_movimiento(id_producto, fecha_movimiento);