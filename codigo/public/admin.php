<?php
declare(strict_types=1);
require dirname(__DIR__) . '/src/bootstrap.php';
$user = Auth::requireProfile('Administrador');
$db = Database::connection();
$stats = $db->query(
    "SELECT SUM(disponibilidad = 'disponible') AS disponibles,
            SUM(disponibilidad = 'prestado') AS prestados,
            SUM(disponibilidad = 'fuera de servicio') AS fuera_servicio
     FROM Vista_Disponibilidad"
)->fetch();
$overdue = $db->query('SELECT COUNT(*) FROM Detalle_Prestamo WHERE fecha_devolucion IS NULL AND fecha_vencimiento < CURRENT_DATE()')->fetchColumn();
$users = $db->query('SELECT COUNT(*) FROM Usuarios WHERE activo = 1')->fetchColumn();
pageStart('Panel de administrador', $user);
?>
<section class="grid stats">
<?php foreach (['Ejemplares disponibles' => $stats['disponibles'], 'Ejemplares prestados' => $stats['prestados'], 'Vencidos pendientes' => $overdue, 'Fuera de servicio' => $stats['fuera_servicio']] as $label => $value): ?>
<article class="card"><p class="eyebrow"><?= e($label) ?></p><p class="number"><?= e($value ?? 0) ?></p></article><?php endforeach ?>
</section><section class="grid two"><article class="card accent"><p class="eyebrow">La biblioteca de un vistazo</p><h2>Información conectada</h2><p>Los indicadores se consultan directamente en MySQL en cada visita.</p><p><strong><?= e($users) ?></strong> cuentas activas en el sistema.</p></article>
<article class="card"><p class="eyebrow">Primer avance</p><h2>Autenticación y paneles</h2><p>Ya puedes iniciar y cerrar sesión con control de permisos y consultar indicadores.</p><p>La administración de usuarios, catálogo, préstamos, devoluciones y reportes PDF se implementará en los siguientes avances.</p></article></section>
<?php pageEnd();
