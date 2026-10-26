<?php
declare(strict_types=1);

function pageStart(string $title, ?array $user = null): void
{ ?>
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= e($title) ?> · BiblioApp</title><link rel="stylesheet" href="/assets/app.css"></head><body>
<header><a class="brand" href="/">B<span>iblio</span>App</a><span class="edition">Biblioteca académica · Avance 01</span>
<?php if ($user): ?><form action="/logout.php" method="post"><input type="hidden" name="csrf" value="<?= e($_SESSION['csrf']) ?>"><button class="secondary">Cerrar sesión</button></form><?php endif ?></header>
<main><?php if ($user): ?><p class="eyebrow"><?= e($user['rol'] === 'Administrador' ? 'Administración' : 'Portal del lector') ?></p>
<h1><?= e($title) ?></h1><p class="welcome">Hola, <?= e($user['nombre']) ?>. Bienvenido a tu biblioteca.</p><?php endif ?>
<?php }

function pageEnd(): void
{ ?>
</main><footer>BiblioApp · Primer avance · PHP + MySQL</footer></body></html>
<?php }

function readerPage(string $profile): void
{
    $user = Auth::requireProfile($profile);
    $q = Database::connection()->prepare(
        'SELECT p.id_prestamo, p.fecha_prestamo, li.titulo, ej.cod_inventario,
                dp.fecha_vencimiento, dp.fecha_devolucion,
                (dp.fecha_devolucion IS NULL AND dp.fecha_vencimiento < CURRENT_DATE()) AS vencido
         FROM Prestamos p JOIN Detalle_Prestamo dp ON dp.id_prestamo = p.id_prestamo
         JOIN Ejemplares ej ON ej.id_ejemplar = dp.id_ejemplar
         JOIN Libros li ON li.id_libro = ej.id_libro
         WHERE p.id_lector = :lector ORDER BY p.fecha_prestamo DESC, dp.id_detalle DESC'
    );
    $q->execute(['lector' => $user['id_lector']]);
    $loans = $q->fetchAll();
    pageStart('Panel de ' . strtolower($profile), $user);
    ?>
    <section class="grid two"><article class="card"><p class="eyebrow">Mi perfil · <?= e($profile) ?></p>
    <h2><?= e($user['nombre']) ?></h2><dl><dt>Correo institucional</dt><dd><?= e($user['correo_institucional']) ?></dd>
    <?php if ($profile === 'Alumno'): ?>
    <dt>Matrícula</dt><dd><?= e($user['matricula']) ?></dd><dt>Carrera</dt><dd><?= e($user['carrera']) ?></dd><dt>Semestre</dt><dd><?= e($user['semestre']) ?></dd>
    <?php else: ?><dt>Número de empleado</dt><dd><?= e($user['numero_empleado']) ?></dd><dt>Departamento</dt><dd><?= e($user['departamento']) ?></dd><?php endif ?>
    </dl></article><article class="card accent"><p class="eyebrow">Tu actividad</p><h2>Mis préstamos</h2>
    <p class="number"><?= count(array_filter($loans, fn($r) => $r['fecha_devolucion'] === null)) ?></p><p>Ejemplares pendientes de devolución</p>
    <p>Los préstamos y devoluciones se registran presencialmente con el personal de biblioteca.</p></article></section>
    <section class="card"><h2>Préstamos e historial personal</h2><div class="table-wrap"><table><thead><tr><th>Folio</th><th>Libro / ejemplar</th><th>Préstamo</th><th>Vencimiento</th><th>Devolución / estado</th></tr></thead><tbody>
    <?php foreach ($loans as $loan): ?><tr><td>#<?= e($loan['id_prestamo']) ?></td><td><?= e($loan['titulo']) ?><small><?= e($loan['cod_inventario']) ?></small></td><td><?= e($loan['fecha_prestamo']) ?></td><td><?= e($loan['fecha_vencimiento']) ?></td><td><?= e($loan['fecha_devolucion'] ?? ($loan['vencido'] ? 'Vencido pendiente' : 'Pendiente')) ?></td></tr><?php endforeach ?>
    <?php if (!$loans): ?><tr><td colspan="5">Aún no tienes préstamos registrados.</td></tr><?php endif ?>
    </tbody></table></div></section>
    <?php pageEnd();
}
