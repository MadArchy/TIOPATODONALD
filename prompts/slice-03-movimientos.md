# Slice 3 — Movimientos

**Objetivo:** registrar gastos e ingresos en 3 toques, con foto opcional, también sin internet.

**Lee primero:** `docs/02_reglas_negocio.md` §3, §4, §5, §10; `docs/03_modelo_datos.md` (movimientos, gastosFijos); `.agents/rules/flutter.md`.

## Construye
1. Botón flotante "+" en el Inicio → hoja "Nuevo": selector Gasto / Ingreso, teclado de monto grande, cuadrícula de categorías con íconos, [Guardar]. Fecha (hoy por defecto, solo dentro del período), nota y foto en "Más opciones".
2. Foto: cámara o galería, compresión ~300 KB (`flutter_image_compress`), subida a Storage; si no hay red, cola local (guardar archivo en disco + reintentar al reconectar) y `fotoPath` se completa después.
3. Historial: lista del período con filtros "Míos / Del hogar", por categoría; tarjeta muestra quién, monto, categoría, fecha, ícono de foto. Navegar a períodos anteriores en solo lectura.
4. Gastos fijos: CRUD en Perfil → "Mis gastos fijos". Tarjeta en el Inicio el día esperado: "¿Registrar arriendo $1.200.000?" → un toque crea el movimiento con `gastoFijoId` y `origen: gastoFijo`.
5. Rules de `movimientos` (create, update de edición menor, delete false) + Storage rules. Tests de cada condición.
6. Edición menor: en el detalle de un movimiento propio con < 24 h, permitir cambiar nota y categoría (gasto→gasto). Function `alEditarMovimiento` escribe auditoría.

## Fuera de alcance
Pago de cuota (slice 5), correcciones con admin (slice 7).

## Listo cuando
- En modo avión: registrar 3 gastos con foto → aparecen en el historial → al reconectar se sincronizan y las fotos suben.
- Registrar con fecha de otro período o a nombre de otro usuario → rechazado por rules (test).
- Borrar un movimiento → imposible (test).
- Editar la nota a las 25 h → rechazado (test con reloj).
- Una persona de la familia registra un gasto en menos de 10 segundos.
