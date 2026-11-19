# Slice 6 — Deudas entre miembros

**Objetivo:** "Juan le debe a María" queda claro, aceptado por los dos y con pagos confirmados.

**Lee primero:** `docs/02_reglas_negocio.md` §8; `docs/03_modelo_datos.md` (deudasInternas, pagos); `docs/04_seguridad_y_functions.md` (`confirmarPagoInterno`).

## Construye
1. Pestaña Deudas → sección "Entre nosotros": "Me deben" / "Debo", con saldo y estado.
2. Crear (acreedor): deudor, monto, concepto → `pendiente`.
3. Deudor: aceptar o rechazar.
4. Deudor: registrar pago (`confirmado: false`). Acreedor: confirmar → Function baja saldo; en 0 → `pagada`.
5. Notificaciones dentro de la app para cada paso (push en slice 9).
6. Rules + tests (quién puede qué en cada estado).

## Listo cuando
- Flujo completo María crea → Juan acepta → Juan paga 2 veces → María confirma → saldo 0, `pagada`.
- Un tercer miembro no puede aceptar ni confirmar (test).
- Nada de esto cambia el gastado ni el semáforo de nadie (test).
