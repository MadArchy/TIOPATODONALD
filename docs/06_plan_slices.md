# 06 — Plan por slices

Orden de la entrevista (§4.8) ampliado. Cada slice termina con algo que funciona en un
teléfono Android real y se muestra a una persona de la familia. Semanas = estimación para
un desarrollador con apoyo de agentes; ajustar con la realidad.

| # | Slice | Prompt | Estado | Semanas (estim.) |
| --- | --- | --- | --- | --- |
| 0 | Base del proyecto | `prompts/slice-00-base.md` | [x] | 0,5 |
| 1 | Auth | `prompts/slice-01-auth.md` | [x] | 0,5 |
| 2 | Hogar / QR | `prompts/slice-02-hogar-qr.md` | [x] | 1 |
| 3 | Movimientos | `prompts/slice-03-movimientos.md` | [x] | 1,5 |
| 4 | Home y presupuesto | `prompts/slice-04-home.md` | [x] | 2 |
| 5 | Deudas externas | `prompts/slice-05-deudas.md` | [x] | 1 |
| 6 | Deudas entre miembros | `prompts/slice-06-deudas-internas.md` | [x] | 1 |
| 7 | Correcciones | `prompts/slice-07-correcciones.md` | [x] | 1,5 |
| 8 | Chat Nivel 1 + puertas de IA | `prompts/slice-08-chat.md` | [x] | 2 |
| 9 | Avisos, pulido y piloto | `prompts/slice-09-piloto.md` | [ ] | 2 |

Total estimado: ~13 semanas.

Regla: un slice no empieza hasta que el anterior pasa `/cerrar-slice`.
