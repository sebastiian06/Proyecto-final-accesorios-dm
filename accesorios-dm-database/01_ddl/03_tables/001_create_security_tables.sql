-- =====================================================
-- Tabla: ROL
-- Descripción: Almacena los roles del sistema
-- Schema: security
-- =====================================================

CREATE TABLE IF NOT EXISTS security.rol (
    id_rol SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE security.rol IS 'Almacena los roles del sistema';
COMMENT ON COLUMN security.rol.id_rol IS 'Identificador único del rol (autoincremental)';
COMMENT ON COLUMN security.rol.nombre IS 'Nombre del rol (ej: ADMIN, VENDEDOR) - Debe ser único';
COMMENT ON COLUMN security.rol.descripcion IS 'Descripción opcional del rol';
COMMENT ON COLUMN security.rol.fecha_creacion IS 'Fecha y hora de creación del registro';

-- =====================================================
-- Tabla: EMPLEADO
-- Descripción: Almacena los empleados del sistema
-- Schema: security
-- =====================================================

CREATE TABLE IF NOT EXISTS security.empleado (
    id_empleado SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(120) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    id_rol INTEGER NOT NULL
);

COMMENT ON TABLE security.empleado IS 'Almacena los empleados del sistema';
COMMENT ON COLUMN security.empleado.id_empleado IS 'Identificador único del empleado (autoincremental)';
COMMENT ON COLUMN security.empleado.nombre IS 'Nombre completo del empleado';
COMMENT ON COLUMN security.empleado.correo IS 'Correo electrónico - Debe ser único, usado para login';
COMMENT ON COLUMN security.empleado.password IS 'Contraseña encriptada';
COMMENT ON COLUMN security.empleado.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN security.empleado.estado IS 'TRUE=Activo, FALSE=Inactivo';
COMMENT ON COLUMN security.empleado.id_rol IS 'Llave foránea que referencia al rol';

-- =====================================================
-- Llaves Foráneas
-- =====================================================

ALTER TABLE security.empleado
    ADD CONSTRAINT fk_empleado_rol
    FOREIGN KEY (id_rol)
    REFERENCES security.rol(id_rol)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;