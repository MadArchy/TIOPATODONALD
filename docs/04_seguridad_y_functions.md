# 04 — Security rules y Cloud Functions

Principio: las rules impiden lo que nunca debe pasar; las Functions hacen lo que el cliente
no puede hacer solo (tocar datos de otros, validar QR, aprobar, bajar saldos).

## Security rules (Firestore)

| Ruta | read | create | update | delete |
| --- | --- | --- | --- | --- |
| `usuarios/{uid}` | el propio uid | el propio uid (sin `hogarId`) | el propio uid, sin tocar `hogarId` | no |
| `hogares/{h}` | miembro activo | no (Function) | no (Function) | no |
| `miembros`, `invitaciones`, `auditoria`, `resumenes`, `usoIA` | miembro activo (invitaciones: solo admin) | no | no | no |
| `presupuestos/{uid}_{p}` | miembro activo | ese uid, monto int > 0 | ese uid | no |
| `movimientos` | miembro activo | ver abajo | ver abajo | **no** |
| `gastosFijos` | miembro activo | uid propio | uid propio | uid propio |
| `deudas` | miembro activo | admin, `saldoActual == saldoInicial` | admin, sin tocar `saldoActual` | no |
| `deudasInternas` | acreedor, deudor o admin | acreedor = auth.uid, estado `pendiente` | deudor: solo `estado` pendiente → aceptada/rechazada | no |
| `deudasInternas/{d}/pagos` | partes o admin | deudor, `confirmado == false` | no (Function confirma) | no |
| `correcciones` | miembro activo | miembro activo, estado `pendiente`, motivo no vacío | no (Function) | no |
| `chats/{uid}/mensajes` | ese uid | ese uid | ese uid (estado) | no |

### Movimientos
- create: miembro activo · `uid == request.auth.uid` · tipo válido · monto int > 0 · categoría válida para el tipo (o `deudaId` existente si `pagoCuota`) · `periodoId` coherente con `fecha` y `diaInicioPeriodo` del usuario · `fecha <= request.time` · `periodoId` = período vigente del usuario, o el inmediatamente anterior si `request.time` está a menos de 48 h de su cierre (margen para escrituras offline) · `estado == 'activo'` · `creadoEn == request.time`.
- update (edición menor): autor · solo cambian `nota`, `categoria` (gasto→gasto) y `editadoEn` · `request.time < creadoEn + 24h`.

## Storage rules
`recibos/{h}/{movId}.jpg`: miembro activo del hogar (via `firestore.get`), `contentType` image/*, tamaño < 1 MB.

## Cloud Functions

| Función | Tipo | Hace | Valida |
| --- | --- | --- | --- |
| `crearHogar` | callable | Crea hogar + miembro admin + `usuarios.hogarId` (transacción) | usuario sin hogar |
| `generarInvitacion` | callable | Desactiva la anterior, crea código con `expiraEn` +4 h, devuelve URL del QR | admin |
| `unirseConCodigo` | callable | Agrega miembro, setea `usuarios.hogarId` | código activo y no vencido; usuario sin hogar |
| `sacarMiembro` | callable | `estado: retirado`, `usuarios.hogarId = null` | admin; no puede sacarse a sí mismo |
| `resolverCorreccion` | callable | Aplica cambios, ajusta saldos si hay reclasificación, escribe auditoría, notifica | admin; plazo de corrección |
| `alCrearMovimiento` | trigger onCreate | Si `pagoCuota`: baja `saldoActual` (transacción, marca `saldoAplicado`); revisa alertas 50/80/100 | idempotente |
| `alEditarMovimiento` | trigger onUpdate | Escribe auditoría `edicionMenor` | |
| `confirmarPagoInterno` | callable | Marca pago confirmado, baja saldo, cierra deuda en 0 | acreedor |
| `cerrarPeriodos` | programada diaria 00:30 Bogotá | Genera `resumenes` de quienes cerraron período; aplica `diaInicioPendiente` | |
| `avisosDiarios` | programada | Recordatorio diario, cuotas que vencen mañana, correcciones pendientes al admin | |
| `asistente` | callable | **Puerta de IA**: hoy responde "próximamente" | miembro activo; `hogar.ia.activa` |

Requiere plan **Blaze** (pago por uso). Para una familia el costo esperado es casi cero, pero pide tarjeta.

## Pruebas obligatorias
- Rules: un test por fila de la tabla, caso permitido y caso negado.
- Functions: tests con emulador para cada callable (feliz + permisos + bordes: QR vencido, usuario con hogar, corrección fuera de plazo, trigger ejecutado dos veces).
