# AGENTS.md — PATO DONALD

Reglas compartidas para cualquier agente de código (Google Antigravity, Cursor, Claude Code).
Las leen todas las herramientas. Mantén este archivo corto: el detalle está en `docs/`.

## Qué es el proyecto

App Android de finanzas del **hogar**. Cada miembro registra sus propios gastos e ingresos,
los compara contra **su presupuesto personal** en **su propio período**, y el admin ve el
manejo de todos en un dashboard. Foco: **transparencia** y **usabilidad familiar**.

- Nombre interno del piloto: PATO DONALD (no publicar con ese nombre; ver `docs/01_producto.md`).
- Piloto: una familia. Moneda: solo COP. Zona horaria: America/Bogota.

## Stack (no cambiar sin preguntar)

- Flutter (Android primero) · Dart con null-safety · Material 3
- Estado: Riverpod · Navegación: go_router
- Firebase: Auth (email/contraseña), Cloud Firestore (con persistencia offline), Storage, Cloud Functions (TypeScript, Node), FCM (avisos)
- IA futura: Genkit dentro de Cloud Functions (apagado en el MVP)

## Fuente de verdad

Antes de escribir código lee, en este orden:

1. `docs/02_reglas_negocio.md` — reglas que el código DEBE cumplir
2. `docs/03_modelo_datos.md` — colecciones y campos exactos
3. `docs/04_seguridad_y_functions.md` — security rules y Functions
4. `docs/06_plan_slices.md` — en qué slice estamos y qué falta
5. `prompts/slice-XX.md` — la tarea concreta del slice en curso

Si el código y `docs/` no coinciden, **gana `docs/`**. Si `docs/` es ambiguo o se contradice,
**detente y pregunta**; no inventes reglas de negocio.

## Reglas que nunca se rompen

1. Nadie registra movimientos a nombre de otro: `uid` del movimiento = usuario autenticado.
2. Los movimientos **no se borran**: se anulan (`estado: anulado`).
3. Solo se registra en el **período vigente** del usuario que registra.
4. Cambios de monto, fecha, anulación o reclasificación pasan por **corrección aprobada por el admin** y dejan entrada en `auditoria`.
5. `saldoActual` de deudas, `auditoria`, `miembros` e `invitaciones` **solo los escribe el servidor** (Cloud Functions).
6. Ninguna API key (IA u otra) va en el código de la app. Solo en Secret Manager.
7. Montos en COP como **enteros** (`int`), nunca `double`.
8. Fechas: guardar `Timestamp` + `periodoId` (texto `YYYY-MM-DD` = inicio del período). Calcular períodos siempre en America/Bogota.
9. Todo dato de un hogar vive bajo `hogares/{hogarId}/...`.

## Estructura del repo

```
app/                 # proyecto Flutter
  lib/
    core/            # tema, router, utilidades (dinero, períodos), errores
    data/            # repositorios Firestore/Storage, modelos (freezed + json)
    features/        # una carpeta por módulo: auth, hogar, movimientos, home,
                     # presupuesto, deudas, deudas_internas, correcciones, chat, admin
  test/
functions/           # Cloud Functions en TypeScript
firestore.rules
firestore.indexes.json
storage.rules
docs/                # decisiones y especificación (fuente de verdad)
prompts/             # un prompt por slice
```

## Cómo trabajar

- Un slice a la vez. No adelantes código de slices futuros (salvo las "puertas de IA" del slice 8).
- Antes de codificar, escribe un plan corto (archivos a crear/modificar y pruebas). Espera aprobación si el cambio toca reglas de negocio, security rules o el modelo de datos.
- Cada lógica de negocio (períodos, semáforo, proyección, disponible por día, saldos) va en funciones puras en `app/lib/core/` o `data/` con **tests unitarios**.
- Cada cambio en `firestore.rules` lleva test con el emulador (`@firebase/rules-unit-testing`).
- Usa los emuladores de Firebase en desarrollo; nunca escribas en producción desde pruebas.
- Textos de la UI en **español de Colombia**, claros y cortos, pensados para personas no técnicas. Montos con formato `$85.000`.
- Al terminar un slice: actualiza la casilla en `docs/06_plan_slices.md` y anota en `docs/CHANGELOG.md`.

## Comandos

```
cd app && flutter pub get && flutter test
cd functions && npm install && npm test
firebase emulators:start
```

## Lo que está fuera del MVP

Metas y gamificación, perfil hijo, agente de IA activo, login social, multi-moneda, iOS.
