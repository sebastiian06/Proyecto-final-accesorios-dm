# ADR 001: Liquibase para Gestión de Migraciones

## Estado
**Aceptado** - 2025-05-04. En implementación y uso activo en todos los ambientes.

## Contexto
El proyecto tiene 3 microservicios (seguridad, catálogo, carrito) que comparten una misma base de datos PostgreSQL. El equipo de desarrollo necesita:

1. **Versionar los cambios** en la estructura de la base de datos
2. **Trabajar en paralelo** sin pisar los cambios de otros
3. **Reproducir el mismo esquema** en desarrollo, QA y producción
4. **Hacer rollback** de cambios problemáticos
5. **Auditar quién, cuándo y qué cambió** en la base de datos

En proyectos anteriores, se usaron scripts SQL sueltos que causaron:
- Conflictos al hacer merge
- Bases de datos inconsistentes entre ambientes
- Rollbacks manuales y riesgosos
- Falta de trazabilidad sobre los cambios aplicados

## Decisión
Se adopta **Liquibase** como herramienta estándar para la gestión de migraciones de base de datos.

### Detalles de la implementación:

- Liquibase se ejecuta dentro de un contenedor Docker
- La configuración está en `docker-compose.yml` con variables de entorno
- El changelog principal (`changelog-master.yaml`) orquesta 4 capas: 01_ddl (estructura), 02_dml (datos), 03_dcl (seguridad), 04_tcl (transacciones)
- Cada carpeta tiene su propio `changelog.yaml`
- Los scripts de rollback están en `05_rollbacks/` con estructura espejo
- Cada changeset tiene `author`, `id` y `rollback` definido

### Estructura adoptada:
```
changelog-master.yaml
├── 01_ddl/
│ ├── 00_extensions/changelog.yaml
│ ├── 01_schemas/changelog.yaml
│ ├── 03_tables/changelog.yaml
│ ├── 04_views/changelog.yaml
│ ├── 06_functions/changelog.yaml
│ ├── 08_triggers/changelog.yaml
│ └── 09_indexes/changelog.yaml
├── 02_dml/
│ └── 00_inserts/changelog.yaml
├── 03_dcl/
│ ├── 00_roles/changelog.yaml
│ ├── 01_grants/changelog.yaml
│ └── 02_policies/changelog.yaml
└── 04_tcl/changelog.yaml
```


## Justificación

1. **Versionado declarativo** - Liquibase permite definir cambios en YAML/XML/SQL, no requiere reinventar la rueda
2. **Rollback nativo** - Soporta rollback por changeset ID, tag, fecha o cantidad (`rollback-count`)
3. **Multi-ambiente nativo** - La misma configuración funciona en develop, QA y main
4. **Tablas de auditoría** - `DATABASECHANGELOG` y `DATABASECHANGELOGLOCK` registran todo automáticamente
5. **Integración CI/CD** - Se ejecuta con Docker, fácil de integrar en pipelines
6. **Tolerante a errores** - Si un changeset falla, no aplica los siguientes
7. **Soporte multi-equipo** - Varios desarrolladores pueden agregar changesets sin conflictos (solo IDs únicos)

## Alternativas

| Alternativa | ¿Por qué se descartó? |
|-------------|----------------------|
| **Flyway** | Rollback es más complejo (requiere scripts manuales). No soporta etiquetas para cambios específicos. |
| **pgMigrate** | Herramienta pequeña, comunidad limitada. Solo funciona con PostgreSQL y no tiene integración multi-ambiente robusta. |
| **Scripts SQL manuales** | Sin versionado, sin rollback, conflictos frecuentes entre desarrolladores. Imposible de reproducir en producción. |
| **No usar migraciones** | Caótico: cada uno aplica cambios manualmente, base de datos inconsistente entre ambientes. |
| **Sqitch** | Menos conocido, curva de aprendizaje más pronunciada. Documentación y comunidad más pequeña. |

## Consecuencias

**Positivas:**
- ✅ Todos los cambios de estructura están versionados en Git
- ✅ Podemos recrear la base de datos desde cero con `docker-compose down -v` y `docker-compose up -d`
- ✅ Rollback controlado: `liquibase rollback --tag=estable`
- ✅ Auditoría completa: saber quién aplicó cada cambio y cuándo
- ✅ Compatible con CI/CD (GitHub Actions, GitLab CI)

**Negativas:**
- ❌ Curva de aprendizaje inicial (sintaxis YAML, conceptos de changeset, contextos)
- ❌ Sensibilidad a ciertas sintaxis de PostgreSQL (`$$` en funciones requirió solución con comillas simples)
- ❌ Un changeset debe ser probado antes de subir (no es tan "fácil" como un script suelto)
- ❌ No se pueden modificar changesets ya aplicados en producción (hay que crear uno nuevo)

## Impacto técnico

**Equipo de desarrollo:**
- Todos deben conocer el flujo básico de Liquibase (update, rollback, status, validate)
- Cada HU debe incluir sus cambios en Liquibase (no scripts sueltos)
- Los PRs deben incluir el changeset correspondiente

**Infraestructura:**
- Se requiere Docker para ejecutar Liquibase (o instalación local)
- La imagen de Liquibase con driver PostgreSQL está incluida en el proyecto
- No hay servidores adicionales que mantener

**Microservicios:**
- No tienen que preocuparse por migraciones
- Solo se conectan a la base de datos existente

## Impacto en costos

| Recurso | Impacto |
|---------|---------|
| Licencia | Liquibase Open Source es gratuita |
| Infraestructura | No requiere servidores adicionales |
| Tiempo de desarrollo | Inversión inicial de 1-2 días para configuración |
| Mantenimiento | Bajo (cambios incremental en changelogs) |
| Capacitación | 2-3 horas para familiarización del equipo |

**Estimación:** Sin costos directos. Ahorro estimado de 20-30 horas/mes vs scripts manuales (evita conflictos, rollbacks manuales, debugging).

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|-------------|
| Changeset conflictivo | Baja | Alto | Usar IDs únicos, probar en develop antes de merge |
| Error de sintaxis en SQL | Media | Medio | Usar `liquibase validate` y `liquibase update-sql` antes de aplicar |
| Rollback fallido | Baja | Alto | Siempre probar rollbacks en QA antes de producción |
| Pérdida de datos | Muy baja | Crítico | Siempre hacer backup antes de rollback en producción |
| Dependencia de sintaxis específica (ej. `$$`) | Media | Medio | Probar las funciones antes de implementar, usar sintaxis compatible |

## Decisiones relacionadas

- **ADR 002:** Separación por capas y esquemas (define cómo organizar los changelogs)
- **ADR 005:** Manejo de puertos por ambiente (define cómo Liquibase se conecta a cada BD)

## Plan de implementación

**Fase 1: Setup inicial (Completado - HU-01)**
- [x] Crear `docker-compose.yml` con servicio de Liquibase
- [x] Crear `changelog-master.yaml` y estructura de carpetas
- [x] Configurar variables de entorno en `docker-compose.yml`
- [x] Verificar que Liquibase se ejecuta correctamente

**Fase 2: Configuración de ambientes (Completado - HU-02, HU-03)**
- [x] Configurar rama qa con su propio docker-compose (puerto 5433)
- [x] Configurar rama main con su propio docker-compose (puerto 5434)

**Fase 3: Uso diario (Activo)**
- [x] Desarrolladores crean HUs con sus cambios en Liquibase
- [x] Se ejecuta `liquibase update` en develop, QA, main
- [x] Rollbacks documentados y probados

## Métricas de éxito

| Métrica | Objetivo | Estado actual |
|---------|----------|---------------|
| Tiempo de aplicación de cambios | < 1 min | ✅ ~10 segundos |
| Rollback exitoso | 100% | ✅ Probado exitosamente |
| Conflictos entre cambios | 0 por sprint | ✅ Sin conflictos hasta ahora |
| Tiempo de onboarding de Liquibase | < 4 horas | ✅ Documentación disponible |
| Errores por migraciones | 0 en producción | ✅ Sin errores a la fecha |

## Fecha y autores

| Rol | Nombre | Fecha |
|-----|--------|-------|
| Autor | JSA | 2025-05-04 |
| Revisado por | Equipo de desarrollo | 2025-05-04 |
| Aprobado por | Arquitectura | 2025-05-04 |

## Referencias

- [Liquibase Official Documentation](https://docs.liquibase.com/)
- [Liquibase vs Flyway - Comparación](https://www.liquibase.com/blog/liquibase-vs-flyway)
- [Liquibase with PostgreSQL - Best Practices](https://docs.liquibase.com/databases/postgresql.html)
- [Project README - Comandos de Liquibase](./README.md)
