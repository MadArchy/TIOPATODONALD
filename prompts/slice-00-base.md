# Slice 0 — Base del proyecto

**Objetivo:** repo listo para construir: app Flutter Android que abre, conectada a Firebase con emuladores, y CI básico.

**Lee primero:** `AGENTS.md`, `docs/03_modelo_datos.md` (convenciones), `docs/08_operacion.md`.

## Construye
1. `app/`: `flutter create --org co.patodonald --platforms android app`. Dependencias: flutter_riverpod, go_router, firebase_core, firebase_auth, cloud_firestore, firebase_storage, cloud_functions, firebase_messaging, freezed, json_serializable, intl, build_runner, mocktail.
2. Firebase: proyectos `pato-donald-dev` y `pato-donald-prod` (los creo yo en la consola; tú me das los pasos exactos y el comando `flutterfire configure` para cada uno). Sabores (flavors) `dev` y `prod`.
3. Firestore con persistencia offline activada. En `dev`, conectar a emuladores (Auth, Firestore, Storage, Functions) cuando `--dart-define=USE_EMULATORS=true`.
4. `functions/` en TypeScript (Functions v2), con ESLint y Jest/Mocha; una función `ping` de prueba.
5. `firestore.rules`, `storage.rules` que **niegan todo** por ahora; `firestore.indexes.json` vacío.
6. `core/`: `formatCop(int)`, `Clock` inyectable, tema Material 3 (verde/rojo accesibles), router con pantalla "Hola, PATO DONALD".
7. CI (GitHub Actions): `flutter analyze`, `flutter test`, `npm test` en functions.

## Fuera de alcance
Pantallas reales, auth, modelos de negocio.

## Listo cuando
- La app abre en un teléfono Android real con el flavor `dev` contra emuladores.
- `formatCop(85000) == '$85.000'` y `formatCop(1200000) == '$1.200.000'` con test.
- `firebase emulators:start` levanta todo y `ping` responde.
- CI en verde.
