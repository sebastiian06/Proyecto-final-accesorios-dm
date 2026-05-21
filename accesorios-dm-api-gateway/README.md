# 🚪 API Gateway - Accesorios DM

API Gateway centralizado para la plataforma **Accesorios DM**, que enruta todas las peticiones a los microservicios de **Inventory**, **Security** y **Payment**.

## 📋 Tabla de Contenidos

- [Arquitectura](#arquitectura)
- [Ambientes](#ambientes)
- [Tecnologías](#tecnologías)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Ejecución](#ejecución)
- [Endpoints](#endpoints)
- [Middlewares](#middlewares)
- [Variables de Entorno](#variables-de-entorno)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Pruebas](#pruebas)
- [Despliegue](#despliegue)
- [Solución de Problemas](#solución-de-problemas)

---

## 🏗️ Arquitectura
```
      ┌─────────────────────────────────────────┐
      │            API GATEWAY (8000)           │
      │   Routing, Auth, Rate Limit, Logging    │
      └───────────────────┬─────────────────────┘
                          │
        ┌─────────────────┼──────────────────┐
        │                 │                  │
        ▼                 ▼                  ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│   Inventory   │ │    Security   │ │    Payment    │
│   Service     │ │    Service    │ │    Service    │
│   (8080)      │ │    (8888)     │ │    (9000)     │
└───────────────┘ └───────────────┘ └───────────────┘
```
Productos Usuarios Carritos

Categorías Autenticación Pedidos

Inventario Roles Pagos


---

## 🌍 Ambientes

| Ambiente | Rama | Puerto | URL Base | Uso |
|----------|------|--------|----------|-----|
| **Development** | `develop` | 8002 | `http://localhost:8002` | Desarrollo local |
| **QA** | `qa` | 8001 | `http://localhost:8001` | Pruebas de calidad |
| **Production** | `main` | 8000 | `https://api.accesoriosdm.com` | Producción |

---

## 🛠️ Tecnologías

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| Node.js | 18.x | Runtime |
| Express | 4.x | Framework web |
| http-proxy-middleware | 2.x | Proxy inverso |
| Winston | 3.x | Logging estructurado |
| Morgan | 1.x | Logging HTTP |
| express-rate-limit | 6.x | Rate limiting |
| Helmet | 7.x | Seguridad (headers) |
| Compression | 1.x | Compresión GZIP |
| CORS | 2.x | Cross-Origin Resource Sharing |
| Docker | 20.x+ | Contenerización |

---

## 📦 Requisitos Previos

- **Node.js** >= 18.0.0
- **npm** >= 9.0.0
- **Docker** >= 20.10.0 (opcional)
- **Docker Compose** >= 2.0.0 (opcional)

---

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/SergioLosadaDev/accesorios-dm-api-gateway.git
cd accesorios-dm-api-gateway
```

### 2. Instalar dependencias
```bash
npm install
```
### 3. Configurar variables de entorno
```bash
cp .env.example .env
```
**Edita .env con tus valores:**
```env
PORT=8002
NODE_ENV=development
LOG_LEVEL=info
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173

INVENTORY_HOST=localhost
INVENTORY_PORT=8082

SECURITY_HOST=localhost
SECURITY_PORT=8890

PAYMENT_HOST=localhost
PAYMENT_PORT=9002
```
## 🏃 Ejecución
### Desarrollo (con hot-reload)
```bash
npm run dev
```
### Producción
```bash
npm start
```
### Con Docker
```bash
# Desarrollo
docker-compose up -d

# QA
docker-compose -f docker-compose.yml up -d

# Producción
docker-compose -f docker-compose.yml up -d
```
## Ver logs
```bash
docker-compose logs -f
```

## 📡 Endpoints
### 🔹 Gateway Health
|Método	|Endpoint	|Descripción|
|-------|-----------|-----------|
|GET	|/api/v1/gateway/health	|Estado del gateway|

**Respuesta:**
```json
{
    "status": "UP",
    "service": "api-gateway",
    "version": "1.0.0",
    "environment": "development",
    "timestamp": "2026-05-14T22:00:00.000Z",
    "services": {
        "inventory": "http://localhost:8082",
        "security": "http://localhost:8890",
        "payment": "http://localhost:9002"
    }
}
```

### 🔹 Health Checks de Servicios
|Método	|Endpoint	|Descripción|
|-------|-----------|-----------|
|GET	|/api/v1/health/all	|Estado de todos los servicios|
|GET	|/api/v1/health/inventory	|Estado del servicio Inventory|
|GET	|/api/v1/health/security	|Estado del servicio Security|
|GET	|/api/v1/health/payment	|Estado del servicio Payment|

**Respuesta /health/all:**
```json
{
    "timestamp": "2026-05-14T22:00:00.000Z",
    "services": {
        "inventory": { "status": "UP", "service": "inventory-service", "version": "1.0.0" },
        "security": { "status": "UP", "service": "security-service", "version": "1.0.0" },
        "payment": { "status": "UP", "service": "payment-service", "version": "1.0.0" }
    }
}
```

### 🔹 Inventory Service
|Método	|Endpoint	|Descripción|
|-------|-----------|-----------|
|GET	|/api/v1/inventory/categorias	|Listar todas las categorías|
|GET	|/api/v1/inventory/categorias/{id}	|Obtener categoría por ID|
|POST	|/api/v1/inventory/categorias	|Crear nueva categoría|
|PUT	|/api/v1/inventory/categorias/{id}	|Actualizar categoría|
|DELETE	|/api/v1/inventory/categorias/{id}	|Eliminar categoría|
|GET	|/api/v1/inventory/productos	|Listar todos los productos|
|GET	|/api/v1/inventory/productos/{id}	|Obtener producto por ID|
|POST	|/api/v1/inventory/productos	|Crear nuevo producto|
|PUT	|/api/v1/inventory/productos/{id}	|Actualizar producto|
|DELETE	|/api/v1/inventory/productos/{id}	|Eliminar producto|


### 🔹 Security Service
|Método	|Endpoint	|Descripción|
|-------|-----------|-----------|
|POST	|/api/v1/security/auth/login	|Iniciar sesión|
|POST	|/api/v1/security/auth/logout	|Cerrar sesión|
|POST	|/api/v1/security/auth/refresh	|Refrescar token|
|GET	|/api/v1/security/empleados/	|Listar empleados (requiere token)|
|GET	|/api/v1/security/empleados/{id}	|Obtener empleado por ID|
|POST	|/api/v1/security/empleados/	|Crear empleado|
|PUT	|/api/v1/security/empleados/{id}	|Actualizar empleado|
|DELETE	|/api/v1/security/empleados/{id}	|Eliminar empleado|
|GET	|/api/v1/security/roles/	|Listar roles|

**Ejemplo de Login:**
```bash
curl -X POST http://localhost:8002/api/v1/security/auth/login \
  -H "Content-Type: application/json" \
  -d '{"correo": "admin@accesoriosdm.com", "password": "admin123"}'
```

**Respuesta:**
```json
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 3600
}
```

**Uso del Token:**
```bash
curl -X GET http://localhost:8002/api/v1/security/empleados/ \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 🔹 Payment Service
|Método |Endpoint	|Descripción|
|-------|-----------|-----------|
|POST	|/api/v1/payment/carrito	|Crear nuevo carrito|
|GET	|/api/v1/payment/carrito/{id}	|Obtener carrito por ID|
|POST	|/api/v1/payment/carrito/{id}/items	|Agregar item al carrito|
|PUT	|/api/v1/payment/carrito/{id}/items/{itemId}	|Actualizar cantidad|
|DELETE	|/api/v1/payment/carrito/{id}/items/{itemId}	|Eliminar item|
|DELETE	|/api/v1/payment/carrito/{id}	|Vaciar carrito|
|POST	|/api/v1/payment/pedidos/crear	|Crear pedido desde carrito|
|GET	|/api/v1/payment/pedidos/	|Listar pedidos|
|GET	|/api/v1/payment/pedidos/{id}	|Obtener pedido por ID|

**Ejemplo Crear Carrito:**
```bash
curl -X POST http://localhost:8002/api/v1/payment/carrito \
  -H "Content-Type: application/json" \
  -d '{"id_cliente": 1}'
```

**Respuesta:**
```json
{
    "id_carrito": 5,
    "fecha_creacion": "2026-05-14T22:00:00.000Z",
    "estado": "activo",
    "id_cliente": 1,
    "items": [],
    "total": 0
}
```

**Ejemplo Agregar Item:**
```bash
curl -X POST http://localhost:8002/api/v1/payment/carrito/5/items \
  -H "Content-Type: application/json" \
  -d '{"id_producto": 1, "cantidad": 2}'
```

**Ejemplo Crear Pedido:**
```bash
curl -X POST http://localhost:8002/api/v1/payment/pedidos/crear \
  -H "Content-Type: application/json" \
  -d '{
    "id_carrito": 5,
    "direccion_envio": "Calle 123, Ciudad",
    "telefono_contacto": "3001234567",
    "cliente_nombre": "Juan Perez",
    "cliente_correo": "juan@test.com",
    "cliente_telefono": "3001234567"
  }'
```

## 🛡️ Middlewares

**El API Gateway implementa los siguientes middlewares:**

|Middleware	|Función	|Configuración por Ambiente|
|-----------|-----------|--------------------------|
|Helmet	|Seguridad de headers HTTP	|Activado en todos|
|Compression	|Compresión GZIP	|Activado en todos|
|CORS	|Control de orígenes	|Configurable por ambiente|
|Morgan	|Logging de requests	|Desarrollo: detallado / Producción: minimal|
|Winston	|Logging estructurado	|Archivos: logs/error.log, logs/combined.log|
|Rate Limit	|Límite de peticiones	|Dev: 1000/min, QA: 50/5min, Prod: 100/15min|
|Error Handler	|Manejo global de errores	|Captura 404 y 500|

**Rate Limiting por Ambiente**
|Ambiente	|Ventana	|Máximo de Requests|
|-----------|-----------|------------------|
|Development	|1 minuto	|1000|
|QA	|5 minutos	|50|
|Production	|15 minutos	|100|

**Headers de Seguridad (Helmet)**

- X-DNS-Prefetch-Control: off

- X-Frame-Options: SAMEORIGIN

- X-Download-Options: noopen

- X-Content-Type-Options: nosniff

- X-XSS-Protection: 0

## 🔧 Variables de Entorno
|Variable	|Descripción	|Default	|Obligatorio|
|-----------|---------------|-----------|-----------|
|PORT	|Puerto del gateway	|8002	|No|
|NODE_ENV	|Ambiente (development, qa, production)	|development	|No|
|LOG_LEVEL	|Nivel de logging (error, warn, info, debug)	|info	|No|
|ALLOWED_ORIGINS	|Orígenes permitidos CORS (separados por coma)	|http://localhost:3000	|No|
|INVENTORY_HOST	|Host del servicio Inventory	|localhost	|No|
|INVENTORY_PORT	|Puerto del servicio Inventory	|8082	|No|
|SECURITY_HOST	|Host del servicio Security	|localhost	|No|
|SECURITY_PORT	|Puerto del servicio Security	|8890	|No|
|PAYMENT_HOST	|Host del servicio Payment	|localhost	|No|
|PAYMENT_PORT	|Puerto del servicio Payment	|9002	|No|

## 📁 Estructura del Proyecto
```text
accesorios-dm-api-gateway/
├── src/
│   ├── index.js              # Punto de entrada
│   ├── config.js             # Configuración central
│   ├── routes/
│   │   └── index.js          # Rutas y proxies
│   ├── middleware/
│   │   ├── cors.js           # CORS
│   │   ├── logging.js        # Morgan + Winston
│   │   ├── rateLimit.js      # Rate limiting
│   │   └── errorHandler.js   # Manejo de errores
│   └── utils/
│       └── logger.js         # Configuración Winston
├── logs/                     # Archivos de log
├── Dockerfile                # Docker para desarrollo
├── Dockerfile.prod           # Docker optimizado para producción
├── docker-compose.yml        # Docker Compose
├── .env.example              # Ejemplo de variables de entorno
├── .gitignore                # Archivos ignorados por Git
├── package.json              # Dependencias
└── README.md                 # Documentación
```
## 🧪 Pruebas

### Probar con curl
```bash
# Health del gateway
curl http://localhost:8002/api/v1/gateway/health

# Health de todos los servicios
curl http://localhost:8002/api/v1/health/all

# Listar categorías
curl http://localhost:8002/api/v1/inventory/categorias

# Login
curl -X POST http://localhost:8002/api/v1/security/auth/login \
  -H "Content-Type: application/json" \
  -d '{"correo":"admin@accesoriosdm.com","password":"admin123"}'
```

### Probar con Postman
1. Importar la colección (próximamente disponible)

2. Variables de entorno:

- baseUrl: http://localhost:8002

- token: se autocompleta después del login

### Probar Rate Limiting
```bash
# Hacer 20 peticiones rápidas
for i in {1..20}; do
  curl http://localhost:8002/api/v1/gateway/health
done
```
**Después de 20 peticiones (en desarrollo), recibirás:**
```json
{
    "error": "Demasiadas peticiones, intenta más tarde"
}
```

## 🚢 Despliegue

### Producción con Docker
```bash
# 1. Crear red de producción
docker network create accesorios-dm-database_accesorios-network-prod

# 2. Construir y levantar
docker-compose up -d --build

# 3. Verificar health
curl http://localhost:8000/api/v1/gateway/health

# 4. Ver logs
docker-compose logs -f
```

### Sin Docker
```bash
# 1. Configurar .env
cp .env.example .env
# Editar .env con valores de producción

# 2. Instalar dependencias
npm ci --only=production

# 3. Iniciar
npm start
```
## ❓ Solución de Problemas
### Error: ECONNREFUSED

Problema: El gateway no puede conectar con un microservicio.

Solución:

```bash
# Verificar que los microservicios están corriendo
docker ps | findstr "inventory|security|payment"

# Verificar conectividad
docker exec -it accesorios-dm-gateway-dev sh -c "wget -qO- http://host.docker.internal:8082/api/v1/health"
```

### Error: 429 Too Many Requests
Problema: Se excedió el límite de rate limiting.

Solución: Esperar a que se reinicie la ventana de tiempo o aumentar el límite en .env.

### Error: CORS en el frontend
Problema: El origen no está permitido.

Solución: Agregar el origen a ALLOWED_ORIGINS en .env.

### Error: Token inválido o expirado
Problema: El token JWT no es válido.

Solución:

```bash
# Obtener nuevo token
curl -X POST http://localhost:8002/api/v1/security/auth/login \
  -H "Content-Type: application/json" \
  -d '{"correo":"admin@accesoriosdm.com","password":"admin123"}'
```
## 📝 Códigos de Estado HTTP
|Código	|Significado|
|-------|-----------|
|200	|OK - Petición exitosa|
|201	|Created - Recurso creado|
|400	|Bad Request - Error en la petición|
|401	|Unauthorized - No autenticado|
|403	|Forbidden - Sin permisos|
|404	|Not Found - Recurso no encontrado|
|429	|Too Many Requests - Rate limit excedido|
|500	|Internal Server Error - Error del servidor|
|503	|Service Unavailable - Servicio no disponible|

## 📄 Licencia

*Todos los derechos reservados - Accesorios DM © 2026*


## 🔄 Historial de Versiones
|Versión	|Fecha	|Cambios|
|-----------|-------|-------|
|v1.0.0	|2026-05-14	|Primera versión estable|
|v1.0.0	|2026-05-14	|Middlewares implementados|
|v1.0.0	|2026-05-14	|Rate limiting por ambiente|

*Última actualización: 14 de mayo de 2026*