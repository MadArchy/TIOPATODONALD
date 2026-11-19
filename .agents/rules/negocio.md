# Reglas de lógica de negocio

Resumen operativo. La especificación completa está en `docs/02_reglas_negocio.md`; si hay duda, esa gana.

- Período: el usuario elige `diaInicioPeriodo` entre 1 y 28. Período = del día D de un mes al día D−1 del mes siguiente, en America/Bogota. `periodoId` = fecha de inicio `YYYY-MM-DD`. Cambiar D aplica desde el siguiente período (`diaInicioPendiente`).
- Gastado = suma de movimientos `gasto` + `pagoCuota` con `estado == activo` del usuario en su período.
- Semáforo: verde si gastado ≤ presupuesto; rojo si gastado > presupuesto.
- Disponible = presupuesto − gastado. Disponible por día = max(0, disponible) ÷ días restantes (contando hoy).
- Proyección = gastado ÷ días transcurridos × días del período; mostrar desde el día 3.
- Alertas al 50, 80 y 100% del presupuesto, una vez cada una por período.
- Pago de cuota: tipo propio con `deudaId`; cuenta en gastado y baja el saldo de la deuda (lo hace una Function).
- Deudas entre miembros: no cuentan como gasto ni ingreso.
- Edición menor sin admin: solo `nota`, o `categoria` entre categorías de gasto; solo el autor; solo < 24 h desde `creadoEn`; solo período vigente.
- Corrección con admin: plazo = período vigente del dueño del movimiento + 5 días.
- Toda lógica de esta lista vive en funciones puras con tests unitarios, incluidos los bordes: día 28, cambio de mes, febrero, años bisiestos, medianoche en Bogotá.
