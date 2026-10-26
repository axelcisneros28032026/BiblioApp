<?php
declare(strict_types=1);
require dirname(__DIR__) . '/src/bootstrap.php';
// El servidor integrado de PHP puede reenviar rutas inexistentes a index.php.
if (!in_array(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), ['/', '/index.php'], true)) {
    http_response_code(404);
    exit('Página no encontrada.');
}
if ($user = Auth::current()) {
    header('Location: ' . Auth::home($user));
    exit;
}
$error = '';
$email = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireCsrf();
    $email = is_string($_POST['email'] ?? null) ? trim($_POST['email']) : '';
    $password = is_string($_POST['password'] ?? null) ? $_POST['password'] : '';
    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 150 || $password === '' || strlen($password) > 72) {
        $error = 'Escribe un correo válido y una contraseña de hasta 72 bytes.';
    } elseif (Auth::login($email, $password)) {
        header('Location: ' . Auth::home(Auth::current()));
        exit;
    } else {
        $error = 'Credenciales incorrectas o cuenta no disponible.';
    }
}
pageStart('Iniciar sesión');
?>
<section class="login-layout"><div class="intro"><p class="eyebrow">Un catálogo. Toda tu biblioteca.</p><h1>Tu próxima<br>gran idea<br>empieza aquí.</h1><p>Consulta tus préstamos y encuentra tu lugar en la biblioteca académica.</p><div class="book-art" aria-hidden="true"><span>B</span><span>I</span><span>B</span><span>L</span><span>I</span><span>O</span></div></div>
<article class="card login"><p class="eyebrow">Bienvenido a BiblioApp</p><h2>Iniciar sesión</h2><p>Ingresa con la cuenta asignada por la biblioteca.</p>
<?php if ($error): ?><p class="alert" role="alert"><?= e($error) ?></p><?php endif ?>
<form method="post"><input type="hidden" name="csrf" value="<?= e($_SESSION['csrf']) ?>">
<label for="email">Correo institucional</label><input id="email" name="email" type="email" autocomplete="username" maxlength="150" value="<?= e($email) ?>" required>
<label for="password">Contraseña</label><input id="password" name="password" type="password" autocomplete="current-password" required>
<button class="primary">Entrar a mi biblioteca</button></form><p class="hint">El acceso se asigna automáticamente según tu rol. Para obtener una cuenta, acude al personal de biblioteca.</p></article></section>
<?php pageEnd();
