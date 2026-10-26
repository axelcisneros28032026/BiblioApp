# Validación del primer avance

Fecha: 26 de octubre de 2026. Entorno local: Windows, PHP 8.4.27 con PDO MySQL y MySQL Community Server 8.0.46.

Se utilizó una instancia MySQL aislada en `127.0.0.1:3307` con datos propios del proyecto. No se utilizó Sakila ni se modificó la instancia habitual del equipo. El servidor PHP de demostración se ejecutó en `127.0.0.1:8087`, con `codigo/public` como raíz pública. La conexión de aplicación utilizó un usuario limitado a SELECT.

## Resultados

| Validación | Resultado |
| --- | --- |
| Sintaxis de los 9 archivos PHP (`php -l`) | Correcta. |
| Importación del script final en una base nueva de MySQL | Correcta; 15 tablas base y una vista. |
| Datos base y cálculo de disponibilidad | 10 ejemplares: 5 disponibles, 2 prestados y 3 fuera de servicio; 1 detalle vencido pendiente al importar. |
| `python codigo/tests/http_smoke.py` | 70 comprobaciones correctas. |
| Login real: administrador, alumno y docente | Redirección a su panel y datos de MySQL. |
| Cuenta de alumno sin préstamos | Muestra perfil y estado vacío. |
| Contraseña incorrecta, correo inexistente e inactivo | Acceso rechazado sin crear sesión. |
| Campos vacíos y entrada con sintaxis de inyección | Acceso rechazado. |
| Paneles sin sesión y acceso a perfil ajeno | Redirección al login y 403, respectivamente. |
| Historial de alumno y docente | Aislamiento de registros por el lector autenticado. |
| Parámetro `id_lector` ajeno en URL | No cambia el historial consultado. |
| Logout por GET / POST sin CSRF / POST válido | 405 / 403 / sesión destruida. |
| Archivos privados solicitados por HTTP | 404; configuración y SQL fuera de la raíz pública. |
| Credenciales y `.env` en archivos públicos del repositorio | Solo plantilla y datos ficticios; configuración local excluida. |

También se verificaron con transacciones reversibles las siguientes restricciones directamente en MySQL:

| Operación inválida | Rechazo esperado y obtenido |
| --- | --- |
| Correo institucional duplicado | UNIQUE, error 1062. |
| Perfil de administrador asociado a usuario lector | FK compuesta, error 1452. |
| Asociar docente al mismo lector de tipo alumno | FK compuesta, error 1452. |
| Semestre igual a cero | CHECK, error 3819. |
| Segundo detalle pendiente para el mismo ejemplar | Índice único sobre columna generada, error 1062. |
| Fecha de devolución sin administrador receptor | CHECK, error 3819. |
| Borrar editorial con libros | FK, error 1451. |
| ISBN explícitamente vacío | CHECK, error 3819. |
| Estado de ejemplar fuera de catálogo | ENUM en modo estricto, error 1265. |

## Límites de esta evidencia

Los módulos de altas, cambios, préstamos, devoluciones y reportes PDF completos se encuentran especificados para avances posteriores; no se declaran implementados ni probados aquí. No se ha grabado el video narrado y no existe enlace YouTube. Esta evidencia técnica no sustituye ese entregable ni demuestra por sí misma una participación equitativa de los integrantes.
