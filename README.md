# Accesorios D&M - Entrega Final

Sistema ecommerce distribuido basado en servicios.

## Intengrantes

- Juan Sebastian Agudelo Quintero
- Dayana Stephany Motta Camayo
- Carol Liceth Cruz Roa
- Miguel Angel Rivera Lozano

## Arquitectura

```text
Frontend Angular
      ↓
API Gateway
      ↓
Servicios Backend
 ├── Security Service
 ├── Inventory Service
 └── Payment Service
      ↓
PostgreSQL
```


El proyecto no se presenta como microservicios puros, sino como una *arquitectura basada en servicios*, ya que existe separación por dominios, pero aún se comparte infraestructura y persistencia.

## Servicios

### Frontend

Aplicación web Angular para clientes y administradores.

### API Gateway

Punto único de entrada para el frontend.

### Security Service

Autenticación JWT, empleados, roles y clientes.

### Inventory Service

Productos, categorías, imágenes y promociones.

### Payment Service

Checkout, pedidos y estados de pedido.

### Database

Base de datos PostgreSQL.

## Orden de despliegue

1. Database
2. Security Service
3. Inventory Service
4. Payment Service
5. API Gateway
6. Frontend

## Despliegue rápido

```bash
cd accesorios-dm-database
docker-compose build
docker-compose -f docker-compose.prod.yml up -d

cd accesorios-dm-security-service
docker compose up -d --build

cd accesorios-dm-inventory-service
docker compose up -d --build

cd accesorios-dm-payment-service
docker compose up -d --build

cd accesorios-dm-api-gateway
docker compose up -d --build

cd accesorios-dm-frontend
docker compose up -d --build
```


## Puertos principales

| Servicio | Puerto |
|---|---:|
| Frontend | 80 |
| API Gateway | 8000 |
| Security Service | 8888 |
| Inventory Service | 8080 |
| Payment Service | 9000 |
| PostgreSQL | 5432 |

## Nota

El frontend debe consumir únicamente el API Gateway:

```text
http://localhost:8000/api/v1
```


En producción debe cambiarse por la URL pública del API Gateway en AWS.