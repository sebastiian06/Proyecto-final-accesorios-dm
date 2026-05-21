-- =====================================================
-- POLITICAS DE SEGURIDAD RLS (Row Level Security)
-- =====================================================

-- =====================================================
-- 1. HABILITAR RLS EN LAS TABLAS
-- =====================================================

-- Security
ALTER TABLE security.empleado ENABLE ROW LEVEL SECURITY;
ALTER TABLE security.rol ENABLE ROW LEVEL SECURITY;

-- Clientes
ALTER TABLE clientes.cliente ENABLE ROW LEVEL SECURITY;

-- Ventas
ALTER TABLE ventas.pedido ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas.detalle_pedido ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas.carrito ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas.item_carrito ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. CREAR ROLES PARA LA APLICACION (sin DO para compatibilidad)
-- =====================================================

-- Rol para administradores (acceso total)
CREATE ROLE app_admin;

-- Rol para vendedores
CREATE ROLE app_vendedor;

-- Rol para clientes (solo ven sus propios datos)
CREATE ROLE app_cliente;

-- Rol para bodegueros (acceso a inventario)
CREATE ROLE app_bodeguero;

-- =====================================================
-- 3. POLITICAS PARA TABLA EMPLEADO
-- =====================================================

-- Administradores: pueden ver todos los empleados
CREATE POLICY empleado_admin_select ON security.empleado
    FOR SELECT
    TO app_admin
    USING (true);

-- Administradores: pueden modificar cualquier empleado
CREATE POLICY empleado_admin_all ON security.empleado
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

-- Empleados: solo ven su propio registro
CREATE POLICY empleado_self_select ON security.empleado
    FOR SELECT
    TO app_vendedor, app_bodeguero
    USING (correo = current_user);

-- =====================================================
-- 4. POLITICAS PARA TABLA CLIENTE
-- =====================================================

-- Administradores y vendedores: pueden ver todos los clientes
CREATE POLICY cliente_admin_vendedor_select ON clientes.cliente
    FOR SELECT
    TO app_admin, app_vendedor
    USING (true);

-- Clientes: solo ven su propio registro
CREATE POLICY cliente_self_select ON clientes.cliente
    FOR SELECT
    TO app_cliente
    USING (correo = current_user);

-- Clientes: pueden actualizar su propia informacion
CREATE POLICY cliente_self_update ON clientes.cliente
    FOR UPDATE
    TO app_cliente
    USING (correo = current_user)
    WITH CHECK (correo = current_user);

-- Administradores pueden modificar cualquier cliente
CREATE POLICY cliente_admin_all ON clientes.cliente
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

-- =====================================================
-- 5. POLITICAS PARA TABLA PEDIDO
-- =====================================================

-- Administradores y vendedores: pueden ver todos los pedidos
CREATE POLICY pedido_admin_vendedor_select ON ventas.pedido
    FOR SELECT
    TO app_admin, app_vendedor
    USING (true);

-- Clientes: solo ven sus propios pedidos
CREATE POLICY pedido_cliente_select ON ventas.pedido
    FOR SELECT
    TO app_cliente
    USING (id_cliente IN (SELECT id_cliente FROM clientes.cliente WHERE correo = current_user));

-- Clientes: pueden crear nuevos pedidos
CREATE POLICY pedido_cliente_insert ON ventas.pedido
    FOR INSERT
    TO app_cliente
    WITH CHECK (id_cliente IN (SELECT id_cliente FROM clientes.cliente WHERE correo = current_user));

-- =====================================================
-- 6. POLITICAS PARA TABLA DETALLE_PEDIDO
-- =====================================================

-- Administradores y vendedores: pueden ver todos los detalles
CREATE POLICY detalle_admin_vendedor_select ON ventas.detalle_pedido
    FOR SELECT
    TO app_admin, app_vendedor
    USING (true);

-- Clientes: solo ven detalles de sus propios pedidos
CREATE POLICY detalle_cliente_select ON ventas.detalle_pedido
    FOR SELECT
    TO app_cliente
    USING (id_pedido IN (
        SELECT id_pedido FROM ventas.pedido 
        WHERE id_cliente IN (SELECT id_cliente FROM clientes.cliente WHERE correo = current_user)
    ));

-- =====================================================
-- 7. POLITICAS PARA TABLA CARRITO
-- =====================================================

-- Clientes: solo ven su propio carrito activo
CREATE POLICY carrito_cliente_select ON ventas.carrito
    FOR SELECT
    TO app_cliente
    USING (id_cliente IN (SELECT id_cliente FROM clientes.cliente WHERE correo = current_user));

-- Clientes: pueden crear su carrito
CREATE POLICY carrito_cliente_insert ON ventas.carrito
    FOR INSERT
    TO app_cliente
    WITH CHECK (id_cliente IN (SELECT id_cliente FROM clientes.cliente WHERE correo = current_user));

-- Clientes: pueden actualizar su carrito
CREATE POLICY carrito_cliente_update ON ventas.carrito
    FOR UPDATE
    TO app_cliente
    USING (id_cliente IN (SELECT id_cliente FROM clientes.cliente WHERE correo = current_user));

-- =====================================================
-- 8. POLITICAS PARA TABLA ITEM_CARRITO
-- =====================================================

-- Clientes: solo ven items de su carrito
CREATE POLICY item_carrito_cliente_select ON ventas.item_carrito
    FOR SELECT
    TO app_cliente
    USING (id_carrito IN (
        SELECT id_carrito FROM ventas.carrito 
        WHERE id_cliente IN (SELECT id_cliente FROM clientes.cliente WHERE correo = current_user) AND estado = 'activo'
    ));

-- Clientes: pueden agregar/eliminar items de su carrito
CREATE POLICY item_carrito_cliente_all ON ventas.item_carrito
    FOR ALL
    TO app_cliente
    USING (id_carrito IN (
        SELECT id_carrito FROM ventas.carrito 
        WHERE id_cliente IN (SELECT id_cliente FROM clientes.cliente WHERE correo = current_user) AND estado = 'activo'
    ))
    WITH CHECK (id_carrito IN (
        SELECT id_carrito FROM ventas.carrito 
        WHERE id_cliente IN (SELECT id_cliente FROM clientes.cliente WHERE correo = current_user) AND estado = 'activo'
    ));

-- =====================================================
-- 9. ASIGNAR PERMISOS BASICOS
-- =====================================================

-- Conectar a la base de datos
GRANT CONNECT ON DATABASE accesorios_dm_db TO app_admin, app_vendedor, app_cliente, app_bodeguero;

-- Uso de schemas
GRANT USAGE ON SCHEMA security TO app_admin, app_vendedor, app_bodeguero, app_cliente;
GRANT USAGE ON SCHEMA clientes TO app_admin, app_vendedor, app_cliente;
GRANT USAGE ON SCHEMA catalogo TO app_admin, app_vendedor, app_bodeguero, app_cliente;
GRANT USAGE ON SCHEMA promociones TO app_admin, app_vendedor, app_cliente;
GRANT USAGE ON SCHEMA ventas TO app_admin, app_vendedor, app_cliente;
GRANT USAGE ON SCHEMA logistica TO app_admin, app_vendedor, app_cliente;
GRANT USAGE ON SCHEMA inventario TO app_admin, app_bodeguero;

-- =====================================================
-- 10. NOTA IMPORTANTE
-- =====================================================
-- Las politicas RLS requieren que la aplicacion se conecte con el rol correspondiente:
-- - app_admin: Usuarios con rol ADMIN
-- - app_vendedor: Usuarios con rol VENDEDOR
-- - app_bodeguero: Usuarios con rol BODEGUERO
-- - app_cliente: Usuarios con rol CLIENTE