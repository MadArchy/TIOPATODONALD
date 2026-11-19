# CHANGELOG

Una entrada por slice cerrado: fecha, slice, qué se hizo, decisiones tomadas.

## 2026-11-19 — Slice 7: Correcciones y auditoría
- **Core**: `correcciones.dart` — plazo (período del movimiento + 5 días), validación de cambios, ajuste de saldo por reclasificación gasto↔pagoCuota (ida y vuelta), acción de auditoría.
- **Modelo/repo**: `Correccion` + `EntradaAuditoria` (freezed); `CorreccionesRepository` (pedir, observar pendientes/auditoría, callable `resolverCorreccion`).
- **UI**: detalle con “Pedir corrección” e “Historial de cambios”; admin `/correcciones` con antes/después, Aprobar / Rechazar (requiere internet) y badge de pendientes en Inicio.
- **Functions**: callable `resolverCorreccion` (solo admin; plazo; transacción; saldos; auditoría `correccion` / `anulacion` / `correccionAdminPropia`). `esEdicionMenor` ya no dispara en categoría de ingreso.
- **Rules**: `correcciones` read miembro; create miembro `pendiente` + motivo; update/delete false.
- **Índices**: `correcciones` por `estado+creadoEn` y `solicitanteUid+creadoEn`; `auditoria` por `movimientoId+fecha`.
- **Gaps conscientes**: push de corrección pendiente/resuelta y aviso masivo si admin corrige lo suyo (Slice 9).

## 2026-11-18 — Slice 6: Deudas entre miembros
- **Modelo/repo**: `DeudaInterna` + `PagoInterno` (freezed) y `DeudasInternasRepository` (crear cobro, aceptar/rechazar, registrar pago; confirmar vía callable).
- **UI**: `/deudas` con pestañas Externas | Entre nosotros (Me deben / Debo); detalle `/deudas-internas/:id` (aceptar/rechazar, registrar pago, confirmar).
- **Avisos in-app**: bandeja derivada de `deudasInternas` + `pagos` pendientes de acción (sin colección `avisos` nueva). Push queda en Slice 9.
- **Core**: `calcularConfirmacionPagoInterno` / `construirAvisosInternos`; test de que deudas internas no afectan gastado ni semáforo.
- **Functions**: callable `confirmarPagoInterno` (acreedor, transacción, idempotente; saldo 0 → `pagada`).
- **Rules**: read acreedor/deudor/admin; create acreedor `pendiente`; update deudor solo `pendiente`→`aceptada|rechazada`; pagos create deudor `confirmado==false`; pagos update false.
- **Índices**: `deudasInternas` por `deudorUid+estado` y `acreedorUid+estado`.
- **Gaps conscientes**: push FCM (Slice 9); correcciones (Slice 7).

## 2026-11-18 — Slice 5: Deudas externas y pago de cuota
- **Modelo/repo**: `Deuda` + `DeudasRepository` (crear/editar/desactivar con internet obligatorio; `saldoActual` solo lo baja el servidor).
- **UI**: pantalla `/deudas` (lista activa con saldo, cuota, próxima fecha, barra de avance); admin crea/edita/desactiva. Inicio muestra cuotas comprometidas y “Próximos pagos”. Nuevo movimiento con tipo **Cuota** (elige deuda, monto prellenado).
- **Core**: `proximaFechaPago` / `avanceDeuda`; `deudasCuotaHookProvider` cableado a deudas reales → cuotasPendientes en margen real del admin.
- **Functions**: trigger `alCrearMovimiento` (pagoCuota → baja saldo en transacción, `saldoAplicado`, estado `pagada` en 0; idempotente).
- **Rules**: `hogares/{h}/deudas` create/update solo admin; create exige `saldoActual == saldoInicial`; update no toca `saldoActual`; `pagoCuota` exige `deudaId` existente.
- **Gaps conscientes**: aviso push el día anterior (Slice 9); deudas entre miembros (Slice 6); reclasificar gasto→pagoCuota vía corrección (Slice 7).

## 2026-11-18 — Slice 4: Home, presupuesto y dashboard admin
- **Core (`app/lib/core/indicadores.dart`)**: funciones puras de gastado, ingresos, disponible, disponiblePorDia, proyección (truncada), semáforo, avisoPreventivo, porcentajeReducible, cuotasComprometidas/Pendientes, margenReal, alertasNuevas y `calcularIndicadoresPeriodo`. Tests con el ejemplo oficial de `docs/02_reglas_negocio.md` §2 y bordes (día 1/2/último, presupuesto 0, sin movimientos).
- **Inicio**: semáforo con texto+ícono, “Te quedan \$X por día”, barra 50/80/100, aviso preventivo, ingresos/cuotas (hook 0 hasta deudas), desglose por categoría, gastos fijos, banner de alertas 50/80/100 con persistencia en `alertasEnviadas`, tarjeta “Cierre de tu período” el día 1 si hay `resumenes` del período anterior.
- **Perfil**: cambiar presupuesto vía callable `cambiarPresupuesto` (auditoría `cambioPresupuesto`); día de inicio → `diaInicioPendiente` con texto “Aplica desde el …”.
- **Admin**: `/dashboard-admin` (margen real + tarjeta por miembro en SU período) y `/desglose-miembro/:uid`. El período ajeno se infiere del `periodoId` de presupuestos (sin leer `usuarios` ajenos).
- **Functions**: `cambiarPresupuesto` (callable) y `cerrarPeriodos` (cron 00:30 America/Bogota) que genera `resumenes/{uid}_{periodoId}` y aplica `diaInicioPendiente`.
- **Gaps conscientes**: cuotas/deudas en 0 hasta Slice 5; push de alertas en Slice 9.

## 2026-11-18 — Preparación
- Kit de arranque: AGENTS.md, reglas para Antigravity (`.agents/`) y Cursor (`.cursor/`), docs 01–08, prompts por slice.
- Decisiones por defecto registradas en `docs/07_decisiones.md`.

## 2026-11-18 — Slice 0: Base del proyecto
- **Flutter (`app/`)**: Proyecto Android (`co.patodonald.app`) con flavors `dev` y `prod`, dependencias del stack (`flutter_riverpod`, `go_router`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions`, `firebase_messaging`, `freezed`, `json_serializable`, `intl`, `build_runner`, `mocktail`).
- **Core**:
  - `formatCop(int)` y `parseCopInput(String)` en `app/lib/core/utils/dinero.dart` con tests unitarios.
  - `Clock` inyectable (`SystemClock` / `FixedClock`) y `clockProvider` en `app/lib/core/utils/clock.dart`.
  - Tema Material 3 con colores de semáforo verde/rojo accesibles (contraste AA) y botones mínimos de 52dp en `app/lib/core/theme/app_theme.dart`.
  - `go_router` con pantalla inicial `"Hola, PATO DONALD"` en `app/lib/core/router/app_router.dart`.
  - Inicialización de Firebase con persistencia offline activada y conexión a emuladores en `dev` cuando `--dart-define=USE_EMULATORS=true`.
- **Firebase y Cloud Functions (`functions/`)**:
  - Región única elegida: `us-central1`.
  - `functions/src/index.ts` en TypeScript (v2) con función `ping` (`onCall`) y `pingHttp` (`onRequest`), ESLint y Jest.
  - `firestore.rules` y `storage.rules` que niegan todo por defecto, con tests de `@firebase/rules-unit-testing` contra el emulador.
  - `firestore.indexes.json` vacío y `.github/workflows/ci.yml` configurado.

## 2026-11-18 — Slice 1: Auth
- **Modelo y repositorio (`app/lib/data/`)**:
  - Modelo `Usuario` (`freezed` + `json_serializable`) con todos los campos de `docs/03_modelo_datos.md` (`uid`, `nombre`, `email`, `hogarId`, `diaInicioPeriodo`, `diaInicioPendiente`, `horaRecordatorio`, `fcmTokens`, `creadoEn`).
  - `AuthRepository` / `FirebaseAuthRepository` que al registrarse crea `usuarios/{uid}` con `diaInicioPeriodo: 1` y `hogarId: null`.
  - Validadores y traducción de errores de Firebase Auth a español de Colombia en `app/lib/core/errors/auth_failures.dart`.
- **Pantallas y navegación (`app/lib/features/auth/` y `app_router.dart`)**:
  - Pantallas: `BienvenidaScreen`, `RegistroScreen`, `LoginScreen`, `RecuperarPasswordScreen`, `PerfilProvisionalScreen`, `SinHogarScreen` ("Crea o únete a un hogar") e `InicioProvisionalScreen`.
  - Guardas reactivas en `go_router`: sin sesión → `/bienvenida`; con sesión y `hogarId == null` → `/sin-hogar`; con sesión y `hogarId != null` → `/inicio`.
- **Security Rules (`firestore.rules`)**:
  - Reglas de `usuarios/{uid}`: solo el propio `uid` lee y escribe; `create` exige `hogarId == null` y `diaInicioPeriodo` ∈ [1, 28]; `update` prohíbe modificar `hogarId` y `creadoEn`; `delete: if false`.
  - Tests con emulador en `functions/test/rules/usuarios.rules.test.ts`.

## 2026-11-18 — Slice 3: Movimientos
- **Modelos y core (`app/`)**: `Movimiento`, `GastoFijo` (freezed); `categorias.dart` (ids, labels, íconos, reducibles); `movimientos_validacion.dart` (creación, edición menor < 24 h, día esperado de gasto fijo).
- **Repositorio y offline**: `MovimientosRepository` (CRUD movimientos/gastos fijos, streams, edición menor); `ColaFotosService` (disco + reintento al reconectar) con `image_picker` / `flutter_image_compress` (~300 KB) → Storage `recibos/{h}/{movId}.jpg`.
- **UI**: FAB "+" y hoja `NuevoMovimientoSheet` (Gasto/Ingreso, monto, categorías, más opciones); `HistorialMovimientosScreen` (Míos/hogar, categoría, períodos anteriores solo lectura); `DetalleMovimientoScreen` (edición menor); `GastosFijosScreen` + tarjeta en Inicio el día esperado; link en Perfil; rutas `/historial`, `/movimiento/:id`, `/gastos-fijos`.
- **Firebase**: rules de `movimientos` (create, edición menor, completar `fotoPath`, delete false) y `gastosFijos`; `storage.rules` para recibos; Function `alEditarMovimiento` escribe auditoría `edicionMenor`; índices compuestos de movimientos.
- **Tests**: unitarios de categorías/validación; smoke UI del sheet; rules (create ok/fail uid/período, delete fail, update <24h ok / 25h fail, gastos fijos).

## 2026-11-18 — Slice 2: Hogar e invitación por QR
- **Lógica pura de períodos (`app/lib/core/periodo.dart`)**:
  - `Periodo periodoDe(DateTime instante, int diaInicio)`, `diasTranscurridos` y `diasRestantes` en zona horaria `America/Bogota` (UTC-5).
  - Tests unitarios en `app/test/core/periodo_test.dart` (D = 1, 15, 28, cruce de año, febrero bisiesto, medianoche en Bogotá y ejemplo oficial de `docs/02_reglas_negocio.md`).
- **Cloud Functions v2 (`functions/src/hogar.ts` e `index.ts`)**:
  - `crearHogar`, `generarInvitacion` (+4 h, invalida la anterior), `unirseConCodigo` y `sacarMiembro` con validaciones y transacciones.
  - Tests con emulador y reloj simulado en `functions/test/rules/hogar.rules.test.ts`.
- **Security Rules (`firestore.rules`)**:
  - Lectura de `hogares/{h}/**` restringida a miembros activos (`esMiembroActivo(hogarId)`); `invitaciones` solo admin; `presupuestos/{uid}_{periodoId}` escritura por su propio dueño con `monto` entero > 0; revocación inmediata al pasar un miembro a `estado: 'retirado'`.
- **App Flutter (`app/`)**:
  - Modelos `Hogar`, `MiembroHogar`, `InvitacionHogar`, `Presupuesto` (`freezed` + `json_serializable`).
  - Deep link `patodonald://unirse?h=..&c=..` en `AndroidManifest.xml`, `parseInvitacionQr` y `UnirseDeepLinkScreen`.
  - Pantallas: `SinHogarScreen` (Crear hogar / Escanear QR), `EscanearQrScreen` (`mobile_scanner`), `ConfigurarPresupuestoPeriodoScreen` ("Tu presupuesto y tu período") y `MiembrosQrScreen` (`qr_flutter` con cuenta regresiva de 4 h, "Generar nuevo" y "Sacar" con confirmación).
  - Validación de conectividad que muestra `"Necesitas internet para esto"` cuando no hay red.
