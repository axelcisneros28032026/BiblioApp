<?php
declare(strict_types=1);

/** Único punto de lectura de configuración y creación de conexiones PDO. */
final class Database
{
    public static function config(): array
    {
        $path = dirname(__DIR__) . '/.env';
        if (!is_file($path)) {
            throw new RuntimeException('Falta el archivo de configuración local.');
        }
        $config = parse_ini_file($path, false, INI_SCANNER_RAW);
        if ($config === false) {
            throw new RuntimeException('Configuración inválida.');
        }
        foreach (['DB_HOST', 'DB_PORT', 'DB_DATABASE', 'DB_USERNAME', 'DB_PASSWORD'] as $key) {
            if (!array_key_exists($key, $config)) {
                throw new RuntimeException('Configuración incompleta.');
            }
        }
        if (!ctype_digit((string)$config['DB_PORT']) ||
            !preg_match('/^[a-zA-Z0-9_]+$/', $config['DB_DATABASE']) ||
            !preg_match('/^[a-zA-Z0-9.:-]+$/', $config['DB_HOST'])) {
            throw new RuntimeException('Parámetros de conexión inválidos.');
        }
        return $config;
    }

    public static function connection(): PDO
    {
        static $connection = null;
        if ($connection === null) {
            $c = self::config();
            date_default_timezone_set($c['APP_TIMEZONE'] ?? 'America/Mexico_City');
            $connection = new PDO(
                "mysql:host={$c['DB_HOST']};port={$c['DB_PORT']};dbname={$c['DB_DATABASE']};charset=utf8mb4",
                $c['DB_USERNAME'], $c['DB_PASSWORD'],
                [PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci',
                 PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                 PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                 PDO::ATTR_EMULATE_PREPARES => false]
            );
        }
        return $connection;
    }
}
