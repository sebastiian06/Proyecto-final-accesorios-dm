-- =====================================================
-- Tabla: CATEGORIA
-- Descripción: Clasificación de productos
-- Schema: catalogo
-- =====================================================

CREATE TABLE IF NOT EXISTS catalogo.categoria (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT,
    estado BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE catalogo.categoria IS 'Clasificación de productos (ej: Anillos, Collares, Pulseras)';
COMMENT ON COLUMN catalogo.categoria.id_categoria IS 'Identificador único de la categoría';
COMMENT ON COLUMN catalogo.categoria.nombre IS 'Nombre de la categoría - Debe ser único';
COMMENT ON COLUMN catalogo.categoria.descripcion IS 'Descripción detallada de la categoría';
COMMENT ON COLUMN catalogo.categoria.estado IS 'TRUE=Activo, FALSE=Inactivo';

-- =====================================================
-- Tabla: MATERIAL
-- Descripción: Tipos de materiales de los productos
-- Schema: catalogo
-- =====================================================

CREATE TABLE IF NOT EXISTS catalogo.material (
    id_material SERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT
);

COMMENT ON TABLE catalogo.material IS 'Materiales de los productos (ej: Oro, Plata, Acero)';
COMMENT ON COLUMN catalogo.material.id_material IS 'Identificador único del material';
COMMENT ON COLUMN catalogo.material.nombre IS 'Nombre del material - Debe ser único';
COMMENT ON COLUMN catalogo.material.descripcion IS 'Descripción del material';

-- =====================================================
-- Tabla: PRODUCTO
-- Descripción: Productos del catálogo
-- Schema: catalogo
-- =====================================================

CREATE TABLE IF NOT EXISTS catalogo.producto (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio NUMERIC(10,2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    id_categoria INTEGER NOT NULL,
    id_material INTEGER NOT NULL
);

COMMENT ON TABLE catalogo.producto IS 'Productos del catálogo de accesorios';
COMMENT ON COLUMN catalogo.producto.id_producto IS 'Identificador único del producto';
COMMENT ON COLUMN catalogo.producto.nombre IS 'Nombre del producto';
COMMENT ON COLUMN catalogo.producto.descripcion IS 'Descripción detallada del producto';
COMMENT ON COLUMN catalogo.producto.precio IS 'Precio del producto (formato monetario)';
COMMENT ON COLUMN catalogo.producto.stock IS 'Cantidad disponible en inventario';
COMMENT ON COLUMN catalogo.producto.fecha_creacion IS 'Fecha de creación del producto';
COMMENT ON COLUMN catalogo.producto.estado IS 'TRUE=Activo, FALSE=Inactivo';
COMMENT ON COLUMN catalogo.producto.id_categoria IS 'Llave foránea a categoría';
COMMENT ON COLUMN catalogo.producto.id_material IS 'Llave foránea a material';

-- =====================================================
-- Llaves Foráneas
-- =====================================================

-- Relación: PRODUCTO pertenece a una CATEGORIA
ALTER TABLE catalogo.producto
    ADD CONSTRAINT fk_producto_categoria
    FOREIGN KEY (id_categoria)
    REFERENCES catalogo.categoria(id_categoria)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Relación: PRODUCTO tiene un MATERIAL
ALTER TABLE catalogo.producto
    ADD CONSTRAINT fk_producto_material
    FOREIGN KEY (id_material)
    REFERENCES catalogo.material(id_material)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;