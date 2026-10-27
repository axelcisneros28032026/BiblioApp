

CREATE DATABASE biblioapp
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE biblioapp;

CREATE TABLE Roles (
    id_rol INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_rol)
);

CREATE TABLE Usuarios (
    id_usuario INT NOT NULL AUTO_INCREMENT,
    id_rol INT NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    correo_institucional VARCHAR(120) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_usuario),
    CONSTRAINT fk_usuarios_roles
        FOREIGN KEY (id_rol) REFERENCES Roles (id_rol)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Admins (
    id_admin INT NOT NULL AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_admin),
    CONSTRAINT fk_admins_usuarios
        FOREIGN KEY (id_usuario) REFERENCES Usuarios (id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Lectores (
    id_lector INT NOT NULL AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_lector),
    CONSTRAINT fk_lectores_usuarios
        FOREIGN KEY (id_usuario) REFERENCES Usuarios (id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Alumnos (
    id_lector INT NOT NULL,
    carrera VARCHAR(80) NOT NULL,
    semestre INT NOT NULL,
    PRIMARY KEY (id_lector),
    CONSTRAINT fk_alumnos_lectores
        FOREIGN KEY (id_lector) REFERENCES Lectores (id_lector)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Docentes (
    id_lector INT NOT NULL,
    departamento VARCHAR(80) NOT NULL,
    PRIMARY KEY (id_lector),
    CONSTRAINT fk_docentes_lectores
        FOREIGN KEY (id_lector) REFERENCES Lectores (id_lector)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Editoriales (
    id_editorial INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_editorial)
);

CREATE TABLE Categorias (
    id_categoria INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    PRIMARY KEY (id_categoria)
);

CREATE TABLE Autores (
    id_autor INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(120) NOT NULL,
    PRIMARY KEY (id_autor)
);

CREATE TABLE Libros (
    id_libro INT NOT NULL AUTO_INCREMENT,
    id_editorial INT NOT NULL,
    id_categoria INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(17),
    publicacion YEAR,
    edicion VARCHAR(30),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_libro),
    CONSTRAINT fk_libros_editoriales
        FOREIGN KEY (id_editorial) REFERENCES Editoriales (id_editorial)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_libros_categorias
        FOREIGN KEY (id_categoria) REFERENCES Categorias (id_categoria)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Libro_Autor (
    id_libro INT NOT NULL,
    id_autor INT NOT NULL,
    PRIMARY KEY (id_libro, id_autor),
    CONSTRAINT fk_libro_autor_libros
        FOREIGN KEY (id_libro) REFERENCES Libros (id_libro)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_libro_autor_autores
        FOREIGN KEY (id_autor) REFERENCES Autores (id_autor)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Ubicaciones (
    id_ubicacion INT NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(20) NOT NULL,
    descripcion VARCHAR(150),
    PRIMARY KEY (id_ubicacion)
);

CREATE TABLE Ejemplares (
    id_ejemplar INT NOT NULL AUTO_INCREMENT,
    id_libro INT NOT NULL,
    id_ubicacion INT NOT NULL,
    cod_inventario VARCHAR(30) NOT NULL,
    estado ENUM('habilitado','mantenimiento','baja') NOT NULL DEFAULT 'habilitado',
    PRIMARY KEY (id_ejemplar),
    CONSTRAINT fk_ejemplares_libros
        FOREIGN KEY (id_libro) REFERENCES Libros (id_libro)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ejemplares_ubicaciones
        FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones (id_ubicacion)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Prestamos (
    id_prestamo INT NOT NULL AUTO_INCREMENT,
    id_lector INT NOT NULL,
    id_admin INT NOT NULL,
    fecha_prestamo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_prestamo),
    CONSTRAINT fk_prestamos_lectores
        FOREIGN KEY (id_lector) REFERENCES Lectores (id_lector)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prestamos_admins
        FOREIGN KEY (id_admin) REFERENCES Admins (id_admin)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Detalle_Prestamo (
    id_detalle INT NOT NULL AUTO_INCREMENT,
    id_prestamo INT NOT NULL,
    id_ejemplar INT NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    fecha_devolucion DATETIME,
    id_admin_devolucion INT,
    observaciones TEXT,
    PRIMARY KEY (id_detalle),
    CONSTRAINT fk_detalle_prestamos
        FOREIGN KEY (id_prestamo) REFERENCES Prestamos (id_prestamo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_ejemplares
        FOREIGN KEY (id_ejemplar) REFERENCES Ejemplares (id_ejemplar)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_admins
        FOREIGN KEY (id_admin_devolucion) REFERENCES Admins (id_admin)
);

ALTER TABLE Roles
    ADD CONSTRAINT uk_roles_nombre UNIQUE (nombre);

ALTER TABLE Usuarios
    ADD CONSTRAINT uk_usuarios_correo UNIQUE (correo_institucional);

ALTER TABLE Admins
    ADD CONSTRAINT uk_admins_usuario UNIQUE (id_usuario);

ALTER TABLE Lectores
    ADD CONSTRAINT uk_lectores_usuario UNIQUE (id_usuario);

ALTER TABLE Editoriales
    ADD CONSTRAINT uk_editoriales_nombre UNIQUE (nombre);

ALTER TABLE Categorias
    ADD CONSTRAINT uk_categorias_nombre UNIQUE (nombre);

ALTER TABLE Libros
    ADD CONSTRAINT uk_libros_isbn UNIQUE (isbn);

ALTER TABLE Ubicaciones
    ADD CONSTRAINT uk_ubicaciones_codigo UNIQUE (codigo);

ALTER TABLE Ejemplares
    ADD CONSTRAINT uk_ejemplares_cod_inventario UNIQUE (cod_inventario);

ALTER TABLE Alumnos
    ADD CONSTRAINT ck_alumnos_semestre CHECK (semestre >= 1 AND semestre <= 12);

ALTER TABLE Detalle_Prestamo
    ADD CONSTRAINT ck_detalle_devolucion CHECK (
        (fecha_devolucion IS NULL AND id_admin_devolucion IS NULL)
        OR
        (fecha_devolucion IS NOT NULL AND id_admin_devolucion IS NOT NULL)
    );


