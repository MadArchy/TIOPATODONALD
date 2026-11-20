# 02 — Reglas de negocio

Estas reglas son obligatorias. El código, las security rules y los tests deben cumplirlas.
Si algo no está aquí, pregunta antes de inventarlo.

## 1. Período

- Cada usuario tiene `diaInicioPeriodo` ∈ [1, 28]. Por defecto 1.
- Período = desde el día D de un mes (00:00 America/Bogota) hasta el día D−1 del mes siguiente (23:59:59.999).
  - D = 15 → 15 nov – 14 dic. D = 1 → mes calendario.
- `periodoId` = fecha de inicio en texto `YYYY-MM-DD`.
- Cambiar D: se guarda en `diaInicioPendiente` y nunca parte ni reabre el período actual. Al cerrar el período actual, si hoy aún no es el día D nuevo, corre un **período puente** desde el cierre hasta el día D nuevo (conservando el presupuesto vigente y aceptando offline el D anterior durante la transición); al llegar el día D nuevo (00:30 America/Bogota), el servidor cierra el puente, actualiza `diaInicioPeriodo = D nuevo`, limpia `diaInicioPendiente` y copia el presupuesto vigente al nuevo período si aún no existe.
- Funciones requeridas en `core/periodo.dart`:
  - `Periodo periodoDe(DateTime instante, int diaInicio)` → inicio, fin, `periodoId`, días totales
  - `int diasTranscurridos(Periodo p, DateTime hoy)` (cuenta hoy)
  - `int diasRestantes(Periodo p, DateTime hoy)` (cuenta hoy)

## 2. Presupuesto y semáforo

- Presupuesto = monto de gasto por período en COP, uno por usuario y período. Editable durante el período (queda en auditoría como `cambioPresupuesto`).
- Si no hay presupuesto del período: el home pide fijarlo; si existe el del período anterior, se propone el mismo monto.
- Indicadores (por usuario, en su período):

| Indicador | Fórmula |
| --- | --- |
| gastado | Σ monto de `gasto` + `pagoCuota` con `estado == activo` |
| ingresos | Σ monto de `ingreso` con `estado == activo` |
| disponible | presupuesto − gastado |
| disponiblePorDia | max(0, disponible) ÷ diasRestantes (redondeo hacia abajo a pesos) |
| proyeccion | gastado ÷ diasTranscurridos × diasPeriodo; solo si diasTranscurridos ≥ 3 |
| semaforo | verde si gastado ≤ presupuesto; rojo si no |
| avisoPreventivo | proyeccion > presupuesto y semaforo == verde |
| porcentajeReducible | Σ gastos en categorías reducibles ÷ gastado |

- Indicadores del hogar (admin):

| Indicador | Fórmula |
| --- | --- |
| cuotasComprometidas | Σ `cuotaMensual` de deudas externas con `estado == activa` |
| cuotasPendientes | Σ `cuotaMensual` de deudas activas sin `pagoCuota` en el período del admin |
| margenReal | ingresos del hogar − gastado del hogar − cuotasPendientes (período del admin; cada miembro aporta lo de su período vigente) |

- Ejemplo de prueba (debe estar en los tests): presupuesto 4.000.000, D = 15, hoy 2026-11-25, gastado 1.800.000 → diasPeriodo 30, transcurridos 11, restantes 20, disponible 2.200.000, disponiblePorDia 110.000, proyeccion 4.909.090, semáforo verde, avisoPreventivo true.
- Alertas: al cruzar 50%, 80% y 100% de gastado/presupuesto, una vez cada una por período (guardar en `presupuestos.alertasEnviadas`).

## 3. Categorías

| Gasto | Reducible |
| --- | --- |
| Alimentación | no |
| Servicios | no |
| Transporte | no |
| Vivienda | no |
| Salud | no |
| Educación | no |
| Ocio / caprichos | sí |
| Otros | sí |

Ingreso: Salario, Otros. Las categorías son constantes en el código (ids sin tildes: `alimentacion`, `servicios`, `transporte`, `vivienda`, `salud`, `educacion`, `ocio`, `otros`, `salario`, `otros_ingreso`).

## 4. Movimientos

- Tipos: `gasto`, `ingreso`, `pagoCuota`.
- `uid` = usuario autenticado; nadie registra por otro.
- Fecha dentro del período vigente de quien registra; no futura.
- `gasto` e `ingreso` llevan `categoria` de su lista; `pagoCuota` lleva `deudaId` y no lleva categoría.
- Monto entero > 0.
- Foto de recibo opcional, máximo 1, comprimida (~300 KB), en Storage `recibos/{hogarId}/{movimientoId}.jpg`.
- No se borran: se anulan por corrección (`estado: anulado`).
- Todos los miembros ven los movimientos del hogar en el historial (transparencia). Cada uno solo edita los suyos.

## 5. Gastos fijos

- Plantilla por usuario: nombre, monto, categoría, `diaEsperado`.
- En el home, cuando llega el día esperado y no hay movimiento ligado ese período: tarjeta "¿Registrar arriendo $1.200.000?" con un toque.
- Registrar desde plantilla crea un movimiento normal con `gastoFijoId`.

## 6. Ediciones menores y correcciones

| Cambio | Quién | Condición | Aprobación |
| --- | --- | --- | --- |
| Nota | Autor | < 24 h desde `creadoEn`, período vigente | No; auditoría `edicionMenor` |
| Categoría (gasto → gasto) | Autor | igual | No; auditoría `edicionMenor` |
| Monto, fecha, categoría de ingreso, anular, reclasificar a pago de cuota | Cualquier miembro solicita | Período vigente del dueño del movimiento + 5 días | Sí, admin |

- La solicitud lleva motivo obligatorio y el mapa de cambios propuestos.
- Admin aprueba → se actualiza el movimiento + auditoría (`antes`, `despues`, `porUid`, `aprobadoPor`).
- Admin rechaza → motivo de rechazo visible para quien pidió.
- Correcciones del admin sobre sus propios movimientos: se aplican y se notifica a todos los miembros.
- Reclasificar a `pagoCuota` baja el saldo de la deuda; reclasificar desde `pagoCuota` lo devuelve.

## 7. Deudas externas

- Solo el admin crea, edita, desactiva (requiere internet).
- Campos: entidad, saldoInicial, cuotaMensual, diaPago (1–31), numeroCuotas (opcional).
- Cualquier miembro registra `pagoCuota`; una Function baja `saldoActual`. En 0 → `estado: pagada`.
- Home muestra la próxima fecha de pago de cada deuda activa; aviso el día anterior.
- Doble conteo: el formulario ofrece "Pago de cuota" como tipo propio. Si alguien registró un gasto normal por un pago de cuota, se corrige reclasificando.

## 8. Deudas entre miembros

- Las crea el acreedor: deudor, monto, concepto. Estado `pendiente` hasta que el deudor acepta (o rechaza).
- El deudor registra pagos (`confirmado: false`); el acreedor confirma; al confirmar baja `saldo`. En 0 → `pagada`.
- No cuentan como gasto ni ingreso, ni entran al semáforo.

## 9. Hogar, roles y QR

- Un admin por hogar, no transferible. Un hogar activo por usuario.
- Sin hogar: crear uno o escanear QR. Ya en un hogar y escanea otro QR → error "Ya perteneces a un hogar".
- QR: solo admin; vale 4 horas; generar uno nuevo invalida el anterior. Contenido: `patodonald://unirse?h={hogarId}&c={codigo}`.
- Sacar miembro: solo admin. Estado `retirado`; sus movimientos quedan; pierde acceso de inmediato.
- Recuperación del admin: por correo. Si pierde el correo, el desarrollador reasigna `adminUid` desde la consola (procedimiento en `docs/08_operacion.md`).

## 10. Offline

- Leer y registrar movimientos funciona sin red; se sincroniza al volver.
- Requieren red y lo dicen en pantalla: crear hogar, unirse con QR, generar QR, sacar miembro, aprobar/rechazar corrección, crear/editar deudas externas.
- Validación de período: el cliente valida con su reloj; las rules validan contra `request.time` con margen de 48 h para escrituras encoladas offline.
