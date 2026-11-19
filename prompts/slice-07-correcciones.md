# Slice 7 — Correcciones y auditoría

**Objetivo:** cualquier error se corrige con transparencia: se pide, el admin decide, queda rastro.

**Lee primero:** `docs/02_reglas_negocio.md` §6; `docs/03_modelo_datos.md` (correcciones, auditoria); `docs/04_seguridad_y_functions.md` (`resolverCorreccion`).

## Construye
1. En el detalle de cualquier movimiento del hogar (dentro de plazo): "Pedir corrección" → elegir qué cambiar (monto, fecha, categoría, anular, reclasificar a pago de cuota + deuda) + motivo obligatorio.
2. Admin → Correcciones: bandeja de pendientes con antes/después lado a lado; [Aprobar] / [Rechazar con motivo]. Contador en el ícono.
3. `resolverCorreccion`: valida plazo, aplica cambios en transacción, ajusta saldo de deuda si hay reclasificación (en ambos sentidos), escribe auditoría, notifica al solicitante y al dueño. Si el admin corrige lo suyo: auditoría `correccionAdminPropia` + aviso a todos.
4. En el detalle del movimiento: "Historial de cambios" leído de `auditoria`.
5. Rules + tests.

## Listo cuando
- Una corrección aprobada cambia el monto, el home se recalcula y el historial muestra antes/después, quién pidió y quién aprobó.
- Reclasificar un gasto a pago de cuota baja el saldo de la deuda; deshacerlo lo devuelve (test).
- Pedir corrección fuera de plazo → rechazado (test con reloj).
- Un miembro no puede aprobar (test).
