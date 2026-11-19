# Entrevista — Sección 3: Home e indicadores

Respuestas capturadas en la entrevista de implementación de **Nuestras Finanzas**.  
Fuente de preguntas: `PREGUNTAS_IMPLEMENTACION.md`.

---

## 3.1 Primer pantallazo del home

**Decisión:** **Todas** las piezas siguientes van en el home:

1. Total gastado del mes/período  
2. Ingresos del período  
3. Cuotas / deudas comprometidas  
4. Resultado vs presupuesto (verde o rojo)  
5. Desglose por categorías  
6. Presupuesto personal del período  
7. Si eres admin: vista/dashboard del manejo de los demás miembros  

---

## 3.2 Definición de verde y rojo

**Decisión:** **Opción A**

- **Rojo** si el gasto supera el presupuesto  
- **Verde** si el gasto no supera el presupuesto  

Sin umbral extra de ahorro mínimo en el MVP.

---

## 3.3 Período del “mes”

**Decisión:** **Opción B** — **período personalizado** (no mes calendario fijo).

### 3.3b Cómo se define

**Decisión:** **Cada usuario elige su día de inicio** del período.

*(Ej.: si elige día 15, su período corre de ese día al anterior del ciclo siguiente.)*

**Nota:** esto actualiza el supuesto de `PRODUCTO.md` (“mes calendario”).

---

## 3.4 Zona horaria

**Decisión:** **Opción A** — todo en **America/Bogota** (Colombia).

---

## Resumen de decisiones — Sección 3

| Tema | Decisión |
|------|----------|
| Home | Lista completa + presupuesto personal + dashboard admin |
| Semáforo | Rojo si gasto > presupuesto; si no, verde |
| Período | Personalizado; cada usuario elige día de inicio |
| Zona horaria | America/Bogota |

---

*Sección 3 cerrada en entrevista. Siguiente: Sección 4 — Técnica y entrega.*
