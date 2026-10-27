
<?php

session_start();

require_once dirname(__DIR__) . '/app/controllers/AuthController.php';

$error = '';
$pagina = $_GET['pagina'] ?? '';

// Cerrar sesión antes de validar el acceso a los paneles.
if ($pagina === 'cerrar') {
    $_SESSION = [];

    if (ini_get('session.use_cookies')) {
        $parametros = session_get_cookie_params();

        setcookie(
            session_name(),
            '',
            time() - 42000,
            $parametros['path'],
            $parametros['domain'],
            $parametros['secure'],
            $parametros['httponly']
        );
    }

    session_destroy();

    header('Location: index.php');
    exit;
}

// Procesar el formulario de inicio de sesión.
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $correo = trim($_POST['correo'] ?? '');
    $password = $_POST['password'] ?? '';

    if ($correo !== '' && $password !== '') {
        try {
            if (AuthController::login($correo, $password)) {
                switch ($_SESSION['rol']) {
                    case 'Administrador':
                        header('Location: index.php?pagina=admin');
                        exit;

                    case 'Alumno':
                        header('Location: index.php?pagina=alumno');
                        exit;

                    case 'Docente':
                        header('Location: index.php?pagina=docente');
                        exit;

                    default:
                        $_SESSION = [];
                        session_destroy();
                        $error = 'El rol de usuario no es válido.';
                }
            } else {
                $error = 'Correo o contraseña incorrectos.';
            }
        } catch (Throwable $e) {
            error_log($e->getMessage());
            $error = 'No fue posible iniciar sesión. Intenta más tarde.';
        }
    } else {
        $error = 'Ingresa tu correo y contraseña.';
    }
}

// Mostrar el panel correspondiente al usuario autenticado.
if (isset($_SESSION['id_usuario'])) {
    $rol = $_SESSION['rol'] ?? '';

    $paginasPermitidas = [
        'Administrador' => 'admin',
        'Alumno' => 'alumno',
        'Docente' => 'docente'
    ];

    // Si no se especifica página, mostrar el panel de su rol.
    if ($pagina === '') {
        if (isset($paginasPermitidas[$rol])) {
            header('Location: index.php?pagina=' . $paginasPermitidas[$rol]);
            exit;
        }
    }

    // Impedir que un usuario acceda al panel de otro rol.
    if (
        isset($paginasPermitidas[$rol]) &&
        $paginasPermitidas[$rol] === $pagina
    ) {
        $nombre = htmlspecialchars(
            $_SESSION['nombre'] ?? 'Usuario',
            ENT_QUOTES,
            'UTF-8'
        );

        $rolSeguro = htmlspecialchars($rol, ENT_QUOTES, 'UTF-8');
        ?>
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>BiblioApp - Panel</title>
            <link rel="stylesheet" href="assets/css/estilos.css">
        </head>
        <body>
            <main class="contenedor">
                <h1>BiblioApp</h1>

                <h2>Bienvenido, <?= $nombre ?></h2>

                <p>Tu rol es: <?= $rolSeguro ?></p>

                <?php if ($rol === 'Administrador'): ?>
                    <h3>Panel de Administrador</h3>
                    <p>Desde aquí podrás gestionar los usuarios,
                       libros y préstamos de la biblioteca.</p>

                <?php elseif ($rol === 'Alumno'): ?>
                    <h3>Panel de Alumno</h3>
                    <p>Desde aquí podrás consultar el catálogo
                       y revisar tus préstamos.</p>

                <?php elseif ($rol === 'Docente'): ?>
                    <h3>Panel de Docente</h3>
                    <p>Desde aquí podrás consultar el catálogo
                       y revisar tus préstamos.</p>
                <?php endif; ?>

                <a href="index.php?pagina=cerrar">Cerrar sesión</a>
            </main>
        </body>
        </html>
        <?php
        exit;
    }

    http_response_code(403);
    exit('No tienes permiso para acceder a este panel.');
}

// Si alguien solicita un panel sin iniciar sesión, mostrar el login.
if (in_array($pagina, ['admin', 'alumno', 'docente'], true)) {
    header('Location: index.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BiblioApp - Iniciar sesión</title>
    <link rel="stylesheet" href="assets/css/estilos.css">
</head>
<body>
    <main class="contenedor">
        <h1>BiblioApp</h1>
        <h2>Iniciar sesión</h2>

        <?php if ($error !== ''): ?>
            <p class="error">
                <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?>
            </p>
        <?php endif; ?>

        <form method="POST" action="index.php">
            <label for="correo">Correo institucional</label>
            <input
                type="email"
                id="correo"
                name="correo"
                required
                autocomplete="username"
            >

            <label for="password">Contraseña</label>
            <input
                type="password"
                id="password"
                name="password"
                required
                autocomplete="current-password"
            >

            <button type="submit">Ingresar</button>
        </form>
    </main>
</body>
</html>

