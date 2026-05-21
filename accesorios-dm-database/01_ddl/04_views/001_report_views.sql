-- =====================================================
-- VISTAS PARA REPORTES
-- =====================================================

-- =====================================================
-- 1. VISTA: Productos con categoría y material
-- =====================================================
CREATE OR REPLACE VIEW catalogo.vw_producto_detalle AS
SELECT 
    p.id_producto,
    p.nombre AS producto_nombre,
    p.descripcion AS producto_descripcion,
    p.precio,
    p.stock,
    p.estado AS producto_activo,
    c.id_categoria,
    c.nombre AS categoria_nombre,
    c.descripcion AS categoria_descripcion,
    m.id_material,
    m.nombre AS material_nombre
FROM catalogo.producto p
LEFT JOIN catalogo.categoria c ON p.id_categoria = c.id_categoria
LEFT JOIN catalogo.material m ON p.id_material = m.id_material;

COMMENT ON VIEW catalogo.vw_producto_detalle IS 'Productos con información de categoría y material';

-- =====================================================
-- 2. VISTA: Productos con promociones activas
-- =====================================================
CREATE OR REPLACE VIEW promociones.vw_producto_promocion_activa AS
SELECT 
    p.id_producto,
    p.nombre AS producto_nombre,
    p.precio AS precio_original,
    prom.id_promocion,
    prom.nombre AS promocion_nombre,
    prom.porcentaje_descuento,
    pp.precio_promocional,
    (p.precio - pp.precio_promocional) AS ahorro,
    prom.fecha_inicio,
    prom.fecha_fin
FROM catalogo.producto p
INNER JOIN promociones.promocion_producto pp ON p.id_producto = pp.id_producto
INNER JOIN promociones.promocion prom ON pp.id_promocion = prom.id_promocion
WHERE prom.activo = TRUE 
  AND prom.fecha_inicio <= CURRENT_TIMESTAMP 
  AND prom.fecha_fin >= CURRENT_TIMESTAMP;

COMMENT ON VIEW promociones.vw_producto_promocion_activa IS 'Productos con promociones activas en el momento actual';

-- =====================================================
-- 3. VISTA: Pedidos con detalles de cliente
-- =====================================================
CREATE OR REPLACE VIEW ventas.vw_pedido_cliente AS
SELECT 
    p.id_pedido,
    p.direccion_envio,
    p.telefono_contacto,
    p.total,
    p.fecha_pedido,
    c.id_cliente,
    c.nombre AS cliente_nombre,
    c.correo AS cliente_correo,
    c.telefono AS cliente_telefono,
    ep.nombre AS estado_actual
FROM ventas.pedido p
INNER JOIN clientes.cliente c ON p.id_cliente = c.id_cliente
INNER JOIN logistica.estado_pedido ep ON p.id_estado_actual = ep.id_estado;

COMMENT ON VIEW ventas.vw_pedido_cliente IS 'Pedidos con información del cliente y estado actual';

-- =====================================================
-- 4. VISTA: Detalle de pedidos con productos
-- =====================================================
CREATE OR REPLACE VIEW ventas.vw_pedido_detalle_producto AS
SELECT 
    p.id_pedido,
    p.fecha_pedido,
    p.total AS pedido_total,
    c.nombre AS cliente_nombre,
    dp.id_detalle,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal,
    prod.id_producto,
    prod.nombre AS producto_nombre,
    ep.nombre AS estado_pedido
FROM ventas.pedido p
INNER JOIN clientes.cliente c ON p.id_cliente = c.id_cliente
INNER JOIN ventas.detalle_pedido dp ON p.id_pedido = dp.id_pedido
INNER JOIN catalogo.producto prod ON dp.id_producto = prod.id_producto
INNER JOIN logistica.estado_pedido ep ON p.id_estado_actual = ep.id_estado;

COMMENT ON VIEW ventas.vw_pedido_detalle_producto IS 'Detalle completo de pedidos con productos incluidos';

-- =====================================================
-- 5. VISTA: Historial de cambios de estado por pedido
-- =====================================================
CREATE OR REPLACE VIEW logistica.vw_pedido_historial_estados AS
SELECT 
    p.id_pedido,
    p.fecha_pedido,
    c.nombre AS cliente_nombre,
    he.fecha_cambio,
    he.observacion,
    e.nombre AS estado_nuevo
FROM ventas.pedido p
INNER JOIN clientes.cliente c ON p.id_cliente = c.id_cliente
INNER JOIN logistica.historial_estado_pedido he ON p.id_pedido = he.id_pedido
INNER JOIN logistica.estado_pedido e ON he.id_estado = e.id_estado
ORDER BY p.id_pedido, he.fecha_cambio DESC;

COMMENT ON VIEW logistica.vw_pedido_historial_estados IS 'Historial completo de cambios de estado por pedido';

-- =====================================================
-- 6. VISTA: Carritos activos con ítems
-- =====================================================
CREATE OR REPLACE VIEW ventas.vw_carrito_activo_cliente AS
SELECT 
    car.id_carrito,
    car.fecha_creacion,
    car.estado AS carrito_estado,
    c.id_cliente,
    c.nombre AS cliente_nombre,
    c.correo AS cliente_correo,
    COUNT(item.id_item_carrito) AS cantidad_productos,
    SUM(item.cantidad * item.precio_unitario) AS total_carrito
FROM ventas.carrito car
INNER JOIN clientes.cliente c ON car.id_cliente = c.id_cliente
LEFT JOIN ventas.item_carrito item ON car.id_carrito = item.id_carrito
WHERE car.estado = 'activo'
GROUP BY car.id_carrito, car.fecha_creacion, car.estado, c.id_cliente, c.nombre, c.correo;

COMMENT ON VIEW ventas.vw_carrito_activo_cliente IS 'Carritos activos con resumen de productos y total';

-- =====================================================
-- 7. VISTA: Movimientos de inventario por producto
-- =====================================================
CREATE OR REPLACE VIEW inventario.vw_movimientos_producto AS
SELECT 
    p.id_producto,
    p.nombre AS producto_nombre,
    p.stock AS stock_actual,
    m.id_movimiento,
    m.cantidad,
    CASE 
        WHEN m.cantidad > 0 THEN 'Entrada'
        WHEN m.cantidad < 0 THEN 'Salida'
        ELSE 'Sin movimiento'
    END AS tipo_movimiento,
    m.fecha_movimiento,
    m.referencia,
    tm.nombre AS tipo_movimiento_nombre
FROM catalogo.producto p
INNER JOIN inventario.inventario_movimiento m ON p.id_producto = m.id_producto
INNER JOIN inventario.tipo_movimiento tm ON m.id_tipo_movimiento = tm.id_tipo_movimiento
ORDER BY p.id_producto, m.fecha_movimiento DESC;

COMMENT ON VIEW inventario.vw_movimientos_producto IS 'Historial de movimientos de inventario por producto';

-- =====================================================
-- 8. VISTA: Productos con bajo stock
-- =====================================================
CREATE OR REPLACE VIEW inventario.vw_producto_bajo_stock AS
SELECT 
    p.id_producto,
    p.nombre AS producto_nombre,
    p.stock,
    p.precio,
    c.nombre AS categoria_nombre,
    CASE 
        WHEN p.stock <= 0 THEN 'Sin Stock'
        WHEN p.stock <= 5 THEN 'Stock Crítico'
        WHEN p.stock <= 10 THEN 'Stock Bajo'
        ELSE 'Stock Normal'
    END AS nivel_stock
FROM catalogo.producto p
INNER JOIN catalogo.categoria c ON p.id_categoria = c.id_categoria
WHERE p.stock <= 10 AND p.estado = TRUE
ORDER BY p.stock ASC;

COMMENT ON VIEW inventario.vw_producto_bajo_stock IS 'Productos con stock bajo o crítico';

-- =====================================================
-- 9. VISTA: Resumen de ventas por mes
-- =====================================================
CREATE OR REPLACE VIEW ventas.vw_ventas_por_mes AS
SELECT 
    EXTRACT(YEAR FROM p.fecha_pedido) AS anio,
    EXTRACT(MONTH FROM p.fecha_pedido) AS mes,
    TO_CHAR(p.fecha_pedido, 'YYYY-MM') AS periodo,
    COUNT(DISTINCT p.id_pedido) AS total_pedidos,
    COUNT(DISTINCT p.id_cliente) AS clientes_unicos,
    SUM(p.total) AS ventas_totales,
    AVG(p.total) AS ticket_promedio,
    SUM(dp.cantidad) AS productos_vendidos
FROM ventas.pedido p
LEFT JOIN ventas.detalle_pedido dp ON p.id_pedido = dp.id_pedido
WHERE p.id_estado_actual IN (SELECT id_estado FROM logistica.estado_pedido WHERE nombre IN ('ENTREGADO', 'PAGADO'))
GROUP BY EXTRACT(YEAR FROM p.fecha_pedido), EXTRACT(MONTH FROM p.fecha_pedido), TO_CHAR(p.fecha_pedido, 'YYYY-MM')
ORDER BY anio DESC, mes DESC;

COMMENT ON VIEW ventas.vw_ventas_por_mes IS 'Resumen de ventas agregado por mes';

-- =====================================================
-- 10. VISTA: Top 10 productos más vendidos
-- =====================================================
CREATE OR REPLACE VIEW ventas.vw_top_productos_vendidos AS
SELECT 
    prod.id_producto,
    prod.nombre AS producto_nombre,
    prod.precio,
    SUM(dp.cantidad) AS total_vendido,
    SUM(dp.subtotal) AS total_generado,
    COUNT(DISTINCT p.id_pedido) AS veces_pedido
FROM catalogo.producto prod
INNER JOIN ventas.detalle_pedido dp ON prod.id_producto = dp.id_producto
INNER JOIN ventas.pedido p ON dp.id_pedido = p.id_pedido
WHERE p.id_estado_actual IN (SELECT id_estado FROM logistica.estado_pedido WHERE nombre IN ('ENTREGADO', 'PAGADO'))
GROUP BY prod.id_producto, prod.nombre, prod.precio
ORDER BY total_vendido DESC
LIMIT 10;

COMMENT ON VIEW ventas.vw_top_productos_vendidos IS 'Top 10 productos más vendidos';