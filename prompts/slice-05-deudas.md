# Slice 5 — Deudas externas y pago de cuota

**Objetivo:** el admin registra las deudas del hogar; cualquiera registra un pago de cuota y el saldo baja solo.

**Lee primero:** `docs/02_reglas_negocio.md` §2 (cuotas), §7; `docs/03_modelo_datos.md` (deudas, movimientos.deudaId); `docs/04_seguridad_y_functions.md` (`alCrearMovimiento`).

## Construye
1. Pestaña Deudas: lista de deudas activas con entidad, saldo, cuota, próxima fecha de pago, barra de avance (pagado / inicial).
2. Admin: crear, editar (sin tocar `saldoActual`), desactivar. Requiere internet.
3. En "Nuevo": tercer tipo **Pago de cuota** → elegir deuda → monto prellenado con la cuota (editable).
4. Trigger `alCrearMovimiento`: si `pagoCuota`, transacción que baja `saldoActual`, marca `saldoAplicado`, y si llega a 0 pone `estado: pagada`. Idempotente.
5. Inicio: "Cuotas comprometidas $X" y lista de "Próximos pagos". Admin: cuotas pendientes en el margen real.
6. Rules + tests.

## Listo cuando
- Un pago de cuota registrado offline baja el saldo al reconectar.
- El trigger ejecutado dos veces no baja el saldo dos veces (test).
- Un miembro no admin no puede crear ni editar deudas (test).
- El pago de cuota suma en gastado del que lo registró.
