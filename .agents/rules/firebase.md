# Reglas Firebase (firestore.rules, storage.rules, functions/)

- Modelo de datos exacto en `docs/03_modelo_datos.md`. No agregues colecciones ni campos sin actualizar ese documento primero.
- Security rules:
  - Función base `esMiembroActivo(hogarId)` = existe `hogares/{h}/miembros/{request.auth.uid}` con `estado == 'activo'`.
  - `esAdmin(hogarId)` = `get(hogares/{h}).data.adminUid == request.auth.uid`.
  - Validar tipos y valores en cada `create`/`update` (monto entero > 0, tipo y categoría dentro de la lista, `uid == request.auth.uid`).
  - `delete` de movimientos: siempre `false`.
  - Colecciones solo-servidor (`auditoria`, `miembros`, `invitaciones`, `usoIA`): escritura `false` desde clientes.
  - Cada regla nueva o cambiada lleva un test en `functions/test/rules/` o `test-rules/` con `@firebase/rules-unit-testing` contra el emulador.
- Cloud Functions (TypeScript):
  - Callables con `onCall` (v2), validan `request.auth` y los permisos dentro de la función (no confiar en el cliente).
  - Operaciones que tocan varios documentos van en **transacción**.
  - Triggers idempotentes: si un trigger corre dos veces, el resultado es el mismo (guardar un marcador `procesado` o usar el id del movimiento).
  - Errores con `HttpsError` y mensajes en español aptos para mostrar al usuario.
  - Región: `southamerica-east1` o `us-central1` (elegir una y usarla en todo).
- Secretos: `defineSecret()` / Secret Manager. Nunca en `.env` commiteado ni en la app.
- Índices compuestos en `firestore.indexes.json`, versionados.
- Desarrollo y tests SIEMPRE contra emuladores.
