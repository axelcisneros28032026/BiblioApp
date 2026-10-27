<?php

require_once dirname(__DIR__) . '/vendor/autoload.php';

$dotenv = Dotenv\Dotenv::createImmutable(dirname(__DIR__));
$dotenv->safeLoad();

class Conexion
{
    private static ?PDO $conexion = null;

    public static function conectar(): PDO
    {
        if (self::$conexion !== null) {
            return self::$conexion;
        }

        $host = $_ENV['DB_HOST'] ?? 'localhost';
        $puerto = $_ENV['DB_PORT'] ?? '3306';
        $base = $_ENV['DB_NAME'] ?? '';
        $usuario = $_ENV['DB_USER'] ?? '';
        $clave = $_ENV['DB_PASSWORD'] ?? '';

        if ($base === '' || $usuario === '') {
            throw new RuntimeException(
                'Faltan parámetros de conexión en el archivo .env.'
            );
        }

        $dsn = "mysql:host=$host;port=$puerto;dbname=$base;charset=utf8mb4";

        self::$conexion = new PDO(
            $dsn,
            $usuario,
            $clave,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false
            ]
        );

        return self::$conexion;
    }
}