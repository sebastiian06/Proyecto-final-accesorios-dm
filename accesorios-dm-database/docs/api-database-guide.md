# Guía de Base de Datos para Microservicios

## Arquitectura General
```
┌─────────────────────────────────────────────────────────────────┐
│                           API Gateway                           │
└─────────────────────────────────────────────────────────────────┘
                        │                │
       ┌────────────────┼────────────────┼────────────────┐ 
       │                │                │                │            
       ▼                ▼                ▼                ▼            
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Microservicio│ │ Microservicio│ │ Microservicio│ │ Otros...     │
│ Seguridad    │ │ Inventario   │ │ Carrito      │ │              │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
       │                │                │                │
       └────────────────┼────────────────┼────────────────┘
                        ▼                ▼
                ┌─────────────────────────────────┐
                │ PostgreSQL (Base de Datos)      │
                │ accesorios_dm_db                │
                └─────────────────────────────────┘
```


## Conexión a la Base de Datos

### Datos de conexión por ambiente

| Ambiente | Host | Puerto | Base de datos | Usuario |
|----------|------|--------|---------------|---------|
| Desarrollo (develop) | localhost | 5432 | accesorios_dm_db | admin |
| Calidad (qa) | localhost | 5433 | accesorios_dm_db | admin |
| Producción (main) | localhost | 5434 | accesorios_dm_db | admin |

### Cadena de conexión (JDBC)

```properties
# Desarrollo
jdbc:postgresql://localhost:5432/accesorios_dm_db

# QA
jdbc:postgresql://localhost:5433/accesorios_dm_db

# Producción
jdbc:postgresql://localhost:5434/accesorios_dm_db
```

### Cadena de conexión (Node.js)

```javascript
// Desarrollo (develop)
const config = {
    host: 'localhost',
    port: 5432,
    database: 'accesorios_dm_db',
    user: 'admin',
    password: 'admin123'
}

// Calidad (qa)
const config = {
    host: 'localhost',
    port: 5433,
    database: 'accesorios_dm_db',
    user: 'admin',
    password: 'admin123'
}

// Produccion (main)
const config = {
    host: 'localhost',
    port: 5434,
    database: 'accesorios_dm_db',
    user: 'admin',
    password: 'admin123'
}
```

### Variables de entorno recomendadas

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=accesorios_dm_db
DB_USER=admin
DB_PASSWORD=admin123
DB_SCHEMA=public
```

### Roles de Conexión por Microservicio

|Microservicio	|Rol de BD	|Permisos|
|---------------|-----------|--------|
|Seguridad	|app_admin o app_vendedor	|CRUD en security, clientes, ventas|
|Catálogo	|app_vendedor o app_bodeguero	|Lectura en catalogo, promociones|
|Carrito/Pedidos	|app_cliente	|Lectura/escritura en ventas, clientes|

### Conectar con rol específico

```sql
-- Para microservicio de seguridad (admin)
SET ROLE app_admin;

-- Para microservicio de catálogo (vendedor)
SET ROLE app_vendedor;

-- Para microservicio de carrito (cliente)
SET ROLE app_cliente;
```

## Esquemas y Responsabilidades

|Esquema	|Propósito	|Microservicio responsable|
|-----------|-----------|-------------------------|
|security	|Roles y empleados	|Seguridad|
|clientes	|Clientes	|Seguridad / Carrito|
|catalogo	|Productos, categorías, materiales, imágenes	|Catálogo|
|promociones	|Promociones y descuentos	|Catálogo|
|ventas	|Carritos, pedidos, detalles	|Carrito|
|logistica	|Estados de pedido, historial	|Carrito|
|inventario	|Movimientos de inventario	|Catálogo|

## 1. MICROSERVICIO DE SEGURIDAD

### Responsabilidades
- Autenticación y autorización de usuarios

- Gestión de empleados

- Gestión de clientes

### Tablas que le pertenecen

|Tabla	|Operaciones	|Observaciones|
|-------|---------------|-------------|
|security.rol	|SELECT	|Solo lectura (datos maestros)|
|security.empleado	|SELECT, INSERT, UPDATE, DELETE	|CRUD completo|
|clientes.cliente	|SELECT, INSERT, UPDATE	|Gestión de clientes|

### Consultas típicas

```sql
-- Obtener empleado por correo (login)
SELECT e.id_empleado, e.nombre, e.correo, e.password, e.estado, r.nombre AS rol
FROM security.empleado e
INNER JOIN security.rol r ON e.id_rol = r.id_rol
WHERE e.correo = 'usuario@email.com' AND e.estado = TRUE;

-- Crear nuevo cliente
INSERT INTO clientes.cliente (nombre, correo, telefono)
VALUES ('Nuevo Cliente', 'cliente@email.com', '3001234567')
RETURNING id_cliente;

-- Obtener todos los empleados
SELECT e.id_empleado, e.nombre, e.correo, e.estado, r.nombre AS rol
FROM security.empleado e
INNER JOIN security.rol r ON e.id_empleado = r.id_rol;
```

## 2. MICROSERVICIO DE INVENTARIO - CATÁLOGO

### Responsabilidades

- Gestión de productos

- Gestión de categorías y materiales

- Gestión de imágenes de productos

- Gestión de promociones

- Control de inventario

### Tablas que le pertenecen

|Tabla	|Operaciones	|Observaciones|
|-------|---------------|-------------|
|catalogo.categoria	|SELECT, INSERT, UPDATE, DELETE	|CRUD completo|
|catalogo.material	|SELECT, INSERT, UPDATE, DELETE	|CRUD completo|
|catalogo.producto	|SELECT, INSERT, UPDATE, DELETE	|CRUD completo|
|catalogo.imagen_producto	|SELECT, INSERT, UPDATE, DELETE	|CRUD completo|
|promociones.promocion	|SELECT, INSERT, UPDATE, DELETE	|CRUD completo|
|promociones.promocion_producto	|SELECT, INSERT, UPDATE, DELETE	|Relación N:M|
|inventario.tipo_movimiento	|SELECT	|Solo lectura|
|inventario.inventario_movimiento	|INSERT	|Solo insertar movimientos|

### Vistas útiles

|Vista	|Propósito|
|-------|---------|
|catalogo.vw_producto_detalle	|Productos con categoría y material|
|promociones.vw_producto_promocion_activa	|Productos con promociones vigentes|
|inventario.vw_movimientos_producto	|Historial de movimientos por producto|
|inventario.vw_producto_bajo_stock	|Alerta de productos con stock bajo|


### Consultas típicas

```sql
-- Obtener todos los productos activos
SELECT p.id_producto, p.nombre, p.descripcion, p.precio, p.stock,
       c.nombre AS categoria, m.nombre AS material
FROM catalogo.producto p
LEFT JOIN catalogo.categoria c ON p.id_categoria = c.id_categoria
LEFT JOIN catalogo.material m ON p.id_material = m.id_material
WHERE p.estado = TRUE
ORDER BY p.nombre;

-- Obtener detalle de un producto (con imágenes)
SELECT p.id_producto, p.nombre, p.descripcion, p.precio, p.stock,
       c.nombre AS categoria, m.nombre AS material,
       i.url_imagen, i.orden
FROM catalogo.producto p
LEFT JOIN catalogo.categoria c ON p.id_categoria = c.id_categoria
LEFT JOIN catalogo.material m ON p.id_material = m.id_material
LEFT JOIN catalogo.imagen_producto i ON p.id_producto = i.id_producto
WHERE p.id_producto = 1
ORDER BY i.orden;

-- Buscar productos por nombre
SELECT id_producto, nombre, precio, stock
FROM catalogo.producto
WHERE nombre ILIKE '%anillo%' AND estado = TRUE;

-- Registrar movimiento de inventario (entrada)
INSERT INTO inventario.inventario_movimiento (cantidad, referencia, id_producto, id_tipo_movimiento)
VALUES (10, 'Compra #123', 1, 1);

-- Obtener productos con bajo stock (alerta)
SELECT * FROM inventario.vw_producto_bajo_stock;
```

## 3. MICROSERVICIO DE CARRITO Y PEDIDOS

### Responsabilidades

- Gestión del carrito de compras

- Procesamiento de pedidos

- Historial de pedidos

- Seguimiento de estados

### Tablas que le pertenecen

|Tabla	|Operaciones	|Observaciones|
|-------|---------------|-------------|
|ventas.carrito	|SELECT, INSERT, UPDATE	|Carrito activo del cliente|
|ventas.item_carrito	|SELECT, INSERT, UPDATE, DELETE	|Ítems del carrito|
|ventas.pedido	|SELECT, INSERT	|Crear pedido desde carrito|
|ventas.detalle_pedido	|SELECT, INSERT	|Detalle del pedido|
|logistica.estado_pedido	|SELECT	|Solo lectura (catálogo)|
|logistica.historial_estado_pedido	|INSERT	|Registrar cambios de estado|

### Vistas útiles

|Vista	|Propósito|
|-------|---------|
|ventas.vw_carrito_activo_cliente	|Carrito activo con resumen|
|ventas.vw_pedido_cliente	|Pedidos del cliente|
|ventas.vw_pedido_detalle_producto	|Detalle completo de pedido|
|logistica.vw_pedido_historial_estados	|Historial de estados por pedido|

### Consultas típicas

```sql
-- Obtener carrito activo del cliente
SELECT car.id_carrito, car.fecha_creacion,
       item.id_item_carrito, item.cantidad, item.precio_unitario,
       p.id_producto, p.nombre AS producto_nombre, p.precio
FROM ventas.carrito car
LEFT JOIN ventas.item_carrito item ON car.id_carrito = item.id_carrito
LEFT JOIN catalogo.producto p ON item.id_producto = p.id_producto
WHERE car.id_cliente = 1 AND car.estado = 'activo';

-- Agregar producto al carrito
INSERT INTO ventas.item_carrito (cantidad, precio_unitario, id_carrito, id_producto)
VALUES (2, 150000, 1, 5);

-- Crear pedido desde carrito (transacción)
BEGIN;
    -- 1. Crear el pedido
    INSERT INTO ventas.pedido (direccion_envio, telefono_contacto, total, id_cliente, id_estado_actual)
    VALUES ('Calle 123', '3001234567', 250000, 1, 1)
    RETURNING id_pedido;
    
    -- 2. Insertar detalles del pedido
    INSERT INTO ventas.detalle_pedido (cantidad, precio_unitario, id_pedido, id_producto)
    SELECT cantidad, precio_unitario, id_pedido, id_producto
    FROM ventas.item_carrito
    WHERE id_carrito = 1;
    
    -- 3. Registrar salida de inventario
    INSERT INTO inventario.inventario_movimiento (cantidad, referencia, id_producto, id_tipo_movimiento)
    SELECT -cantidad, 'Venta Pedido # ' || id_pedido, id_producto, 2
    FROM ventas.detalle_pedido;
    
    -- 4. Registrar historial de estado
    INSERT INTO logistica.historial_estado_pedido (observacion, id_pedido, id_estado)
    VALUES ('Pedido creado', id_pedido, 1);
    
    -- 5. Marcar carrito como procesado
    UPDATE ventas.carrito SET estado = 'procesado' WHERE id_carrito = 1;
COMMIT;

-- Obtener historial de pedidos del cliente
SELECT * FROM ventas.vw_pedido_cliente WHERE id_cliente = 1;

-- Obtener detalle de un pedido específico
SELECT * FROM ventas.vw_pedido_detalle_producto WHERE id_pedido = 1;

-- Actualizar estado del pedido
DO $$
DECLARE
    v_nuevo_estado INTEGER;
BEGIN
    -- Obtener ID del nuevo estado
    SELECT id_estado INTO v_nuevo_estado FROM logistica.estado_pedido WHERE nombre = 'PAGADO';
    
    -- Actualizar estado actual del pedido
    UPDATE ventas.pedido SET id_estado_actual = v_nuevo_estado WHERE id_pedido = 1;
    
    -- Registrar en historial
    INSERT INTO logistica.historial_estado_pedido (observacion, id_pedido, id_estado)
    VALUES ('Cliente realizó pago', 1, v_nuevo_estado);
END $$;
```

## Reglas de Negocio Implementadas (Triggers)

|Trigger	|Evento	|Acción|
|-----------|-------|------|
|trg_update_stock_on_insert	|INSERT en inventario_movimiento	|Actualiza stock del producto|
|trg_update_stock_on_update	|UPDATE en inventario_movimiento	|Recalcula stock|
|trg_revert_stock_on_delete	|DELETE en inventario_movimiento	|Revierte cambios de stock|


## Efecto de los triggers

```sql
-- Cuando insertas un movimiento, el stock se actualiza automáticamente
INSERT INTO inventario.inventario_movimiento (cantidad, referencia, id_producto, id_tipo_movimiento)
VALUES (5, 'Compra', 1, 1);  -- ENTrada

-- El stock del producto aumenta en 5 automáticamente
SELECT stock FROM catalogo.producto WHERE id_producto = 1;
```

## Estados de Pedido (Catálogo)

|id_estado	|nombre	|Descripción|
|-----------|-------|-----------|
|1	|PENDIENTE	|Pedido creado, esperando pago|
|2	|PAGADO	|Pago confirmado, preparando envío|
|3	|ENVIADO	|Pedido en camino|
|4	|ENTREGADO	|Pedido entregado exitosamente|
|5	|CANCELADO	|Pedido cancelado|


## Transiciones de estado permitidas

```text
PENDIENTE → PAGADO → ENVIADO → ENTREGADO
PENDIENTE → CANCELADO
```

## Tipos de Movimiento de Inventario

|id_tipo_movimiento	|nombre	|Signo	|Descripción|
|-------------------|-------|-------|-----------|
|1	|ENTRADA	|+	|Ingreso de productos (compras, devoluciones)|
|2	|SALIDA	|-	|Salida de productos (ventas)|
|3	|AJUSTE	|±	|Ajuste manual de inventario|


## Políticas de Seguridad (RLS)

### Acceso por microservicio

|Tabla	|app_admin	|app_vendedor	|app_cliente	|app_bodeguero|
|-------|-----------|---------------|---------------|-------------|
|security.empleado	|✅ CRUD	|SELECT (solo su perfil)	|❌	|SELECT (solo su perfil)|
|clientes.cliente	|✅ CRUD	|✅ SELECT	|SELECT/UPDATE (solo su perfil)	|❌|
|catalogo.producto	|✅ CRUD	|✅ CRUD	|SELECT	|SELECT|
|ventas.carrito	|✅ CRUD	|✅ SELECT	    |✅ CRUD (solo su carrito)	   | ❌|  
|ventas.pedido	|✅ CRUD	|✅ SELECT	   | SELECT/INSERT (solo sus pedidos)	    |❌|  
|inventario.inventario_movimiento	|✅ CRUD	|SELECT	|❌	|✅ INSERT|


### Cómo probar roles localmente

```sql
-- Cuando insertas un movimiento, el stock se actualiza automáticamente
INSERT INTO inventario.inventario_movimiento (cantidad, referencia, id_producto, id_tipo_movimiento)
VALUES (5, 'Compra', 1, 1);  -- ENTrada

-- El stock del producto aumenta en 5 automáticamente
SELECT stock FROM catalogo.producto WHERE id_producto = 1;
```

### Scripts de Verificación

**Ejecutar desde PowerShell en la raíz del proyecto:**

```powershell
# Verificar todo el ambiente de desarrollo
.\scripts.\verify-all.ps1

# Verificar solo develop
.\scripts\verify-develop.ps1

# Verificar solo QA
.\scripts\verify-qa.ps1
```

## Diagrama de Tablas (Relaciones)

```text
security                    clientes                catalogo
┌─────────────┐            ┌─────────────┐         ┌─────────────┐
│    rol      │            │   cliente   │         │  categoria  │
├─────────────┤            ├─────────────┤         ├─────────────┤
│ id_rol (PK) │◄──┐        │ id_cliente  │         │id_categoria │
│ nombre      │   │        │ nombre      │         │  nombre     │
└─────────────┘   │        │ correo      │         └─────────────┘
                  │        └─────────────┘               │
┌─────────────┐   │              │                       │
│  empleado   │   │              │                       │
├─────────────┤   │              │                       │
│id_empleado  │   │              │                       │
│ nombre      │   │              │                       │
│ correo      │   │              │                       │
│ id_rol (FK) ├───┘              │                       │
└─────────────┘                  │                       │
                                 │                       │
                           ┌─────┴─────┐                 │
                           │  pedido   │                 │
                           ├───────────┤                 │
                           │id_pedido  │     ┌───────────┴───────────┐
                           │id_cliente ├────►│       producto        │
                           │id_estado  │     ├───────────────────────┤
                           └───────────┘     │ id_producto (PK)      │
                                 │           │ nombre                │
                                 │           │ precio                │
                                 │           │ stock                 │
                                 │           │ id_categoria (FK)     │
                                 │           │ id_material (FK)      │
                           ┌─────┴─────┐     └───────────────────────┘
                           │detalle_   │                │         │
                           │ pedido    │                │         │
                           ├───────────┤                │         │
                           │id_detalle │                │         │
                           │id_pedido  ├────────────────┘         │
                           │id_producto├──────────────────────────┘
                           └───────────┘
```

## Preguntas Frecuentes

### ¿Cómo manejar la concurrencia?


Los triggers y transacciones manejan la integridad de datos. Usar transacciones para operaciones que involucran múltiples tablas.

### ¿Cómo hacer rollback de una operación?
```sql
BEGIN;
-- operaciones...
ROLLBACK; -- deshace todo
-- o
COMMIT; -- confirma
```

### ¿Cómo ver el historial de cambios en la base de datos?

```sql
SELECT * FROM databasechangelog ORDER BY dateexecuted DESC;
```


### Contacto y Soporte

**Para dudas sobre la estructura de la base de datos:**

- Revisar la documentación en docs/

- Ejecutar scripts de verificación

- Consultar el README.md del proyecto