# ADR 005: Manejo de Puertos por Ambiente (Develop, QA, Main)

## Estado
**Aceptado** - 2025-05-04. Implementación completa y en uso activo en las 3 ramas del repositorio. Flujo de merges documentado y probado.

## Contexto

El sistema requiere ejecutarse en múltiples ambientes:

| Ambiente | Propósito | Usuarios | Frecuencia de uso | Requisito de aislamiento |
|----------|-----------|----------|-------------------|-------------------------|
| **Develop** | Desarrollo local de cada ingeniero | Desarrolladores | Diario | Aislado de otros desarrolladores |
| **QA** | Pruebas de integración y calidad | Equipo de QA, CI/CD | Varias veces por día | Compartido, pero aislado de desarrollo |
| **Main (Producción)** | Sistema productivo | Clientes finales | 24/7 | Máximo aislamiento y estabilidad |

### Problemas identificados

1. **Conflicto de puertos en una misma máquina**
   - Un desarrollador no podía tener develop y QA corriendo simultáneamente
   - El CI/CD agent no podía ejecutar pruebas contra develop y QA al mismo tiempo
   - El puerto 5432 (default de PostgreSQL) solo puede ser usado por un contenedor

2. **Contaminación entre ambientes**
   - Sin separación clara, un desarrollador podía conectarse accidentalmente a QA en lugar de develop
   - Scripts de prueba podían modificar la base de datos de QA mientras se ejecutaban pruebas locales

3. **Reproducibilidad**
   - Cada entorno de desarrollo (cada máquina) necesitaba la misma experiencia
   - No podíamos asumir que el puerto 5432 estuviera libre (podría haber PostgreSQL local instalado)

4. **Dificultad para CI/CD**
   - Las pipelines necesitaban correr contra múltiples bases de datos en paralelo
   - Sin puertos fijos, la configuración de conexiones era compleja

5. **Git Branching y archivos de configuración**
   - El archivo `docker-compose.yml` vive en cada rama, pero debe tener diferente puerto
   - HUs normales no deben modificar este archivo (solo cambios estructurales de BD)

### Ejemplo de problema concreto

Un desarrollador trabajando en una feature:

```bash
# Levanta develop
git checkout develop
docker-compose up -d  # Puerto 5432

# Necesita probar contra QA
git checkout qa
docker-compose up -d  # Error: puerto 5432 ya en uso
```

El desarrollador no podía tener ambos ambientes corriendo para comparar resultados.

## Decisión

Se adopta una estrategia de puertos fijos por rama, donde cada rama tiene su propio puerto PostgreSQL y su propio docker-compose.yml con ese puerto.

### Puertos asignados

|Rama	|Puerto PostgreSQL	|Contenedor	|Justificación|
|-------|-------------------|-----------|-------------|
|develop	|5432	|accesorios-dm-postgres-dev	|Puerto estándar, familiar para desarrolladores|
|qa	|5433	|accesorios-dm-postgres-qa	|Desplazamiento +1, fácil de recordar|
|main	|5434	|accesorios-dm-postgres-prod	|Desplazamiento +2, diferente de develop/QA|

## Estructura de archivos por rama

**Cada rama tiene su propio docker-compose.yml con configuración específica:**

### Rama develop (puerto 5432):

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: accesorios-dm-postgres-dev
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: accesorios_dm_db
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data

  liquibase:
    build: ./docker/liquibase
    container_name: accesorios-dm-liquibase-dev
    depends_on:
      - postgres
    volumes:
      - ./:/liquibase/changelog
    command: >
      sh -c "sleep 5 && 
             liquibase --url=jdbc:postgresql://postgres:5432/accesorios_dm_db
                       --username=admin
                       --password=admin123
                       --changeLogFile=changelog-master.yaml update"
```

### Rama QA (puerto 5433):

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: accesorios-dm-postgres-qa
    ports:
      - "5433:5432"  # ← Única diferencia
    # ... resto igual pero container_name cambia
```

### Rama MAIN (puerto 5434):

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: accesorios-dm-postgres-prod
    ports:
      - "5434:5432"  # ← Única diferencia
    environment:
      POSTGRES_DB: accesorios_dm_db
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}  # Variable de entorno para producción
    # ... resto similar
```

## Reglas de Git para proteger los puertos

1. Los archivos docker-compose.yml NO se modifican en HUs normales

- Las HUs de tablas, funciones, vistas, índices, etc. no tocan este archivo

- Esto se revisa en los Pull Requests

2. Solo las HUs de configuración de ambiente modifican los puertos

- HU-01: Creación inicial con puerto 5432 (develop)

- HU-02: Configuración QA (cambia puerto a 5433)

- HU-03: Configuración PRODUCCIÓN (cambia puerto a 5434)

3. Al hacer merge entre ramas, se mantiene el puerto de la rama destino

```bash
# Merge develop → QA
git checkout qa
git merge develop --no-commit --no-ff
git checkout qa -- docker-compose.yml   # Mantener puerto 5433
git add .
git commit -m "Merge develop into qa: mantener puerto 5433"
```

## Justificación

### ¿Por qué puertos fijos y no dinámicos?

|Criterio	|Puertos fijos	|Puertos dinámicos|
|Determinismo	|✅ Siempre se sabe dónde está cada ambiente	|❌ Depende del orden de ejecución|
|Scripts de pruebas	|✅ Se puede hardcodear el puerto	|❌ Requiere descubrimiento dinámico|
|Contenerización	|✅ Fácil de documentar	|❌ Complejo de configurar|
|Multiplexación	|✅ Múltiples ambientes pueden coexistir	|✅ También pueden coexistir|
|CI/CD	|✅ Configuración simple	|❌ Requiere lógica adicional|

## Beneficios específicos

1. Coexistencia de ambientes

- Un desarrollador puede correr develop, QA y main simultáneamente (puertos 5432, 5433, 5434)

- CI/CD puede correr pruebas contra develop y QA en paralelo

2. Simplicidad para scripts

- Los scripts de verificación (verify-develop.ps1, verify-qa.ps1) saben exactamente a qué puerto conectar

- No necesitan lógica de descubrimiento

3. Aislamiento por diseño

- Conectarse al ambiente equivocado requiere cambiar explícitamente el puerto

- Menor riesgo de modificar QA accidentalmente desde un script de desarrollo

4. Escalabilidad

- Si se necesitan más ambientes (staging, UAT), se pueden asignar puertos adicionales (5435, 5436, etc.)

5. Mismo código, diferente configuración

- El código SQL es idéntico entre ramas (Las tablas, funciones, vistas son las mismas)

- Solo cambia el puerto de exposición

## Alternativas

|Alternativa	|Descripción	|¿Por qué se descartó?|
|---------------|---------------|---------------------|
|Un solo docker-compose.yml con perfiles	|Usar docker-compose --profile para elegir ambiente	|El puerto sigue siendo el mismo, conflictos persisten|
|Puertos aleatorios (ephemeral ports)	|Docker asigna puertos automáticamente	|No reproducible, scripts complejos|
|Misma máquina, ambiente separado por red Docker	|Crear redes aisladas	|No resuelve conflicto de puertos en host|
|Contenedores en máquinas virtuales separadas	|Una VM por ambiente	|Costoso, complejo de gestionar|
|Usar variables de entorno para puerto	|DB_PORT configurable	|Útil, pero docker-compose.yml igual debe tener el puerto fijo|
|No tener QA local, solo en servidor	|QA solo en servidor remoto	|No se puede probar localmente, feedback lento|

## Análisis detallado de alternativas descartadas

### Un solo docker-compose.yml con perfiles:

```bash
# Merge develop → QA
docker-compose --profile qa up -d  # Puerto sigue siendo 5432
```

- El puerto en el host es el mismo para todos los perfiles

- No se resuelve el conflicto base

### Usar variables de entorno para puerto:

```bash
ports:
  - "${DB_PORT}:5432"
```

- Funcional, pero requiere que cada desarrollador recuerde exportar DB_PORT

- Propenso a errores (olvidar cambiar la variable)

## Consecuencias

### Positivas

- ✅ Coexistencia - Develop, QA y main pueden correr en la misma máquina simultáneamente

- ✅ Determinismo - Cada ambiente siempre está en el mismo puerto

- ✅ Simplicidad en CI/CD - Configuración directa, sin lógica dinámica

- ✅ Aislamiento - Bajo riesgo de contaminación entre ambientes

- ✅ Documentación clara - La guía de conexión puede indicar puertos fijos

- ✅ Escalable - Nuevos ambientes solo requieren nuevo puerto

### Negativas

- ❌ Múltiples archivos docker-compose - Cada rama tiene el suyo (pero igual ya están en diferentes ramas)

- ❌ Mantenimiento del merge - Al hacer merge, hay que recordar mantener el puerto destino (documentado y scripteable)

- ❌ Uso de puertos en la máquina - Ocupa 3 puertos si se levantan todos (pero es poco común)

- ❌ Documentación adicional - Se necesita explicar la estrategia a nuevos desarrolladores

## Impacto en los desarrolladores

### Flujo diario de trabajo:

```bash
# Trabajo normal en develop
git checkout develop
docker-compose up -d                    # PostgreSQL en puerto 5432
# ... desarrollo normal ...

# Necesito probar algo contra QA (comportamiento real)
git checkout qa
docker-compose up -d                    # PostgreSQL en puerto 5433 (sin conflicto)

# Ambos corren simultáneamente
docker ps
# CONTAINER ID   NAMES                          PORTS
# abc123        accesorios-dm-postgres-dev      0.0.0.0:5432->5432/tcp
# def456        accesorios-dm-postgres-qa       0.0.0.0:5433->5432/tcp

# Puedo probar mi microservicio contra cualquiera de los dos
```

## Impacto técnico

### En el repositorio

- Cada rama tiene su propio docker-compose.yml (no se comparte entre ramas)

- Las ramas qa y main se crean desde develop, luego se modifica manualmente el puerto

- El historial de docker-compose.yml es diferente en cada rama

### En los microservicios

- Configuración de conexión por ambiente:

```javascript
// Config por variable de entorno
const dbConfig = {
    develop: { host: 'localhost', port: 5432 },
    qa: { host: 'localhost', port: 5433 },
    main: { host: process.env.DB_HOST, port: process.env.DB_PORT || 5434 }
};
```

### En CI/CD

- Pipelines independientes por rama:

```yaml
# .gitlab-ci.yml o GitHub Actions
develop:
  script:
    - docker-compose -f docker-compose.yml up -d
    - npm test  # Conecta a localhost:5432

qa:
  script:
    - docker-compose -f docker-compose.yml up -d
    - npm test  # Conecta a localhost:5433
```

## Impacto en costos

|Recurso	|Impacto|
|-----------|-------|
|Infraestructura	|Ninguno (sigue siendo la misma máquina)|
|Tiempo de desarrollo	|1 hora para configurar ramas iniciales|
|Mantenimiento	|Muy bajo (solo al crear nuevas ramas de ambiente)|
|CI/CD	|Sin impacto adicional|
|Portabilidad	|Sin impacto|

**Estimación:** Costo insignificante, beneficio alto en productividad.

## Riesgos

|Riesgo	|Probabilidad	|Impacto	|Mitigación|
|-------|---------------|-----------|----------|
|Merge con conflicto en docker-compose.yml	|Media	|Medio	|Uso de --strategy-option ours y git checkout --ours|
|Desarrollador olvida mantener puerto destino	|Baja	|Bajo	|Documentado en README, scripts de verificación|
|Puerto 5432 ocupado por PostgreSQL local	|Media	|Bajo	|Se puede cambiar develop a 5432 alternativo|
|Puerto 5433/5434 ocupado por otra aplicación	|Baja	|Bajo	|Documentar cómo cambiar si es necesario|
|Confusión de ambientes (conectarse al puerto equivocado)	|Media	|Medio	|Scripts de verificación alertan si el puerto es incorrecto|

## Plan de contingencia para conflictos de puertos

1. Puerto 5432 ocupado por PostgreSQL local:

- Solución: Cambiar temporalmente develop a otro puerto (ej. 5435)

- Documentar en README cómo hacerlo

2. Conflicto al mergear:

- Script de merge documentado en README

- Validación automática en CI que el puerto sea el correcto en cada rama

## Decisiones relacionadas

- ADR 001: Liquibase para migraciones (se ejecuta en cada ambiente en su puerto correspondiente)

- ADR 002: Separación por capas (independiente, solo afecta estructura de BD)
    
- ADR 004: Políticas RLS (cada microservicio se conecta con diferentes roles, no afecta puertos)

## Plan de implementación

### Fase 1: Configuración de develop (Completado - HU-01)

- Crear docker-compose.yml en rama develop con puerto 5432

- Verificar que el contenedor funciona

### Fase 2: Configuración de QA (Completado - HU-02)

- Crear rama qa desde develop

- Modificar puerto a 5433 en docker-compose.yml

- Verificar que QA funciona independientemente

### Fase 3: Configuración de main (Completado - HU-03)

- Crear rama main desde qa

- Modificar puerto a 5434 en docker-compose.yml

- Configurar variable de entorno para contraseña

### Fase 4: Documentación del flujo de merge (Completado)

- Documentar en README cómo hacer merge sin afectar puertos

- Scripts de verificación por ambiente (verify-develop.ps1, verify-qa.ps1)

### Fase 5: Prueba de coexistencia (Completado)

- Levantar develop y QA simultáneamente

- Verificar que no hay conflicto de puertos

- Conectar microservicios a ambos ambientes

## Métricas de éxito

|Métrica	|Objetivo	|Estado actual|
|-----------|-----------|-------------|
|Puedo levantar develop y QA simultáneamente	|Sí	|✅ Verificado|
|Tiempo para identificar puerto de un ambiente	|< 5 segundos	|✅ Documentado|
|Errores de conexión por puerto incorrecto	|< 1 por mes	|✅ 0 errores reportados|
|CI/CD ejecuta pruebas contra ambiente correcto	|100%	|✅ Verificado|
|Merge entre ramas mantiene puerto destino	|100%	|✅ Documentado y probado|

## Verificación de coexistencia

```bash
# .gitlab-ci.yml o GitHub Actions
# Levantar develop
git checkout develop
docker-compose up -d
# Esperar a que esté saludable

# Levantar QA
git checkout qa
docker-compose up -d
# Esperar a que esté saludable

# Verificar ambos corren
docker ps --format "table {{.Names}}\t{{.Ports}}"
# accesorios-dm-postgres-dev    0.0.0.0:5432->5432/tcp
# accesorios-dm-postgres-qa     0.0.0.0:5433->5432/tcp

# Verificar desarrollo
docker exec accesorios-dm-postgres-dev psql -U admin -d accesorios_dm_db -c "SELECT 1"

# Verificar QA
docker exec accesorios-dm-postgres-qa psql -U admin -d accesorios_dm_db -c "SELECT 1"

# Ambos funcionan ✅
```

## Fecha y autores

|Rol	|Nombre	|Fecha|
|-------|-------|-----|
|Autor	|JSA	|2025-05-04|
|Revisado por	|Equipo de plataforma	|2025-05-04|
|Aprobado por	|Arquitecto de soluciones	|2025-05-04|

## Referencias

- [Docker Compose Port Mapping](https://docs.docker.com/compose/compose-file/#ports)

- [PostgreSQL Default Port](https://www.postgresql.org/docs/current/runtime-config-connection.html)

- [Git Branching Strategy for Database Projects](https://www.liquibase.com/blog/git-branching-strategy-liquibase)

- [ADR 001: Liquibase para migraciones](./001-liquibase-para-migraciones.md)

- [ADR 002: Separación por capas](./002-separacion-por-capas-esquemas.md)
