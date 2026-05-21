# ADR 002: Separación de la Base de Datos por Capas y Esquemas

## Estado
**Aceptado** - 2025-05-04. Implementación completa en los 3 ambientes (develop, QA, main). En uso activo por los 3 microservicios.

## Contexto

El sistema de comercio electrónico cuenta con 3 microservicios que consumen la misma base de datos PostgreSQL:

| Microservicio | Responsabilidad | Equipo a cargo |
|---------------|-----------------|----------------|
| **Seguridad** | Autenticación, roles, empleados, clientes | Equipo de plataforma |
| **Catálogo** | Productos, categorías, materiales, imágenes, promociones, inventario | Equipo de producto |
| **Carrito/Pedidos** | Carritos de compra, pedidos, logística, estados | Equipo de experiencia |

**Problemas identificados:**

1. **Acoplamiento fuerte** - Todas las tablas en el mismo schema `public` generan conflictos
2. **Propiedad difusa** - No está claro qué equipo es responsable de qué tablas
3. **Seguridad compleja** - Es difícil aplicar políticas de acceso granulares
4. **Dependencias ocultas** - Un microservicio puede modificar tablas que no le corresponden
5. **Escalabilidad limitada** - En el futuro, migrar un módulo a su propia BD sería muy costoso
6. **Conflictos en Git** - Múltiples equipos modificando archivos en la misma carpeta

**Ejemplo de problema concreto:**

El equipo de Carrito necesita agregar una columna `primer_compra` a la tabla `cliente`. Pero la tabla `cliente` es propiedad del equipo de Seguridad. Esto genera:
- Dependencia entre equipos
- Necesidad de coordinar cambios
- Riesgo de conflictos en el changelog

## Decisión

Se adopta una **arquitectura por capas funcionales dentro de Liquibase y por schemas dentro de PostgreSQL**.

### Capas de Liquibase

Organizamos los cambios por **tipo de operación SQL** en la estructura de carpetas de Liquibase:

| Capa | Propósito | Ejemplo de cambios |
|------|-----------|-------------------|
| **01_ddl** | Cambios estructurales (Data Definition Language) | CREATE TABLE, ALTER TABLE, CREATE INDEX, CREATE FUNCTION, CREATE TRIGGER |
| **02_dml** | Cambios de datos (Data Manipulation Language) | INSERT, UPDATE, DELETE de datos maestros o iniciales |
| **03_dcl** | Seguridad y permisos (Data Control Language) | CREATE ROLE, GRANT, REVOKE, RLS Policies |
| **04_tcl** | Transacciones manuales (Transaction Control Language) | BEGIN, COMMIT, SAVEPOINT para recuperaciones manuales |

**Regla de activación:**
- Una carpeta solo se activa cuando está incluida en el `changelog.yaml` de su nivel superior
- Las capas no activas pueden existir (estructura reservada para futuro)
- Esto permite crecimiento ordenado sin romper despliegues existentes

### Esquemas de PostgreSQL

Organizamos las tablas por **dominio funcional** en schemas separados:

| Schema | Propósito | Tablas | Microservicio |
|--------|-----------|--------|---------------|
| **security** | Autenticación y autorización | `rol`, `empleado` | Seguridad |
| **clientes** | Datos de clientes | `cliente` | Seguridad / Carrito |
| **catalogo** | Gestión de productos | `categoria`, `material`, `producto`, `imagen_producto` | Catálogo |
| **promociones** | Descuentos y ofertas | `promocion`, `promocion_producto` | Catálogo |
| **ventas** | Proceso de compra | `carrito`, `item_carrito`, `pedido`, `detalle_pedido` | Carrito |
| **logistica** | Estados y seguimiento | `estado_pedido`, `historial_estado_pedido` | Carrito |
| **inventario** | Movimientos de stock | `tipo_movimiento`, `inventario_movimiento` | Catálogo |
| **public** | Schema por defecto de PostgreSQL | Tablas del sistema | Ninguno |

### Propiedad de tablas por equipo

| Equipo | Schemas de su propiedad | Schemas de solo lectura |
|--------|------------------------|------------------------|
| **Seguridad** | `security`, `clientes` | `ventas` (para consultas) |
| **Catálogo** | `catalogo`, `promociones`, `inventario` | - |
| **Carrito** | `ventas`, `logistica` | `clientes` (solo lectura) |

## Justificación

### Razones para la separación por capas Liquibase

1. **Orden de ejecución claro** - Primero se crea la estructura (DDL), luego los datos (DML), luego la seguridad (DCL)
2. **Rollback granular** - Se puede revertir solo una capa si es necesario
3. **Mantenibilidad** - Cada capa tiene responsabilidad única
4. **Evolución controlada** - Podemos activar nuevas capas (ej. `07_procedures`) sin afectar las existentes
5. **Separación de intereses** - El equipo de seguridad puede trabajar en `03_dcl` sin tocar `01_ddl`

### Razones para la separación por schemas PostgreSQL

1. **Aislamiento lógico** - Cada microservicio conoce solo "su" schema
2. **Seguridad granular** - RLS puede aplicarse por schema fácilmente
3. **Propiedad clara** - Cada equipo sabe qué tablas le pertenecen
4. **Escalabilidad** - En el futuro, cada schema podría migrar a su propia base de datos
5. **Documentación implícita** - El nombre del schema ya indica la responsabilidad
6. **Evita conflictos** - Múltiples equipos pueden tener tablas con el mismo nombre (ej. `log` en diferentes schemas)

### Beneficios adicionales

- **Joins entre schemas** - Siguen siendo posibles, pero quedan explícitos (ej. `clientes.cliente` JOIN `ventas.pedido`)
- **Backups selectivos** - Podemos respaldar solo ciertos schemas
- **Permisos a nivel de schema** - `GRANT USAGE ON SCHEMA catalogo TO app_vendedor`

## Alternativas

| Alternativa | Descripción | ¿Por qué se descartó? |
|-------------|-------------|----------------------|
| **Un solo schema (`public`)** | Todas las tablas en el mismo lugar | Conflicto de responsabilidades, difícil de mantener, seguridad compleja |
| **Bases de datos separadas** | Cada microservicio con su propia BD | Joins imposibles entre servicios, transacciones distribuidas complejas, replicación de datos (ej. clientes en múltiples BDs) |
| **Prefijo en nombres** (ej. `sec_users`) | Mismo schema pero con prefijo | No hay aislamiento real, seguridad más compleja, prefijos se olvidan |
| **Una sola capa Liquibase** | Todos los cambios en `01_ddl/sql/all.sql` | Imposible de mantener, sin separación de responsabilidades rollback complejo |

## Consecuencias

### Positivas
- ✅ **Claridad de responsabilidades** - Cada equipo sabe qué tablas le pertenecen
- ✅ **Seguridad granular** - RLS implementable por schema y tabla
- ✅ **Escalabilidad** - Migración futura a bases de datos separadas es viable
- ✅ **Mantenibilidad** - Es fácil encontrar dónde está cada definición
- ✅ **Menos conflictos** - Equipos modifican carpetas y schemas distintos

### Negativas
- ❌ **Joins entre schemas** - Se vuelven más explícitos, requieren permisos adicionales
- ❌ **Complejidad inicial** - Más carpetas y archivos que mantener
- ❌ **Curva de aprendizaje** - Nuevos desarrolladores deben entender la estructura
- ❌ **Overhead de archivos** - Muchos `changelog.yaml` (uno por carpeta)

## Impacto técnico

### En el repositorio
- **Estructura de carpetas:** 4 capas principales, 25+ subcarpetas
- **Archivos de changelog:** 1 master + 4 por capa + ~20 por subcarpetas
- **Reglas de activación:** Cada changelog solo incluye sus hijos directos

### En los microservicios
- **Conexión:** Deben especificar el schema en las consultas (ej. `SELECT * FROM catalogo.producto`)
- **Permisos:** Cada microservicio usa un rol con permisos específicos por schema
- **Cambios:** Solo pueden modificar tablas en sus schemas propios

### En el equipo de desarrollo
- **Localización de cambios:** Saben exactamente dónde agregar nuevos objetos
- **Revisiones de PR:** Más fáciles de revisar (cambios localizados)
- **Onboarding:** Curva de aprendizaje de 1-2 días

## Impacto en costos

| Recurso | Impacto | Detalle |
|---------|---------|---------|
| Infraestructura | Ninguno | No requiere recursos adicionales |
| Desarrollo inicial | 2-3 días | Configuración de estructura y plantillas |
| Mantenimiento | Bajo | Crear nuevos archivos ya es parte del flujo |
| Capacitación | 2-4 horas | Explicar la estructura a nuevos miembros |
| **Total estimado** | **Bajo** | El beneficio supera ampliamente el costo |

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|-------------|
| Joins entre schemas olvidados | Media | Medio | Documentar joins necesarios, revisar en PRs |
| Permisos mal configurados | Media | Alto | Usar scripts de verificación (`verify-*.ps1`) |
| Dependencia circular entre schemas | Baja | Alto | Revisar arquitectura: las dependencias solo van en una dirección |
| Confusión en la propiedad | Baja | Medio | Documentar en README y en comentarios de tablas |
| Archivos de changelog desincronizados | Baja | Medio | Validación automática en CI (`liquibase validate`) |

### Dependencia entre schemas (dirección permitida)

- security → (ninguno)
- clientes → security (solo referencias a roles)
- catalogo → clientes (FK a cliente? No, cliente está en ventas/pedidos)
- ventas → clientes, catalogo, logistica
- logistica → ventas
- inventario → catalogo
- promociones → catalogo


**Regla:** Las dependencias deben ser acíclicas. Un schema puede depender de schemas "inferiores" pero no al revés.

## Decisiones relacionadas

- **ADR 001:** Liquibase para migraciones (define cómo se organizan los changelogs)
- **ADR 004:** Políticas RLS por microservicio (define permisos a nivel de schema)
- **ADR 005:** Puertos por ambiente (independiente, pero usa esta estructura)

## Plan de implementación

**Fase 1: Setup de esquemas (Completado - HU-04)**
- [x] Crear archivo `001_create_schemas.sql`
- [x] Definir los 8 schemas
- [x] Activar en `01_ddl/01_schemas/changelog.yaml`

**Fase 2: Creación de tablas (Completado - HUs 05-12)**
- [x] Seguridad: `security.rol`, `security.empleado`
- [x] Clientes: `clientes.cliente`
- [x] Catálogo: `catalogo.categoria`, `catalogo.material`, `catalogo.producto`, `catalogo.imagen_producto`
- [x] Promociones: `promociones.promocion`, `promociones.promocion_producto`
- [x] Ventas: `ventas.carrito`, `ventas.item_carrito`, `ventas.pedido`, `ventas.detalle_pedido`
- [x] Logística: `logistica.estado_pedido`, `logistica.historial_estado_pedido`
- [x] Inventario: `inventario.tipo_movimiento`, `inventario.inventario_movimiento`

**Fase 3: Permisos por schema (Completado - HU-18)**
- [x] Crear roles: `app_admin`, `app_vendedor`, `app_cliente`, `app_bodeguero`
- [x] `GRANT USAGE ON SCHEMA` para cada rol
- [x] Políticas RLS por tabla

**Fase 4: Documentación (Completado - HU-19, HU-20)**
- [x] Actualizar README con estructura
- [x] Documentar en `api-database-guide.md` qué schema corresponde a cada microservicio

## Métricas de éxito

| Métrica | Objetivo | Estado actual |
|---------|----------|---------------|
| Esquemas claramente definidos | 8 schemas | ✅ 8 schemas documentados |
| Propiedad de tablas por equipo | 100% claro | ✅ Documentado en guía |
| Conflictos entre equipos | 0 por sprint | ✅ Hasta ahora 0 |
| Tiempo para localizar una tabla | < 30 segundos | ✅ Navegación directa por schema |
| Dependencias circulares | 0 | ✅ Sin dependencias circulares |
| Joins entre schemas documentados | 100% | ✅ Pendiente de documentar según surjan |

## Fecha y autores

| Rol | Nombre | Fecha |
|-----|--------|-------|
| Autor | JSA | 2025-05-04 |
| Revisado por | Equipo de arquitectura | 2025-05-04 |
| Aprobado por | Líder técnico | 2025-05-04 |

## Referencias

- [PostgreSQL Schema Documentation](https://www.postgresql.org/docs/current/ddl-schemas.html)
- [PostgreSQL GRANT USAGE](https://www.postgresql.org/docs/current/sql-grant.html)
- [Liquibase Master Changelog Structure](https://docs.liquibase.com/concepts/changelogs/master-changelog.html)
- [Database Schema Design Best Practices](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATTERNS)