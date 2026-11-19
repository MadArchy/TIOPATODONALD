# CHANGELOG

Una entrada por slice cerrado: fecha, slice, qué se hizo, decisiones tomadas.

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
