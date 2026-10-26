<?php
declare(strict_types=1);

final class Auth
{
    public static function find(int|string $value, bool $byId = false): array|false
    {
        $field = $byId ? 'u.id_usuario' : 'u.correo_institucional';
        $query = Database::connection()->prepare(
            "SELECT u.*, r.nombre AS rol, a.id_admin, l.id_lector,
                    al.matricula, al.carrera, al.semestre, d.numero_empleado, d.departamento,
                    CASE WHEN al.id_lector IS NOT NULL AND d.id_lector IS NULL THEN 'Alumno'
                         WHEN d.id_lector IS NOT NULL AND al.id_lector IS NULL THEN 'Docente'
                         ELSE NULL END AS perfil
             FROM Usuarios u JOIN Roles r ON r.id_rol = u.id_rol
             LEFT JOIN Admins a ON a.id_usuario = u.id_usuario
             LEFT JOIN Lectores l ON l.id_usuario = u.id_usuario
             LEFT JOIN Alumnos al ON al.id_lector = l.id_lector
             LEFT JOIN Docentes d ON d.id_lector = l.id_lector
             WHERE {$field} = :value LIMIT 1"
        );
        $query->execute(['value' => $value]);
        return $query->fetch();
    }

    private static function valid(array|false $user): bool
    {
        return $user && (int)$user['activo'] === 1 && (
            ($user['rol'] === 'Administrador' && $user['id_admin'] && !$user['id_lector']) ||
            ($user['rol'] === 'Lector' && !$user['id_admin'] && $user['id_lector'] && $user['perfil'])
        );
    }

    public static function login(string $email, string $password): bool
    {
        $user = self::find($email);
        // Hash de relleno para verificar también cuando el correo no existe.
        $hash = $user['password_hash'] ?? '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.';
        $passwordOk = password_verify($password, $hash);
        if (!$passwordOk || !self::valid($user)) {
            return false;
        }
        session_regenerate_id(true);
        $_SESSION['user_id'] = (int)$user['id_usuario'];
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
        return true;
    }

    public static function current(): array|false
    {
        if (!isset($_SESSION['user_id'])) {
            return false;
        }
        $user = self::find((int)$_SESSION['user_id'], true);
        if (!self::valid($user)) {
            unset($_SESSION['user_id']);
            return false;
        }
        return $user;
    }

    public static function home(array $user): string
    {
        return $user['rol'] === 'Administrador' ? '/admin.php'
            : ($user['perfil'] === 'Alumno' ? '/alumno.php' : '/docente.php');
    }

    public static function requireProfile(string $profile): array
    {
        $user = self::current();
        if (!$user) {
            header('Location: /index.php');
            exit;
        }
        $actual = $user['rol'] === 'Administrador' ? 'Administrador' : $user['perfil'];
        if ($actual !== $profile) {
            http_response_code(403);
            exit('Acceso no autorizado para este perfil.');
        }
        return $user;
    }

    public static function logout(): void
    {
        $_SESSION = [];
        $params = session_get_cookie_params();
        setcookie(session_name(), '', [
            'expires' => time() - 42000, 'path' => $params['path'],
            'secure' => $params['secure'], 'httponly' => true, 'samesite' => 'Lax'
        ]);
        session_destroy();
    }
}
