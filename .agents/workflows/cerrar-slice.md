---
description: Verifica y cierra el slice en curso
---

1. Corre `cd app && flutter analyze && flutter test` y `cd functions && npm run lint && npm test`. Si algo falla, arréglalo antes de seguir.
2. Corre los tests de security rules contra el emulador.
3. Revisa uno por uno los criterios "Listo cuando" del `prompts/slice-XX.md` y dime cuáles se cumplen y cómo lo comprobaste.
4. Lista los pasos para probarlo en un teléfono Android real (lo que debe hacer una persona de la familia).
5. Marca el slice en `docs/06_plan_slices.md` y agrega una entrada en `docs/CHANGELOG.md` con fecha, qué se hizo y decisiones tomadas.
6. Propón el mensaje de commit. No hagas push sin que lo pida.
