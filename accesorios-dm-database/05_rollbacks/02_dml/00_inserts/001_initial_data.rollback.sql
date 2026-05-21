-- =====================================================
-- ROLLBACK: Eliminar datos iniciales insertados
-- =====================================================

-- Eliminar empleados de ejemplo
DELETE FROM security.empleado WHERE correo IN ('admin@accesoriosdm.com', 'vendedor@accesoriosdm.com');

-- Eliminar cliente demo
DELETE FROM clientes.cliente WHERE correo = 'demo@accesoriosdm.com';

-- Eliminar productos de ejemplo
DELETE FROM catalogo.producto WHERE nombre IN (
    'Anillo de compromiso Oro 18K',
    'Collar de Perlas Plata 925',
    'Pulsera de Acero Inoxidable',
    'Aretes de Oro 14K',
    'Dije de Corazón Plata 925',
    'Anillo de Plata Ley',
    'Collar de Titanio Hombre',
    'Pulsera de Cobre Energía'
);

-- Eliminar categorías de ejemplo
DELETE FROM catalogo.categoria WHERE nombre IN (
    'Anillos', 'Collares', 'Pulseras', 'Aretes', 'Dijes', 'Llaveros', 'Conjuntos'
);

-- Eliminar materiales de ejemplo
DELETE FROM catalogo.material WHERE nombre IN (
    'Oro 18K', 'Oro 14K', 'Plata 925', 'Acero Inoxidable', 'Titanio', 'Cobre', 'Plata de Ley'
);

-- Eliminar tipos de movimiento de ejemplo
DELETE FROM inventario.tipo_movimiento WHERE nombre IN ('ENTRADA', 'SALIDA', 'AJUSTE');

-- Eliminar estados de pedido de ejemplo
DELETE FROM logistica.estado_pedido WHERE nombre IN ('PENDIENTE', 'PAGADO', 'ENVIADO', 'ENTREGADO', 'CANCELADO');

-- Eliminar roles de ejemplo (solo si no tienen empleados asociados)
DELETE FROM security.rol WHERE nombre IN ('ADMIN', 'VENDEDOR', 'BODEGUERO', 'CLIENTE');