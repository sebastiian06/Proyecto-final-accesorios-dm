# accesorios-dm-database

Base de datos para el sistema de comercio electrónico de accesorios DM, gestionada con Liquibase y PostgreSQL.

## Alcance Actual

Este repositorio administra toda la estructura de la base de datos del proyecto:

- Extensiones: `uuid-ossp`
- Schemas: `security`, `clientes`, `catalogo`, `promociones`, `ventas`, `logistica`, `inventario`
- Tablas: 17 tablas completas (roles, empleados, clientes, categorías, materiales, productos, imágenes, promociones, carritos, pedidos, inventario)
- Datos iniciales: roles, tipos de movimiento, estados de pedido, categorías, materiales, productos demo
- Funciones y triggers: actualización automática de stock
- Índices: 35 índices de rendimiento
- Vistas: 10 vistas para reportes
- Políticas RLS: seguridad a nivel de fila

## Estructura del Proyecto

```text
accesorios-dm-database/
|-- changelog-master.yaml
|-- docker-compose.yml
|-- .env.example
|-- .gitignore
|-- README.md
|-- verify-all.ps1
|-- 01_ddl/
|   |-- changelog.yaml
|   |-- 00_extensions/
|   |   |-- changelog.yaml
|   |   `-- 001_enable_uuid_extension.sql
|   |-- 01_schemas/
|   |   |-- changelog.yaml
|   |   `-- 001_create_schemas.sql
|   |-- 02_types/
|   |   `-- changelog.yaml
|   |-- 03_tables/
|   |   |-- changelog.yaml
|   |   |-- 001_create_security_tables.sql
|   |   |-- 002_create_clientes_tables.sql
|   |   |-- 003_create_catalogo_tables.sql
|   |   |-- 004_create_imagen_producto_table.sql
|   |   |-- 005_create_promociones_tables.sql
|   |   |-- 006_create_carrito_tables.sql
|   |   |-- 007_create_pedidos_tables.sql
|   |   `-- 008_create_inventario_movimiento_table.sql
|   |-- 04_views/
|   |   |-- changelog.yaml
|   |   `-- 001_report_views.sql
|   |-- 05_materialized_views/
|   |   `-- changelog.yaml
|   |-- 06_functions/
|   |   |-- changelog.yaml
|   |   `-- 001_update_stock_functions.sql
|   |-- 07_procedures/
|   |   `-- changelog.yaml
|   |-- 08_triggers/
|   |   |-- changelog.yaml
|   |   `-- 001_inventario_triggers.sql
|   `-- 09_indexes/
|       |-- changelog.yaml
|       `-- 001_performance_indexes.sql
|-- 02_dml/
|   |-- changelog.yaml
|   `-- 00_inserts/
|       |-- changelog.yaml
|       `-- 001_initial_data.sql
|-- 03_dcl/
|   |-- changelog.yaml
|   |-- 00_roles/
|   |   |-- changelog.yaml
|   |   `-- 001_create_roles.sql
|   |-- 01_grants/
|   |   |-- changelog.yaml
|   |   `-- 001_grants.sql
|   `-- 02_policies/
|       |-- changelog.yaml
|       `-- 001_rls_policies.sql
|-- 04_tcl/
|   `-- changelog.yaml
|-- 05_rollbacks/
|   |-- 01_ddl/
|   |   |-- 00_extensions/
|   |   |-- 01_schemas/
|   |   |-- 02_types/
|   |   |-- 03_tables/
|   |   |-- 04_views/
|   |   |-- 05_materialized_views/
|   |   |-- 06_functions/
|   |   |-- 07_procedures/
|   |   |-- 08_triggers/
|   |   `-- 09_indexes/
|   |-- 02_dml/
|   |   `-- 00_inserts/
|   |-- 03_dcl/
|   |   |-- 00_roles/
|   |   |-- 01_grants/
|   |   `-- 02_policies/
|   `-- 04_tcl/
|-- docker/
|   `-- liquibase/
|       `-- Dockerfile
`-- docs/
    `-- scripts-verificacion/
        |-- verify-develop.ps1
        |-- verify-qa.ps1
        `-- verify-main.ps1
```

## Arquitectura de Capas

La arquitectura está organizada por responsabilidad SQL:

|Capa	|Propósito|
|-------|---------|
|01_ddl	|Cambios estructurales (extensiones, schemas, tablas, vistas, funciones, triggers, índices)|
|02_dml	|Cambios de datos (inserts, updates, deletes)|
|03_dcl	|Seguridad, permisos y control de acceso (roles, grants, políticas RLS)|
|04_tcl	|Operaciones transaccionales o de recuperación excepcionales|
|05_rollbacks	|Scripts de reversión (estructura espejo de las capas activas)|


## Ambientes y Puertos

|Rama	|Puerto	|Ambiente	|Contenedor|
|-------|-------|-----------|----------|
|develop	|5432	|Desarrollo	|accesorios-dm-postgres-dev|
|qa	|5433	|Calidad	|accesorios-dm-postgres-qa|
|main	|5434	|Producción	|accesorios-dm-postgres-prod|

## Requisitos

- Docker Desktop

- Docker Compose

- Git

- PowerShell (para scripts de verificación en Windows)

## Configuración Inicial

### 1. Clonar el repositorio

```bash
git clone https://github.com/SergioLosadaDev/accesorios-dm-database.git
cd accesorios-dm-database
```

### 2. Configurar variables de entorno (opcional)

```bash
cp .env.example .env
```

### 3. Levantar el ambiente de desarrollo

```bash
git checkout develop
docker-compose -f docker-compose.yml up -d
```

### 4. Verificar que todo funciona

```bash
.\verify-all.ps1
```

## Comandos Útiles

### Levantar ambientes

```bash
# Desarrollo (puerto 5432)
git checkout develop
docker-compose -f docker-compose.yml up -d

# QA (puerto 5433)
git checkout qa
docker-compose -f docker-compose.yml up -d

# Produccion(puerto 5434)
git checkout main
docker-compose -f docker-compose.yml up -d
```

### Ver logs de Liquibase

```bash
docker-compose -f docker-compose.yml logs liquibase
```

### Conectar a PostgreSQL

```bash
# Desarrollo
docker exec -it accesorios-dm-postgres-dev psql -U admin -d accesorios_dm_db

# QA
docker exec -it accesorios-dm-postgres-qa psql -U admin -d accesorios_dm_db

# Producción
docker exec -it accesorios-dm-postgres-main psql -U admin -d accesorios_dm_db
```

### Detener y limpiar

```bash
docker-compose -f docker-compose.yml down -v
```

## Scripts de Verificación

|Script|	Propósito|
|------|-------------|
|verify-all.ps1	|Verifica los 3 ambientes (develop, qa, main)|
|docs/scripts-verificacion/verify-develop.ps1	|Verifica solo develop|
|docs/scripts-verificacion/verify-qa.ps1	|Verifica solo QA|
|docs/scripts-verificacion/verify-main.ps1	|Verifica solo main|

## Estructura de la Base de Datos

### Schemas (8)

|Schema	|Propósito|
|-------|---------|
|security	|Roles y empleados|
|clientes	|Clientes|
|catalogo	|Categorías, materiales, productos, imágenes|
|promociones	|Promociones y relación con productos|
|ventas	|Carritos, pedidos y detalles|
|logistica	|Estados de pedido y historial|
|inventario	|Tipos de movimiento y movimientos de inventario|
|public	|Schema por defecto|

### Tablas (17)

|Tabla	|Schema|
|-------|------|
|rol	|security|
|empleado	|security|
|cliente	|clientes|
|categoria	|catalogo|
|material	|catalogo|
|producto	|catalogo|
|imagen_producto	|catalogo|
|promocion	|promociones|
|promocion_producto	|promociones|
|carrito	|ventas|
|item_carrito	|ventas|
|pedido	|ventas|
|detalle_pedido	|ventas|
|estado_pedido	|logistica|
|historial_estado_pedido	|logistica|
|tipo_movimiento	|inventario|
|inventario_movimiento	|inventario|

### Historias de Usuario Completadas

|HU	|Descripción|
|---|-----------|
|HU-01	|Docker + Liquibase base (develop)|
|HU-02	|Configuración QA|
|HU-03	|Configuración MAIN|
|HU-04	|Extensions + Schemas|
|HU-05	|Tablas ROL + EMPLEADO|
|HU-06	|Tabla CLIENTE|
|HU-07	|Tablas CATEGORIA, MATERIAL, PRODUCTO|
|HU-08	|Tabla IMAGEN_PRODUCTO|
|HU-09	|Tablas PROMOCION, PROMOCION_PRODUCTO|
|HU-10	|Tablas CARRITO, ITEM_CARRITO|
|HU-11	|Tablas PEDIDOS|
|HU-12	|Tablas INVENTARIO|
|HU-13	|Datos iniciales|
|HU-14	|Scripts de verificación|
|HU-15	|Funciones y triggers|
|HU-16	|Índices de rendimiento|
|HU-17	|Vistas para reportes|
|HU-18	|Políticas de seguridad RLS|
|HU-19	|Documentación|

## Flujo de Trabajo con Git

### Crear una nueva HU

```bash
git checkout develop
git pull origin develop
git checkout -b HU-DEV-JSA-XX-nombre
# Realizar cambios...
git add .
git commit -m "feat: HU-DEV-JSA-XX descripcion"
git push origin HU-DEV-JSA-XX-nombre
# Crear Pull Request a develop
```

### Pasar cambios a QA

```bash
git checkout qa
git pull origin qa
git merge develop --no-commit --no-ff
git checkout qa -- docker-compose.yml
git add .
git commit -m "Merge develop into qa: mantener docker-compose.yml"
git push origin qa
```

## Convención de Commits

|Tipo	|Uso	|Ejemplo|
|-------|-------|-------|
|feat	|Nueva funcionalidad / HU	|feat: HU-DEV-JSA-01 crear estructura|
|fix	|Corrección de errores	|fix: corregir sintaxis|
|docs	|Documentación	|docs: actualizar README|
|chore	|Mantenimiento	|chore: actualizar .gitignore|

## Licencia

Proyecto interno de accesorios DM.
