
<?php

require_once dirname(__DIR__, 2) . '/config/conexion.php';

class AuthController
{
    public static function login(string $correo, string $password): bool
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }

        $sql = "SELECT
                    u.id_usuario,
                    u.nombre,
                    u.correo_institucional,
                    u.password_hash,
                    r.nombre AS rol
                FROM Usuarios u
                INNER JOIN Roles r ON r.id_rol = u.id_rol
                WHERE u.correo_institucional = :correo
                  AND u.activo = 1
                LIMIT 1";

        $conexion = Conexion::conectar();
        $consulta = $conexion->prepare($sql);
        $consulta->execute(['correo' => $correo]);

        $usuario = $consulta->fetch();

        if (!$usuario || !password_verify($password, $usuario['password_hash'])) {
            return false;
        }

        session_regenerate_id(true);

        $_SESSION['id_usuario'] = $usuario['id_usuario'];
        $_SESSION['nombre'] = $usuario['nombre'];
        $_SESSION['correo'] = $usuario['correo_institucional'];
        $_SESSION['rol'] = $usuario['rol'];

        return true;
    }
}

