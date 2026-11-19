# 03 — Modelo de datos (Cloud Firestore)

Convenciones: montos `int` en COP · fechas `Timestamp` · `periodoId` texto `YYYY-MM-DD` ·
ids de categorías sin tildes (ver `02_reglas_negocio.md` §3) · todo dato de un hogar bajo `hogares/{hogarId}`.

## Colecciones

### `usuarios/{uid}`
| Campo | Tipo | Notas |
| --- | --- | --- |
| nombre | string | |
| email | string | |
| hogarId | string \| null | null = sin hogar. Lo escribe solo el servidor |
| diaInicioPeriodo | int 1–28 | |
| diaInicioPendiente | int \| null | aplica en el siguiente período |
| horaRecordatorio | string `HH:mm` \| null | recordatorio diario |
| fcmTokens | array<string> | |
| creadoEn | Timestamp | |

### `hogares/{hogarId}`
| Campo | Tipo | Notas |
| --- | --- | --- |
| nombre | string | |
| adminUid | string | fijo |
| ia | map | `{ activa: false, proveedor: "", modelo: "", limiteMensual: 0 }` — puerta de IA |
| creadoEn | Timestamp | |

### `hogares/{h}/miembros/{uid}` (solo servidor)
nombre · rol (`admin` \| `miembro`) · estado (`activo` \| `retirado`) · unidoEn · retiradoEn

### `hogares/{h}/invitaciones/{id}` (solo servidor)
codigo (string aleatorio 16+ caracteres) · creadaPor · creadaEn · expiraEn (+4 h) · activa (bool)

### `hogares/{h}/presupuestos/{uid}_{periodoId}`
uid · periodoId · monto (int) · alertasEnviadas (array<int>: 50, 80, 100) · actualizadoEn

### `hogares/{h}/movimientos/{id}`
| Campo | Tipo | Notas |
| --- | --- | --- |
| tipo | `gasto` \| `ingreso` \| `pagoCuota` | |
| monto | int > 0 | |
| categoria | string \| null | null solo en `pagoCuota` |
| deudaId | string \| null | solo en `pagoCuota` |
| gastoFijoId | string \| null | si vino de una plantilla |
| fecha | Timestamp | dentro del período vigente |
| periodoId | string | período de `uid` |
| uid | string | quien registró |
| nota | string | opcional, máx. 200 |
| fotoPath | string \| null | ruta en Storage |
| origen | `formulario` \| `chat` \| `gastoFijo` | para medir uso del chat |
| estado | `activo` \| `anulado` | |
| creadoEn | Timestamp | `serverTimestamp()` |
| editadoEn | Timestamp \| null | |
| saldoAplicado | bool | lo marca la Function al bajar el saldo (idempotencia) |

### `hogares/{h}/gastosFijos/{id}`
uid · nombre · monto · categoria · diaEsperado (1–31) · activo

### `hogares/{h}/deudas/{id}` (escribe admin; `saldoActual` solo servidor)
entidad · saldoInicial · saldoActual · cuotaMensual · diaPago · numeroCuotas · estado (`activa` \| `pagada` \| `desactivada`) · creadaEn

### `hogares/{h}/deudasInternas/{id}`
acreedorUid · deudorUid · montoInicial · saldo · concepto · estado (`pendiente` \| `aceptada` \| `rechazada` \| `pagada`) · creadaEn
- Subcolección `pagos/{id}`: monto · fecha · registradoPor (deudor) · confirmado (bool) · confirmadoEn

### `hogares/{h}/correcciones/{id}`
movimientoId · solicitanteUid · motivo · cambios (map campo → valor nuevo; `estado: anulado` para anular) · estado (`pendiente` \| `aprobada` \| `rechazada`) · resueltaPor · resueltaEn · motivoRechazo · creadoEn

### `hogares/{h}/auditoria/{id}` (solo servidor, nunca se borra)
movimientoId \| null · accion (`correccion` \| `edicionMenor` \| `anulacion` \| `cambioPresupuesto` \| `correccionAdminPropia`) · antes (map) · despues (map) · porUid · aprobadoPor · fecha

### `hogares/{h}/resumenes/{uid}_{periodoId}` (servidor, al cerrar período)
gastado · ingresos · presupuesto · semaforo · porCategoria (map) · porcentajeReducible · variacionVsAnterior (map) · creadoEn
> Puerta de IA: es el contexto que leerá el asistente.

### `hogares/{h}/chats/{uid}/mensajes/{id}`
rol (`usuario` \| `app` \| `ia`) · texto · intencion (map \| null, ver `05_ia.md`) · estado (`propuesto` \| `confirmado` \| `descartado`) · fecha

### `hogares/{h}/usoIA/{id}` (solo servidor, futuro)
uid · proveedor · modelo · tokensEntrada · tokensSalida · fecha

## Storage
`recibos/{hogarId}/{movimientoId}.jpg` — solo miembros activos, solo `image/*`, máx. 1 MB.

## Índices compuestos (`firestore.indexes.json`)
| Colección | Campos |
| --- | --- |
| movimientos | uid ASC, periodoId ASC, fecha DESC |
| movimientos | periodoId ASC, fecha DESC |
| movimientos | deudaId ASC, periodoId ASC |
| correcciones | estado ASC, creadoEn DESC |
| deudasInternas | deudorUid ASC, estado ASC |
| deudasInternas | acreedorUid ASC, estado ASC |

## Volumen esperado
Familia de 2–6 personas: cientos de movimientos por período. Los agregados se calculan en el cliente.
Si un hogar pasa de ~2.000 movimientos por período, agregar documento resumen mantenido por Function.
