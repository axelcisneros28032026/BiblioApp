DROP DATABASE IF EXISTS biblioapp;

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

INSERT INTO Roles (id_rol, nombre) VALUES
    (1, 'Administrador'),
    (2, 'Alumno'),
    (3, 'Docente');

INSERT INTO Usuarios
    (id_usuario, id_rol, nombre, correo_institucional, password_hash, activo)
VALUES
    (9, 3, 'Sheinbaum', 'laesperanzademexico@itparral.edu.mx', '$2y$12$H4xoZ0oab4FhRyyQxSYLX.Ca99sDd8vENC7mYwjX0Yr3CroFkbasq', TRUE),
    (10, 2, 'Amery', 'amery@itparral.edu.mx', '$2y$12$H4xoZ0oab4FhRyyQxSYLX.Ca99sDd8vENC7mYwjX0Yr3CroFkbasq', TRUE),
    (11, 1, 'Administrador BiblioApp', 'admin@biblioapp.com', '$2y$12$cwuTYDq8BandRyJre5iiL.lK3bMXAFNt9lkF0Rxzmft8SIk0mj6Ei', TRUE),
    (1, 1, 'Laura Gutiérrez Mendoza', 'laura.gutierrez@biblioapp.edu.mx', '$2y$10$KlX.hUJXXmpkOW9qVqS6EOHPYzsxxgbF/wpXvq.7Rzv9juuacjRNq', TRUE),
    (2, 1, 'Roberto Salas Ortega', 'roberto.salas@biblioapp.edu.mx', '$2y$10$KlX.hUJXXmpkOW9qVqS6EOHPYzsxxgbF/wpXvq.7Rzv9juuacjRNq', TRUE),
    (3, 2, 'Ana Sofía Torres Rivera', 'a24410101@biblioapp.edu.mx', '$2y$10$6LJ41TpBf3yWodOPuVpzWephUTdstEnu62F.Kf3yJVULNU2tGVxf6', TRUE),
    (4, 2, 'Carlos Eduardo Ruiz Lara', 'a24410202@biblioapp.edu.mx', '$2y$10$6LJ41TpBf3yWodOPuVpzWephUTdstEnu62F.Kf3yJVULNU2tGVxf6', TRUE),
    (5, 2, 'María Fernanda Chávez Soto', 'a24410303@biblioapp.edu.mx', '$2y$10$6LJ41TpBf3yWodOPuVpzWephUTdstEnu62F.Kf3yJVULNU2tGVxf6', TRUE),
    (6, 2, 'Diego Armando Pérez Nava', 'a23410404@biblioapp.edu.mx', '$2y$10$6LJ41TpBf3yWodOPuVpzWephUTdstEnu62F.Kf3yJVULNU2tGVxf6', FALSE),
    (7, 3, 'Dr. Héctor Villalobos Ríos', 'hector.villalobos@biblioapp.edu.mx', '$2y$10$6LJ41TpBf3yWodOPuVpzWephUTdstEnu62F.Kf3yJVULNU2tGVxf6', TRUE),
    (8, 3, 'Mtra. Patricia Domínguez Luna','patricia.dominguez@biblioapp.edu.mx', '$2y$10$6LJ41TpBf3yWodOPuVpzWephUTdstEnu62F.Kf3yJVULNU2tGVxf6', TRUE);

INSERT INTO Admins (id_admin, id_usuario) VALUES
    (1, 1),
    (2, 2);

INSERT INTO Lectores (id_lector, id_usuario) VALUES
    (1, 3), (2, 4), (3, 5), (4, 6),
    (5, 7), (6, 8);

INSERT INTO Alumnos (id_lector, carrera, semestre) VALUES
    (1, 'Ingeniería en Sistemas Computacionales', 3),
    (2, 'Ingeniería Industrial', 5),
    (3, 'Arquitectura', 1),
    (4, 'Contaduría Pública', 7);

INSERT INTO Docentes (id_lector, departamento) VALUES
    (5, 'Ciencias Básicas'),
    (6, 'Sistemas y Computación');

INSERT INTO Editoriales (id_editorial, nombre) VALUES
    (1, 'Pearson Educación'),
    (2, 'McGraw-Hill'),
    (3, 'Alfaomega'),
    (4, 'Fondo de Cultura Económica'),
    (5, 'Penguin Random House'),
    (6, 'Anagrama');

INSERT INTO Categorias (id_categoria, nombre) VALUES
    (1, 'Programación'),
    (2, 'Bases de datos'),
    (3, 'Matemáticas'),
    (4, 'Literatura'),
    (5, 'Historia'),
    (6, 'Administración');

INSERT INTO Autores (id_autor, nombre) VALUES
    (1, 'Abraham Silberschatz'),
    (2, 'Henry F. Korth'),
    (3, 'S. Sudarshan'),
    (4, 'Andrew S. Tanenbaum'),
    (5, 'Gabriel García Márquez'),
    (6, 'Juan Rulfo'),
    (7, 'Octavio Paz'),
    (8, 'James Stewart'),
    (9, 'Ramez Elmasri'),
    (10, 'Shamkant B. Navathe'),
    (11, 'Robert C. Martin'),
    (12, 'Carlos Fuentes'),
    (13, 'Daniel Cosío Villegas'),
    (14, 'Harold Koontz');

INSERT INTO Ubicaciones (id_ubicacion, codigo, descripcion) VALUES
    (1, 'A-01', 'Estante A1 - Computación'),
    (2, 'A-02', 'Estante A2 - Bases de datos y redes'),
    (3, 'B-01', 'Estante B1 - Ciencias exactas'),
    (4, 'C-01', 'Estante C1 - Literatura'),
    (5, 'D-01', 'Estante D1 - Historia y humanidades');

INSERT INTO Libros (id_libro, id_editorial, id_categoria, titulo, isbn, publicacion, edicion, activo) VALUES
    (1, 2, 2, 'Fundamentos de bases de datos', '978-84-481-9440-8', 2014, '6a edición', TRUE),
    (2, 1, 1, 'Redes de computadoras', '978-60-751-3032-6', 2012, '5a edición', TRUE),
    (3, 3, 2, 'Fundamentos de sistemas de bases de datos', '978-84-783-2990-6', 2007, '5a edición', TRUE),
    (4, 1, 1, 'Código limpio', '978-60-731-6046-3', 2012, '1a edición', TRUE),
    (5, 5, 4, 'Cien años de soledad', '978-60-731-4094-6', 2017, '1a edición', TRUE),
    (6, 4, 4, 'Pedro Páramo', '978-96-816-6129-1', 2005, '2a edición', TRUE),
    (7, 4, 4, 'El laberinto de la soledad', '978-96-816-3231-4', 1999, '3a edición', TRUE),
    (8, 2, 3, 'Cálculo de una variable', '978-60-748-1990-4', 2012, '7a edición', TRUE),
    (9, 6, 4, 'La muerte de Artemio Cruz', '978-60-731-5188-1', 2018, '1a edición', TRUE),
    (10, 4, 5, 'Historia mínima de México', NULL, 2004, '1a edición', TRUE),
    (11, 1, 6, 'Fundamentos de administración', NULL, 2010, '2a edición', TRUE),
    (12, 3, 1, 'Programación orientada a objetos (descontinuado)', NULL, 1998, '1a edición', FALSE);

INSERT INTO Libro_Autor (id_libro, id_autor) VALUES
    (1, 1), (1, 2), (1, 3),
    (2, 4),
    (3, 9), (3, 10),
    (4, 11),
    (5, 5),
    (6, 6),
    (7, 7),
    (8, 8),
    (9, 12),
    (10, 13),
    (11, 14),
    (12, 11);

INSERT INTO Ejemplares (id_ejemplar, id_libro, id_ubicacion, cod_inventario, estado) VALUES
    (1, 1, 2, 'BIB-0001', 'habilitado'),
    (2, 1, 2, 'BIB-0002', 'habilitado'),
    (3, 2, 2, 'BIB-0003', 'habilitado'),
    (4, 3, 2, 'BIB-0004', 'habilitado'),
    (5, 4, 1, 'BIB-0005', 'habilitado'),
    (6, 4, 1, 'BIB-0006', 'habilitado'),
    (7, 5, 4, 'BIB-0007', 'habilitado'),
    (8, 5, 4, 'BIB-0008', 'habilitado'),
    (9, 6, 4, 'BIB-0009', 'habilitado'),
    (10, 7, 4, 'BIB-0010', 'habilitado'),
    (11, 8, 3, 'BIB-0011', 'habilitado'),
    (12, 8, 3, 'BIB-0012', 'habilitado'),
    (13, 9, 4, 'BIB-0013', 'habilitado'),
    (14, 10, 5, 'BIB-0014', 'habilitado'),
    (15, 11, 5, 'BIB-0015', 'habilitado'),
    (16, 2, 2, 'BIB-0016', 'mantenimiento'),
    (17, 6, 4, 'BIB-0017', 'baja'),
    (18, 12, 1, 'BIB-0018', 'habilitado');

INSERT INTO Prestamos (id_prestamo, id_lector, id_admin, fecha_prestamo) VALUES
    (1, 1, 1, '2026-09-28 10:15:00'),
    (2, 2, 1, '2026-10-05 12:30:00'),
    (3, 5, 2, '2026-10-12 09:00:00'),
    (4, 3, 2, '2026-10-20 16:45:00'),
    (5, 6, 1, '2026-09-15 11:00:00');

INSERT INTO Detalle_Prestamo
    (id_detalle, id_prestamo, id_ejemplar, fecha_vencimiento, fecha_devolucion, id_admin_devolucion, observaciones) VALUES
    (1, 1, 1, '2026-10-12', NULL, NULL, NULL),
    (2, 1, 5, '2026-10-12', '2026-10-10 13:20:00', 2, 'Devuelto en buen estado'),
    (3, 2, 7, '2026-10-19', '2026-10-18 10:05:00', 1, 'Devuelto, página 112 con doblez'),
    (4, 2, 11, '2026-11-02', NULL, NULL, NULL),
    (5, 3, 3, '2026-11-12', NULL, NULL, NULL),
    (6, 4, 9, '2026-11-03', NULL, NULL, NULL),
    (7, 5, 10, '2026-09-29', NULL, NULL, NULL),
    (8, 5, 14, '2026-09-29', '2026-09-27 15:10:00', 1, NULL);

UPDATE Ejemplares SET estado = 'mantenimiento' WHERE id_ejemplar = 7;

INSERT INTO Admins (id_admin, id_usuario) VALUES
    (3, 11);

INSERT INTO Lectores (id_lector, id_usuario) VALUES
    (7, 9),
    (8, 10);

INSERT INTO Docentes (id_lector, departamento) VALUES
    (7, 'Ciencias Básicas');

INSERT INTO Alumnos (id_lector, carrera, semestre) VALUES
    (8, 'Ingeniería en Sistemas Computacionales', 6);
