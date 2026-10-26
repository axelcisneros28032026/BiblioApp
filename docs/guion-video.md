# Guion del video — primer avance (máximo 10 minutos)

**Pendiente de grabar y subir a YouTube por el equipo.** Usar voz real de uno o varios integrantes.

1. **0:00–0:45 — Presentación.** Nombre BiblioApp, integrantes, objetivo y alcance: biblioteca académica con administrador y lectores de tipo alumno o docente.
2. **0:45–1:45 — Base real.** Mostrar MySQL y ejecutar `USE biblioapp; SHOW TABLES;` y `SELECT id_usuario, nombre, correo_institucional, activo FROM Usuarios;`. Explicar las 15 tablas y abrir el ER Mermaid en GitHub. No mostrar hashes ni credenciales.
3. **1:45–2:45 — Conexión.** Mostrar `codigo/config/Database.php`: configuración por `.env`, método independiente, PDO, utf8mb4 y consultas preparadas. No abrir `.env`; puede mostrarse `.env.example`.
4. **2:45–4:00 — Administrador.** Entrar con `admin@biblioapp.test`, mostrar indicadores y explicar que proceden de consultas a MySQL. Cerrar sesión.
5. **4:00–5:15 — Alumno.** Entrar con `alumno@biblioapp.test`; mostrar matrícula, carrera, semestre, préstamo vencido y devolución parcial. Intentar `/admin.php` y mostrar 403. Cerrar sesión.
6. **5:15–6:30 — Docente.** Entrar con `docente@biblioapp.test`; mostrar número de empleado, departamento y su préstamo vigente. Explicar por qué no ve los préstamos del alumno. Cerrar sesión.
7. **6:30–7:30 — Excepciones.** Contraseña incorrecta y `inactivo@biblioapp.test`: acceso rechazado. Visitar panel sin sesión: regreso al login. Opcional: cuenta `sinprestamos@biblioapp.test` muestra estado vacío.
8. **7:30–8:30 — Repositorio.** Mostrar `codigo/`, `.gitignore`, `biblioapp.sql`, criterios de aceptación en `readme.md` y resultados de pruebas. Distinguir lo implementado de los módulos futuros.
9. **8:30–9:00 — Cierre.** Mostrar historial y etiqueta `v0.1-avance1`. Explicar próximos pasos: gestión de catálogos, préstamos, devoluciones y PDF.

Publicar como público o no listado y verificar el acceso sin iniciar sesión. Añadir el enlace verdadero en la sección 8 de `readme.md`. Si el video se añade después de etiquetar, coordinar con el equipo la captura final; no reemplazar silenciosamente la etiqueta.
