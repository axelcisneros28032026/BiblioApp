-- BiblioApp: primer avance. MySQL 8.0.16 o superior.

-- Ejecutar UNA VEZ en una base nueva. No borra ni reemplaza bases existentes.

-- Datos ficticios; contraseñas demo solo para un entorno local.

CREATE DATABASE biblioapp CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

USE biblioapp;

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE TABLE Roles (
    id_rol INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Usuarios (
    id_usuario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    correo_institucional VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT 1,
    UNIQUE KEY uq_usuario_rol (id_usuario, id_rol),
    FOREIGN KEY (id_rol) REFERENCES Roles(id_rol),
    CHECK (activo IN (0,1)),
    CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CHECK (CHAR_LENGTH(TRIM(correo_institucional)) > 0)
) ENGINE=InnoDB;

CREATE TABLE Admins (
    id_admin INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    id_rol INT NOT NULL DEFAULT 1,
    CHECK (id_rol = 1),
    FOREIGN KEY (id_usuario,id_rol) REFERENCES Usuarios(id_usuario,id_rol)
) ENGINE=InnoDB;

CREATE TABLE Lectores (
    id_lector INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    id_rol INT NOT NULL DEFAULT 2,
    tipo ENUM('Alumno','Docente') NOT NULL,
    CHECK (id_rol = 2),
    UNIQUE KEY uq_lector_tipo (id_lector,tipo),
    FOREIGN KEY (id_usuario,id_rol) REFERENCES Usuarios(id_usuario,id_rol)
) ENGINE=InnoDB;

CREATE TABLE Alumnos (
    id_lector INT NOT NULL PRIMARY KEY,
    tipo ENUM('Alumno','Docente') NOT NULL DEFAULT 'Alumno',
    matricula VARCHAR(20) NOT NULL UNIQUE,
    carrera VARCHAR(100) NOT NULL,
    semestre INT NOT NULL,
    CHECK (tipo = 'Alumno'),
    CHECK (semestre BETWEEN 1 AND 16),
    CHECK (CHAR_LENGTH(TRIM(matricula)) > 0),
    FOREIGN KEY (id_lector,tipo) REFERENCES Lectores(id_lector,tipo)
) ENGINE=InnoDB;

CREATE TABLE Docentes (
    id_lector INT NOT NULL PRIMARY KEY,
    tipo ENUM('Alumno','Docente') NOT NULL DEFAULT 'Docente',
    numero_empleado VARCHAR(20) NOT NULL UNIQUE,
    departamento VARCHAR(100) NOT NULL,
    CHECK (tipo = 'Docente'),
    CHECK (CHAR_LENGTH(TRIM(numero_empleado)) > 0),
    FOREIGN KEY (id_lector,tipo) REFERENCES Lectores(id_lector,tipo)
) ENGINE=InnoDB;

CREATE TABLE Editoriales (
    id_editorial INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    CHECK (CHAR_LENGTH(TRIM(nombre)) > 0)
) ENGINE=InnoDB;

CREATE TABLE Categorias (
    id_categoria INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    CHECK (CHAR_LENGTH(TRIM(nombre)) > 0)
) ENGINE=InnoDB;

CREATE TABLE Autores (
    id_autor INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    CHECK (CHAR_LENGTH(TRIM(nombre)) > 0)
) ENGINE=InnoDB;

CREATE TABLE Libros (
    id_libro INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_editorial INT NOT NULL,
    id_categoria INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(17) NULL UNIQUE,
    publicacion YEAR NULL,
    edicion VARCHAR(40) NULL,
    activo BOOLEAN NOT NULL DEFAULT 1,
    FOREIGN KEY (id_editorial) REFERENCES Editoriales(id_editorial),
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria),
    CHECK (isbn IS NULL OR CHAR_LENGTH(TRIM(isbn)) > 0),
    CHECK (activo IN (0,1)),
    CHECK (CHAR_LENGTH(TRIM(titulo)) > 0)
) ENGINE=InnoDB;

CREATE TABLE Libro_Autor (
    id_libro INT NOT NULL,
    id_autor INT NOT NULL,
    PRIMARY KEY (id_libro,id_autor),
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro),
    FOREIGN KEY (id_autor) REFERENCES Autores(id_autor)
) ENGINE=InnoDB;

CREATE TABLE Ubicaciones (
    id_ubicacion INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NOT NULL,
    CHECK (CHAR_LENGTH(TRIM(codigo)) > 0)
) ENGINE=InnoDB;

CREATE TABLE Ejemplares (
    id_ejemplar INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_libro INT NOT NULL,
    id_ubicacion INT NOT NULL,
    cod_inventario VARCHAR(30) NOT NULL UNIQUE,
    estado ENUM('habilitado','mantenimiento','baja') NOT NULL DEFAULT 'habilitado',
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro),
    FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id_ubicacion),
    CHECK (CHAR_LENGTH(TRIM(cod_inventario)) > 0)
) ENGINE=InnoDB;

CREATE TABLE Prestamos (
    id_prestamo INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_lector INT NOT NULL,
    id_admin INT NOT NULL,
    fecha_prestamo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_lector) REFERENCES Lectores(id_lector),
    FOREIGN KEY (id_admin) REFERENCES Admins(id_admin)
) ENGINE=InnoDB;

CREATE TABLE Detalle_Prestamo (
    id_detalle INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_prestamo INT NOT NULL,
    id_ejemplar INT NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    fecha_devolucion DATETIME NULL,
    id_admin_devolucion INT NULL,
    observaciones TEXT NULL,
    ejemplar_pendiente INT GENERATED ALWAYS AS (CASE WHEN fecha_devolucion IS NULL THEN id_ejemplar ELSE NULL END) STORED UNIQUE,
    FOREIGN KEY (id_prestamo) REFERENCES Prestamos(id_prestamo),
    FOREIGN KEY (id_ejemplar) REFERENCES Ejemplares(id_ejemplar),
    FOREIGN KEY (id_admin_devolucion) REFERENCES Admins(id_admin),
    UNIQUE KEY uq_prestamo_ejemplar (id_prestamo,id_ejemplar),
    CHECK ((fecha_devolucion IS NULL AND id_admin_devolucion IS NULL) OR (fecha_devolucion IS NOT NULL AND id_admin_devolucion IS NOT NULL))
) ENGINE=InnoDB;

-- Una única ocupación pendiente por ejemplar se garantiza con columna generada UNIQUE.
CREATE VIEW Vista_Disponibilidad AS
SELECT e.id_ejemplar, e.id_libro, e.cod_inventario, e.estado,
       CASE WHEN EXISTS (SELECT 1 FROM Detalle_Prestamo d WHERE d.id_ejemplar=e.id_ejemplar AND d.fecha_devolucion IS NULL)
            THEN 'prestado'
            WHEN e.estado='habilitado' AND l.activo=1 THEN 'disponible'
            ELSE 'fuera de servicio' END AS disponibilidad
FROM Ejemplares e JOIN Libros l ON l.id_libro=e.id_libro;

-- Los subtipos usan FKs compuestas: un lector no puede ser alumno y docente a la vez.
-- La creación futura de usuarios/perfiles y préstamos/detalles se hará en transacciones.
-- MySQL no tiene restricciones diferidas: la existencia de un subtipo y de al menos
-- un detalle/autor se validará por el servicio al confirmar cada transacción.

START TRANSACTION;
INSERT INTO Roles VALUES (1,'Administrador'),(2,'Lector');


INSERT INTO Usuarios (id_usuario,id_rol,nombre,correo_institucional,password_hash,activo) VALUES
(1,1,'Administración Demo','admin@biblioapp.test','$2y$12$u9FVJFgS34e5Otmht/h1r.tslKnDKtOTZleq79EYXeaYiI.NVopFK',1),
(2,2,'Alumno Demo','alumno@biblioapp.test','$2y$12$u9FVJFgS34e5Otmht/h1r.tslKnDKtOTZleq79EYXeaYiI.NVopFK',1),
(3,2,'Docente Demo','docente@biblioapp.test','$2y$12$u9FVJFgS34e5Otmht/h1r.tslKnDKtOTZleq79EYXeaYiI.NVopFK',1),
(4,2,'Lector Inactivo Demo','inactivo@biblioapp.test','$2y$12$u9FVJFgS34e5Otmht/h1r.tslKnDKtOTZleq79EYXeaYiI.NVopFK',0),
(5,1,'Administración Auxiliar Demo','auxiliar@biblioapp.test','$2y$12$u9FVJFgS34e5Otmht/h1r.tslKnDKtOTZleq79EYXeaYiI.NVopFK',1),
(6,2,'Alumna Sin Préstamos Demo','sinprestamos@biblioapp.test','$2y$12$u9FVJFgS34e5Otmht/h1r.tslKnDKtOTZleq79EYXeaYiI.NVopFK',1);

INSERT INTO Admins (id_admin,id_usuario) VALUES (1,1),(2,5);
INSERT INTO Lectores (id_lector,id_usuario,tipo) VALUES (1,2,'Alumno'),(2,3,'Docente'),(3,4,'Alumno'),(4,6,'Alumno');
INSERT INTO Alumnos (id_lector,matricula,carrera,semestre) VALUES
(1,'DEMO-A001','Ingeniería en Sistemas Computacionales',5),
(3,'DEMO-A002','Ingeniería Industrial',3),(4,'DEMO-A003','Administración',1);
INSERT INTO Docentes (id_lector,numero_empleado,departamento) VALUES (2,'DEMO-D001','Sistemas y Computación');
INSERT INTO Editoriales VALUES (1,'Editorial Académica Demo'),(2,'Letras del Norte Demo'),(3,'Ciencia Abierta Demo');
INSERT INTO Categorias VALUES (1,'Informática'),(2,'Literatura'),(3,'Matemáticas');
INSERT INTO Autores VALUES (1,'Ana Torres Demo'),(2,'Luis Pérez Demo'),(3,'Elena Gómez Demo'),(4,'Carlos Ríos Demo');
INSERT INTO Libros VALUES
(1,1,1,'Fundamentos de bases de datos','9780000000002',2024,'Primera',1),
(2,1,1,'Programación web con PHP','9780000000019',2025,'Segunda',1),
(3,2,2,'Relatos de la biblioteca','9780000000026',2022,'Primera',1),
(4,3,3,'Álgebra para ingeniería','9780000000033',2023,'Tercera',1),
(5,3,1,'Redes y sistemas','9780000000040',2020,'Primera',0);
INSERT INTO Libro_Autor VALUES (1,1),(1,2),(2,1),(3,3),(4,4),(5,2);
INSERT INTO Ubicaciones VALUES (1,'A-01','Informática, estante 1'),(2,'B-01','Literatura, estante 1'),(3,'C-01','Matemáticas, estante 1');
INSERT INTO Ejemplares VALUES
(1,1,1,'INV-001','habilitado'),(2,1,1,'INV-002','habilitado'),
(3,2,1,'INV-003','habilitado'),(4,2,1,'INV-004','mantenimiento'),
(5,3,2,'INV-005','habilitado'),(6,3,2,'INV-006','baja'),
(7,4,3,'INV-007','habilitado'),(8,4,3,'INV-008','habilitado'),
(9,5,1,'INV-009','habilitado'),(10,2,1,'INV-010','habilitado');
INSERT INTO Prestamos VALUES
(1,1,1,DATE_SUB(NOW(),INTERVAL 10 DAY)),
(2,2,2,DATE_SUB(NOW(),INTERVAL 3 DAY)),
(3,1,1,DATE_SUB(NOW(),INTERVAL 25 DAY));
INSERT INTO Detalle_Prestamo (id_detalle,id_prestamo,id_ejemplar,fecha_vencimiento,fecha_devolucion,id_admin_devolucion,observaciones) VALUES
(1,1,1,DATE_SUB(CURRENT_DATE(),INTERVAL 3 DAY),NULL,NULL,'Pendiente vencido de prueba'),
(2,1,5,DATE_ADD(CURRENT_DATE(),INTERVAL 4 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY),1,'Devolución parcial de prueba'),
(3,2,3,DATE_ADD(CURRENT_DATE(),INTERVAL 5 DAY),NULL,NULL,'Pendiente vigente de prueba'),
(4,3,7,DATE_SUB(CURRENT_DATE(),INTERVAL 15 DAY),DATE_SUB(NOW(),INTERVAL 16 DAY),2,'Préstamo concluido de prueba');
COMMIT;
-- Comprobación: 15 tablas base, 6 usuarios, 10 ejemplares, 2 detalles pendientes.
SELECT COUNT(*) AS tablas FROM information_schema.tables WHERE table_schema='biblioapp' AND table_type='BASE TABLE';
SELECT disponibilidad,COUNT(*) AS total FROM Vista_Disponibilidad GROUP BY disponibilidad;
