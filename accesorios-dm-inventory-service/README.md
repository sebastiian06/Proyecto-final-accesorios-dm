# Inventory Service - Accesorios DM

Microservicio de gestión de inventario, catálogo y productos para la plataforma de comercio electrónico Accesorios DM.

## Requisitos Previos

- Docker Desktop
- Docker Compose
- Java 17 (para ejecutar localmente)
- Maven (opcional, se incluye wrapper)
- Git

## Estructura del Proyecto
```
accesorios-dm-inventory-service/
├── src/
│ ├── main/
│ │ ├── java/com/accesoriosdm/inventory/
│ │ │ ├── controller/ # Endpoints REST
│ │ │ ├── service/ # Lógica de negocio
│ │ │ ├── repository/ # Acceso a datos
│ │ │ ├── entity/ # Entidades JPA
│ │ │ ├── dto/ # Data Transfer Objects
│ │ │ └── exception/ # Manejo de excepciones
│ │ └── resources/
│ │ └── application.yml # Configuración
│ └── test/ # Pruebas unitarias
├── Dockerfile
├── docker-compose.yml
├── pom.xml
└── README.md
```

# IMPORTANTE
## Dependencia: Base de Datos

Este microservicio requiere la base de datos `accesorios-dm-database`. Debes tenerla **clonada y corriendo.**

### Clonar la base de datos

```bash
git clone https://github.com/SergioLosadaDev/accesorios-dm-database.git
cd accesorios-dm-database
```

### Levantar la base de datos (ambiente main)
```bash
git checkout main
docker-compose -f docker-compose.yml up -d
```

### Verificar que PostgreSQL está corriendo:
```bash
docker ps | findstr "postgres"
```
**Debes ver: accesorios-dm-postgres-qa corriendo en el puerto 5433.**

# Configuración del Microservicio

## Variables de entorno

El microservicio utiliza las siguientes variables (configuradas en docker-compose.yml):

|Variable	|Valor	|Descripción|
|-----------|-------|-----------|
|SPRING_DATASOURCE_URL	|jdbc:postgresql://accesorios-dm-postgres-dev:5432/accesorios_dm_db	|Conexión a BD|
|SPRING_DATASOURCE_USERNAME	|admin	|Usuario de BD|
|SPRING_DATASOURCE_PASSWORD	|admin123	|Contraseña de BD|
|SERVER_PORT	|8080	|Puerto del servicio|

## Archivo de configuración local (opcional)

Si deseas ejecutar sin Docker, crea src/main/resources/application-local.yml:

```bash
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/accesorios_dm_db
    username: admin
    password: admin123
```

# Cómo Levantar el Microservicio

## Opción 1: Con Docker (Recomendado)
```bash
# 1. Asegurar que la base de datos está corriendo
cd ../accesorios-dm-database
docker-compose -f docker-compose.yml up -d

# 2. Volver al microservicio
cd ../accesorios-dm-inventory-service

# 3. Construir la imagen
docker-compose build

# 4. Levantar el contenedor
docker-compose up -d

# 5. Ver los logs
docker-compose logs -f
```

## Opción 2: Ejecución local (sin Docker)

```bash
# 1. Asegurar que la base de datos está corriendo
cd ../accesorios-dm-database
docker-compose -f docker-compose.yml up -d

# 2. Volver al microservicio
cd ../accesorios-dm-inventory-service

# 3. Compilar
./mvnw clean package -DskipTests

# 4. Ejecutar
java -jar target/inventory-service-0.0.1-SNAPSHOT.jar
```

## Verificar que Funciona

### Health check

```bash
curl http://localhost:8080/api/v1/health
```

**Respuesta esperada:**
```json
{"service":"inventory-service","version":"1.0.0","status":"UP"}
```

### Obtener categorías
```bash
curl http://localhost:8080/api/v1/categorias
```

**Respuesta esperada:**
```json
[{"idCategoria":1,"nombre":"General","descripcion":"Categoria general","estado":true},...]
```

### Obtener productos
```bash
curl http://localhost:8080/api/v1/productos
```

**Respuesta esperada:**
```json
[{"idProducto":1,"nombre":"Producto Demo","precio":100000.00,"precioConDescuento":100000.00,"categoriaNombre":"General"}]
```

## Endpoints Disponibles

### Categorías

|Método	|Endpoint	|Descripción|
|-------|-----------|-----------|
|GET	|/api/v1/categorias	|Listar todas las categorías activas|
|GET	|/api/v1/categorias/{id}	|Obtener categoría por ID|
|GET	|/api/v1/categorias/nombre/{nombre}	|Obtener categoría por nombre|
|POST	|/api/v1/categorias	|Crear nueva categoría|
|PUT	|/api/v1/categorias/{id}	|Actualizar categoría|
|DELETE	|/api/v1/categorias/{id}	|Eliminar categoría|
|PATCH	|/api/v1/categorias/{id}/toggle-estado	|Activar/desactivar categoría|

### Materiales

|Método	|Endpoint	|Descripción|
|-------|-----------|-----------|
|GET	|/api/v1/materiales	|Listar todos los materiales|
|GET	|/api/v1/materiales/{id}	|Obtener material por ID|
|POST	|/api/v1/materiales	|Crear nuevo material|
|PUT	|/api/v1/materiales/{id}	|Actualizar material|
|DELETE	|/api/v1/materiales/{id}	|Eliminar material|

### Productos

|Método	|Endpoint	|Descripción|
|-------|-----------|-----------|
|GET	|/api/v1/productos	|Listar productos activos|
|GET	|/api/v1/productos/paginated	|Productos paginados|
|GET	|/api/v1/productos/{id}	|Detalle completo del producto|
|GET	|/api/v1/productos/categoria/{categoriaId}	|Productos por categoría|
|GET	|/api/v1/productos/disponibles	|Productos con stock|
|GET	|/api/v1/productos/search?nombre={texto}	|Búsqueda por nombre|
|POST	|/api/v1/productos	|Crear nuevo producto|
|PUT	|/api/v1/productos/{id}	|Actualizar producto|
|DELETE	|/api/v1/productos/{id}	|Eliminar producto|
|GET	|/api/v1/productos/{productoId}/imagenes	|Obtener imágenes del producto|
|POST	|/api/v1/productos/{productoId}/imagenes?urlImagen={url}&orden={orden}	|Agregar imagen|
|DELETE	|/api/v1/productos/imagenes/{imagenId}	|Eliminar imagen|

### Promociones

|Método	|Endpoint	|Descripción|
|-------|-----------|-----------|
|GET	|/api/v1/promociones	|Listar promociones activas|
|GET	|/api/v1/promociones/vigentes	|Promociones vigentes|
|POST	|/api/v1/promociones	|Crear promoción|
|PUT	|/api/v1/promociones/{id}	|Actualizar promoción|
|DELETE	|/api/v1/promociones/{id}	|Eliminar promoción|
|POST	|/api/v1/promociones/{promocionId}/productos/{productoId}	|Aplicar promoción a producto|
|DELETE	|/api/v1/promociones/{promocionId}/productos/{productoId}	|Quitar promoción de producto|

### Health

|Método	|Endpoint	|Descripción|
|-------|-----------|-----------|
|GET	|/api/v1/health	|Health check del servicio|

## Comandos Útiles

### Ver logs del contenedor
```bash
docker-compose logs -f
```

### Detener el servicio
```bash
docker-compose down
```

### Reconstruir después de cambios
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Conectar a la base de datos desde el contenedor (debug)
```bash
docker exec -it accesorios-dm-inventory-service sh
```

## Solución de Problemas

### Error: Connection refused

**Causa:** La base de datos no está corriendo o el puerto es incorrecto.

**Solución:**
```bash
# Verificar que la BD está corriendo
cd ../accesorios-dm-database
docker-compose -f docker-compose.yml ps

# Si no está, levantarla
docker-compose -f docker-compose.yml up -d
```

### Error: FATAL: password authentication failed

**Causa:** Credenciales incorrectas en application.yml.

**Solución:** Verificar que username: admin y password: admin123.

### Error: Relation "categoria" does not exist

**Causa:** Las migraciones de la BD no se aplicaron.

**Solución:**
```bash
cd ../accesorios-dm-database
docker-compose -f docker-compose.yml down -v
docker-compose -f docker-compose.yml up -d
```

### El contenedor no arranca
```bash
# Ver logs detallados
docker-compose logs -f

# Reconstruir desde cero
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

# Configuración de Puertos

|Ambiente	|BD (localhost)	|BD (red Docker)	|Microservicio|
|-----------|---------------|-------------------|-------------|
|develop	|5434	|5432	|8082|
|qa	|5433	|5432	|8081|
|main	|5432	|5432	|8080|

Nota: Dentro de la red Docker, la BD siempre escucha en el puerto 5432.

## Flujo de Trabajo con Git
```bash
# Crear rama para nueva funcionalidad
git checkout develop
git pull origin develop
git checkout -b HU-{ambiente}-{desarrollador}-XX-nombre

# Hacer cambios...
git add .
git commit -m "feat: HU-DEV-JSA-XX descripcion"
git push origin HU-DEV-JSA-XX-nombre

# Crear Pull Request a develop
```

## Tecnologías Utilizadas
|Tecnología	|Versión	|Propósito|
|-----------|-----------|---------|
|Java	|17	|Lenguaje principal|
|Spring Boot	|3.5.11	|Framework|
|Spring Data JPA	|-	|Acceso a datos|
|PostgreSQL	|16	|Base de datos|
|Maven	|-	|Gestión de dependencias|
|Docker	|-	|Contenerización|
|Lombok	|-	|Reducción de código boilerplate|

## Licencia
Proyecto interno de Accesorios DM.

## Contacto
Repositorio: https://github.com/SergioLosadaDev/accesorios-dm-inventory-service