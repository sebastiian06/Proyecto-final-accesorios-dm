-- =====================================================
-- ROLLBACK: Eliminar políticas RLS
-- =====================================================

-- Eliminar políticas de empleado
DROP POLICY IF EXISTS empleado_admin_select ON security.empleado;
DROP POLICY IF EXISTS empleado_admin_all ON security.empleado;
DROP POLICY IF EXISTS empleado_self_select ON security.empleado;

-- Eliminar políticas de cliente
DROP POLICY IF EXISTS cliente_admin_vendedor_select ON clientes.cliente;
DROP POLICY IF EXISTS cliente_self_select ON clientes.cliente;
DROP POLICY IF EXISTS cliente_self_update ON clientes.cliente;
DROP POLICY IF EXISTS cliente_admin_all ON clientes.cliente;

-- Eliminar políticas de pedido
DROP POLICY IF EXISTS pedido_admin_vendedor_select ON ventas.pedido;
DROP POLICY IF EXISTS pedido_cliente_select ON ventas.pedido;
DROP POLICY IF EXISTS pedido_cliente_insert ON ventas.pedido;

-- Eliminar políticas de detalle pedido
DROP POLICY IF EXISTS detalle_admin_vendedor_select ON ventas.detalle_pedido;
DROP POLICY IF EXISTS detalle_cliente_select ON ventas.detalle_pedido;

-- Eliminar políticas de carrito
DROP POLICY IF EXISTS carrito_cliente_select ON ventas.carrito;
DROP POLICY IF EXISTS carrito_cliente_insert ON ventas.carrito;
DROP POLICY IF EXISTS carrito_cliente_update ON ventas.carrito;

-- Eliminar políticas de item carrito
DROP POLICY IF EXISTS item_carrito_cliente_select ON ventas.item_carrito;
DROP POLICY IF EXISTS item_carrito_cliente_all ON ventas.item_carrito;

-- Deshabilitar RLS en las tablas
ALTER TABLE security.empleado DISABLE ROW LEVEL SECURITY;
ALTER TABLE security.rol DISABLE ROW LEVEL SECURITY;
ALTER TABLE clientes.cliente DISABLE ROW LEVEL SECURITY;
ALTER TABLE ventas.pedido DISABLE ROW LEVEL SECURITY;
ALTER TABLE ventas.detalle_pedido DISABLE ROW LEVEL SECURITY;
ALTER TABLE ventas.carrito DISABLE ROW LEVEL SECURITY;
ALTER TABLE ventas.item_carrito DISABLE ROW LEVEL SECURITY;

-- Eliminar roles (opcional)
-- DROP ROLE IF EXISTS app_admin;
-- DROP ROLE IF EXISTS app_vendedor;
-- DROP ROLE IF EXISTS app_cliente;
-- DROP ROLE IF EXISTS app_bodeguero;