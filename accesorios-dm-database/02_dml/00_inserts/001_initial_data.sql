-- =====================================================
-- DATOS INICIALES
-- =====================================================

-- 1. ROLES
INSERT INTO security.rol (nombre, descripcion) VALUES
    ('ADMIN', 'Administrador del sistema'),
    ('VENDEDOR', 'Vendedor'),
    ('BODEGUERO', 'Encargado de inventario'),
    ('CLIENTE', 'Cliente del sistema')
ON CONFLICT (nombre) DO NOTHING;

-- 2. TIPOS DE MOVIMIENTO (necesarios para inventario)
INSERT INTO inventario.tipo_movimiento (nombre, descripcion) VALUES
    ('ENTRADA', 'Ingreso de productos al inventario'),
    ('SALIDA', 'Salida de productos del inventario'),
    ('AJUSTE', 'Ajuste manual de inventario')
ON CONFLICT (nombre) DO NOTHING;

-- 3. ESTADOS DE PEDIDO
INSERT INTO logistica.estado_pedido (nombre, descripcion) VALUES
    ('PENDIENTE', 'Pedido creado'),
    ('PAGADO', 'Pago confirmado'),
    ('ENVIADO', 'Pedido enviado'),
    ('ENTREGADO', 'Pedido entregado'),
    ('CANCELADO', 'Pedido cancelado')
ON CONFLICT (nombre) DO NOTHING;

-- 4. CATEGORIAS
INSERT INTO catalogo.categoria (nombre, descripcion, estado) VALUES
    ('General', 'Categoria general', TRUE),
    ('Anillos', 'Anillos en diferentes estilos', TRUE),
    ('Collares', 'Collares y gargantillas', TRUE),
    ('Pulseras', 'Pulseras y brazaletes', TRUE)
ON CONFLICT (nombre) DO NOTHING;

-- 5. MATERIALES
INSERT INTO catalogo.material (nombre, descripcion) VALUES
    ('General', 'Material general'),
    ('Oro 18K', 'Oro de 18 quilates'),
    ('Plata 925', 'Plata esterlina'),
    ('Acero Inoxidable', 'Acero quirurgico')
ON CONFLICT (nombre) DO NOTHING;

-- 6. PRODUCTOS
INSERT INTO catalogo.producto (nombre, descripcion, precio, stock, estado, id_categoria, id_material)
SELECT * FROM (VALUES
    ('Producto Demo', 'Producto de demostracion', 100000, 50, TRUE, 
     (SELECT id_categoria FROM catalogo.categoria WHERE nombre = 'General'),
     (SELECT id_material FROM catalogo.material WHERE nombre = 'General'))
) AS v(nombre, descripcion, precio, stock, estado, id_categoria, id_material)
WHERE NOT EXISTS (SELECT 1 FROM catalogo.producto WHERE nombre = 'Producto Demo');

-- 7. CLIENTE DEMO
INSERT INTO clientes.cliente (nombre, correo, telefono) VALUES
    ('Cliente Demo', 'demo@accesoriosdm.com', '3001234567')
ON CONFLICT (correo) DO NOTHING;

-- 8. EMPLEADO ADMIN
INSERT INTO security.empleado (nombre, correo, password, estado, id_rol) VALUES
    ('Administrador', 'admin@accesoriosdm.com', 'admin123', TRUE,
     (SELECT id_rol FROM security.rol WHERE nombre = 'ADMIN'))
ON CONFLICT (correo) DO NOTHING;