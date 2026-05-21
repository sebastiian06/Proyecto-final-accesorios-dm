-- =========================================
-- 1. CREACIÓN DE SCHEMAS
-- =========================================
CREATE SCHEMA IF NOT EXISTS seguridad;
CREATE SCHEMA IF NOT EXISTS inventario;
CREATE SCHEMA IF NOT EXISTS pago;

-- =========================================
-- 2. MICROSERVICIO SEGURIDAD
-- =========================================

CREATE TABLE seguridad.usuario (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE seguridad.rol (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE seguridad.usuario_rol (
    usuario_id INT NOT NULL,
    rol_id INT NOT NULL,
    PRIMARY KEY (usuario_id, rol_id),
    FOREIGN KEY (usuario_id) REFERENCES seguridad.usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (rol_id) REFERENCES seguridad.rol(id) ON DELETE CASCADE
);

-- =========================================
-- 3. MICROSERVICIO INVENTARIO
-- =========================================

CREATE TABLE inventario.categoria (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE inventario.producto (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    categoria_id INT,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES inventario.categoria(id) ON DELETE SET NULL
);

CREATE TABLE inventario.inventario_stock (
    id SERIAL PRIMARY KEY,
    producto_id INT NOT NULL UNIQUE,
    cantidad INT NOT NULL CHECK (cantidad >= 0),
    ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES inventario.producto(id) ON DELETE CASCADE
);

CREATE TABLE inventario.imagen_producto (
    id SERIAL PRIMARY KEY,
    producto_id INT NOT NULL,
    url TEXT NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES inventario.producto(id) ON DELETE CASCADE
);

-- =========================================
-- 4. MICROSERVICIO PAGO
-- =========================================

CREATE TABLE pago.carrito (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    estado VARCHAR(50) DEFAULT 'ACTIVO',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES seguridad.usuario(id) ON DELETE CASCADE
);

CREATE TABLE pago.carrito_detalle (
    id SERIAL PRIMARY KEY,
    carrito_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    FOREIGN KEY (carrito_id) REFERENCES pago.carrito(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES inventario.producto(id)
);

CREATE TABLE pago.pedido (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total NUMERIC(10,2) CHECK (total >= 0),
    estado VARCHAR(50) DEFAULT 'PENDIENTE',
    FOREIGN KEY (usuario_id) REFERENCES seguridad.usuario(id)
);

CREATE TABLE pago.pedido_detalle (
    id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    FOREIGN KEY (pedido_id) REFERENCES pago.pedido(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES inventario.producto(id)
);

CREATE TABLE pago.pago (
    id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    estado VARCHAR(50) DEFAULT 'PENDIENTE',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pago.pedido(id) ON DELETE CASCADE
);

-- =========================================
-- 5. ÍNDICES PARA RENDIMIENTO
-- =========================================

CREATE INDEX idx_usuario_email ON seguridad.usuario(email);

CREATE INDEX idx_producto_categoria 
ON inventario.producto(categoria_id);

CREATE INDEX idx_stock_producto 
ON inventario.inventario_stock(producto_id);

CREATE INDEX idx_carrito_usuario 
ON pago.carrito(usuario_id);

CREATE INDEX idx_pedido_usuario 
ON pago.pedido(usuario_id);

CREATE INDEX idx_pedido_detalle_pedido 
ON pago.pedido_detalle(pedido_id);

-- =========================================
-- 6. DATOS INICIALES
-- =========================================

INSERT INTO seguridad.rol (nombre) VALUES ('ADMIN'), ('CLIENTE');

INSERT INTO inventario.categoria (nombre, descripcion) VALUES
('Collares', 'Accesorios para el cuello'),
('Pulseras', 'Accesorios para la muñeca'),
('Anillos', 'Accesorios para dedos');

INSERT INTO seguridad.usuario (nombre, email, password_hash)
VALUES ('Admin', 'admin@test.com', '123456');

INSERT INTO seguridad.usuario_rol (usuario_id, rol_id)
VALUES (1, 1);

-- PRODUCTOS DE PRUEBA (IMPORTANTE)
INSERT INTO inventario.producto (nombre, descripcion, precio, categoria_id, activo)
VALUES
('Aretes Dorados', 'Aretes elegantes', 25000, 1, TRUE),
('Collar Corazón', 'Collar dorado', 45000, 1, TRUE),
('Pulsera Minimalista', 'Pulsera sencilla', 18000, 2, TRUE),
('Anillo Plateado', 'Anillo ajustable', 22000, 3, TRUE);

INSERT INTO inventario.imagen_producto (producto_id, url)
VALUES
(1, 'https://via.placeholder.com/150'),
(2, 'https://via.placeholder.com/150'),
(3, 'https://via.placeholder.com/150'),
(4, 'https://via.placeholder.com/150');