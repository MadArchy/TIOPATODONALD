---
description: Revisa que el código cumpla las reglas de negocio y de seguridad
---

1. Lee `docs/02_reglas_negocio.md` y `docs/04_seguridad_y_functions.md`.
2. Recorre el código del slice actual y las `firestore.rules`.
3. Para cada regla de "Reglas que nunca se rompen" de `AGENTS.md`, dime dónde se hace cumplir (archivo y línea) o si falta.
4. Busca: montos en `double`, `DateTime.now()` fuera de `Clock`, escrituras del cliente a colecciones solo-servidor, API keys en el código, textos de UI en inglés.
5. Entrega una lista de hallazgos ordenada por gravedad, sin cambiar código hasta que lo apruebe.
