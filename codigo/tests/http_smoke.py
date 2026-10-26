"""Pruebas de integración HTTP con MySQL real; no modifica datos de negocio."""
import argparse
import http.cookiejar
import re
import urllib.error
import urllib.parse
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument('--base', default='http://127.0.0.1:8087')
args = parser.parse_args()
base = args.base.rstrip('/')
checks = 0

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

def browser():
    return urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()), NoRedirect())

def request(client, path, data=None):
    body = urllib.parse.urlencode(data).encode() if data is not None else None
    try:
        result = client.open(base + path, data=body, timeout=10)
    except urllib.error.HTTPError as error:
        result = error
    return result.code, result.headers, result.read().decode('utf-8')

def check(condition, label):
    global checks
    if not condition:
        raise AssertionError(label)
    checks += 1
    print('OK:', label)

def token(html):
    return re.search(r'name="csrf" value="([a-f0-9]+)"', html).group(1)

def login(client, email, password='BibliotecaDemo2026!'):
    code, headers, html = request(client, '/index.php')
    check(code == 200, 'Formulario disponible')
    return request(client, '/index.php', {'csrf': token(html), 'email': email, 'password': password})

client = browser()
for path in ['/admin.php', '/alumno.php', '/docente.php']:
    code, headers, _ = request(client, path)
    check(code == 302 and headers['Location'] == '/index.php', 'Sin sesión: ' + path)
check(request(client, '/logout.php')[0] == 405, 'Logout rechaza GET')
check(request(client, '/index.php', {'email': 'admin@biblioapp.test', 'password': 'x'})[0] == 403, 'CSRF obligatorio')

for email, password in [('admin@biblioapp.test', 'incorrecta'),
                        ('inactivo@biblioapp.test', 'BibliotecaDemo2026!'),
                        ('noexiste@biblioapp.test', 'BibliotecaDemo2026!'),
                        ("' OR 1=1 --@biblioapp.test", 'x')]:
    client = browser()
    code, _, html = login(client, email, password)
    check(code == 200 and ('Credenciales incorrectas o cuenta no disponible.' in html or
                          'Escribe un correo válido' in html), 'Credenciales rechazadas: ' + email)
    check(request(client, '/admin.php')[0] == 302, 'Fallo no crea sesión')

client = browser()
_, _, html = request(client, '/')
check(request(client, '/', {'csrf': token(html), 'email': '', 'password': ''})[0] == 200, 'Campos vacíos no autentican')
check(request(client, '/admin.php')[0] == 302, 'Campos vacíos sin sesión')

profiles = [('admin', '/admin.php', 'Panel de administrador', 'Ejemplares disponibles'),
            ('alumno', '/alumno.php', 'Panel de alumno', 'DEMO-A001'),
            ('docente', '/docente.php', 'Panel de docente', 'DEMO-D001'),
            ('sinprestamos', '/alumno.php', 'Panel de alumno', 'Aún no tienes préstamos registrados.')]
for email, home, title, content in profiles:
    client = browser()
    code, headers, _ = login(client, email + '@biblioapp.test')
    check(code == 302 and headers['Location'] == home, 'Redirección de ' + email)
    code, headers, html = request(client, home)
    check(code == 200 and title in html and content in html, 'Panel MySQL de ' + email)
    check(headers.get('Cache-Control') == 'no-store', 'Panel sin caché')
    if email == 'alumno':
        check('INV-001' in html and 'INV-003' not in html, 'Alumno solo ve sus préstamos')
        check('Vencido pendiente' in html, 'Alumno ve atraso pendiente')
    if email == 'docente':
        check('INV-003' in html and 'INV-001' not in html, 'Docente solo ve sus préstamos')
    for other in ['/admin.php', '/alumno.php', '/docente.php']:
        if other != home:
            check(request(client, other)[0] == 403, email + ' no accede a ' + other)
    check(request(client, home + '?id_lector=999')[2] == html, 'No acepta lector por URL: ' + email)
    check(request(client, '/logout.php', {'csrf': 'invalido'})[0] == 403, 'Logout valida CSRF')
    check(request(client, home)[0] == 200, 'CSRF inválido no cierra sesión')
    check(request(client, '/logout.php', {'csrf': token(html)})[0] == 302, 'Logout correcto de ' + email)
    check(request(client, home)[0] == 302, 'Sesión cerrada de ' + email)

for path in ['/.env', '/config/Database.php', '/src/Auth.php', '/biblioapp.sql']:
    check(request(browser(), path)[0] == 404, 'Archivo privado fuera de raíz pública: ' + path)
print(f'COMPLETADO: {checks} comprobaciones correctas.')
