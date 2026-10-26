<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/config/Database.php';
require_once __DIR__ . '/Auth.php';
require_once __DIR__ . '/views.php';

ini_set('display_errors', '0');
ini_set('session.use_strict_mode', '1');
session_set_cookie_params([
    'httponly' => true, 'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    'samesite' => 'Lax', 'path' => '/'
]);
session_start();
header('Cache-Control: no-store');
header('X-Content-Type-Options: nosniff');
header("Content-Security-Policy: default-src 'self'; style-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'none'");
$_SESSION['csrf'] ??= bin2hex(random_bytes(32));

set_exception_handler(function (Throwable $error): void {
    // No exponer contraseñas, consultas SQL ni mensajes PDO al navegador o al log.
    error_log('BiblioApp: operación fallida (' . get_class($error) . ')');
    http_response_code(503);
    echo '<!doctype html><html lang="es"><meta charset="utf-8"><title>Servicio no disponible</title>';
    echo '<h1>Servicio temporalmente no disponible</h1><p>Verifica la configuración y disponibilidad de MySQL.</p></html>';
});

function e(mixed $value): string
{
    return htmlspecialchars((string)($value ?? ''), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function requireCsrf(): void
{
    $token = $_POST['csrf'] ?? null;
    if (!is_string($token) || !hash_equals($_SESSION['csrf'], $token)) {
        http_response_code(403);
        exit('Solicitud inválida. Recarga la página e inténtalo de nuevo.');
    }
}
