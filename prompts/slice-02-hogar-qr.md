# Slice 2 — Hogar e invitación por QR

**Objetivo:** el admin crea el hogar, muestra un QR y otra persona se une escaneándolo.

**Lee primero:** `docs/02_reglas_negocio.md` §9 y §10, `docs/03_modelo_datos.md` (hogares, miembros, invitaciones), `docs/04_seguridad_y_functions.md` (crearHogar, generarInvitacion, unirseConCodigo, sacarMiembro).

## Construye
1. Functions: `crearHogar`, `generarInvitacion`, `unirseConCodigo`, `sacarMiembro` con validaciones y transacciones.
2. Pantalla "Crea o únete": [Crear hogar] (nombre) · [Escanear QR] (cámara, paquete `mobile_scanner`).
3. Admin: pantalla Miembros y QR — lista de miembros, botón "Invitar" que muestra el QR (`qr_flutter`) con cuenta regresiva de 4 h, botón "Generar nuevo" y "Sacar" por miembro (con confirmación).
4. Deep link `patodonald://unirse?h=..&c=..` también funciona si se abre el link.
5. Sin internet: botones de crear, invitar, unirse y sacar muestran "Necesitas internet para esto".
6. Rules: lectura de `hogares/{h}/**` solo para miembros activos. Tests.
7. Paso siguiente tras crear o unirse: pantalla "Tu presupuesto y tu período" (monto + día de inicio 1–28). Guardar en `usuarios.diaInicioPeriodo` y `presupuestos/{uid}_{periodoId}`. Usa `core/periodo.dart` (créalo aquí con sus tests, ver §1).

## Fuera de alcance
Movimientos, home real.

## Listo cuando
- Dos teléfonos quedan en el mismo hogar escaneando el QR.
- QR vencido (+4 h) o reemplazado → error claro (test de Function con reloj simulado).
- Usuario que ya tiene hogar y escanea otro → "Ya perteneces a un hogar".
- Miembro sacado pierde acceso de inmediato (test de rules).
- Tests de `periodoDe` con D = 1, 15, 28, cruce de año y febrero bisiesto.
