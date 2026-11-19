# Entrevista — Sección 7: Riesgos y preferencias al ejecutar

Respuestas capturadas en la entrevista de implementación de **PATO DONALD**.  
Fuente de preguntas: `PREGUNTAS_IMPLEMENTACION.md`.

---

## 7.1 Transparencia vs velocidad

**Decisión:** **Opción B** — permitir **ediciones menores sin aprobación**.

**Nota de tensión con Sección 1:** las correcciones “completas” (monto, categoría, fecha, nota, anular, reclasificar) siguen existiendo con admin + log; aquí se abre una vía más liviana para errores tipográficos / cambios menores. Habrá que definir en implementación qué cuenta como “menor”.

---

## 7.2 Qué sacrificar si hay que recortar

**Decisión:** **Nada se sacrifica** — “todo debe ir” en el MVP.

Ítems que permanecen innegociables según esta respuesta:

- Invitación por QR  
- Deudas + cuotas en el margen  
- Correcciones vía admin  
- Desglose por categorías  
- Home verde/rojo completo  
- Foto de recibo  
- Deudas entre miembros  

---

## 7.3 Mayor miedo al implementar

**Decisión:** **Opción B** — **usabilidad familiar**.

Prioridad de diseño/QA: que la familia entienda y use la app sin fricción, por encima de (como miedo principal) seguridad, cálculos o velocidad de entrega.

---

## Resumen de decisiones — Sección 7

| Tema | Decisión |
|------|----------|
| Ediciones | Menores sin aprobación |
| Recorte MVP | No recortar |
| Riesgo #1 | Usabilidad familiar |

---

*Sección 7 cerrada. Entrevista completa.*
