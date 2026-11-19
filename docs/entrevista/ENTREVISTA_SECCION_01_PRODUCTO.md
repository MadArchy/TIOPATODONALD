# Entrevista — Sección 1: Producto y reglas de negocio

Respuestas capturadas en la entrevista de implementación de **Nuestras Finanzas**.  
Fuente de preguntas: `PREGUNTAS_IMPLEMENTACION.md`.

---

## 1.1 Fórmula del mes (verde / rojo)

**Decisión:** El verde/rojo no se basa solo en ingresos − gastos − cuotas. Se basa en un **presupuesto de gasto del mes** que la persona define (ej. “quiero gastar 4 millones”).

- Se debe ver el **saldo** / si hay algo ahorrado o disponible.
- Si el gasto del mes **excede** ese presupuesto → el mes queda en **déficit** y los números van en **rojo**.
- La app debe **anunciar** cuando se supera ese tope.

**Implicación vs `PRODUCTO.md`:** se introduce el concepto de **presupuesto personal mensual** como control principal del semáforo.

---

## 1.1b Quién fija el presupuesto

**Decisión:** **Cada usuario crea su propio presupuesto.**

El **admin** recibe en un **dashboard** la visión del manejo de cada usuario (transparencia del hogar sin que el presupuesto sea único compartido).

---

## 1.2 Cuotas de deuda vs gasto registrado

**Decisión:**

1. Al crear una deuda se deben mostrar las **fechas de pago** como primer resguardo / recordatorio.
2. Si alguien registra “gasté X en pago de cuota” como gasto normal, **por ahora cuenta como gasto normal**.
3. Como las cuotas debidas siguen visibles, puede haber **doble conteo**.
4. Eso entra al flujo de **corrección**: hay una **ventana de tiempo** en la que se señala el caso y se pasa al ítem correcto (**pago de cuota**).

---

## 1.3 Atribución del movimiento

**Decisión:** **Opción A** — solo importa **quién lo registró**.

**Regla extra:** **nadie puede registrar movimientos por otra persona.**

---

## 1.4 Qué se puede corregir

**Decisión:** **Todas** las opciones del MVP:

- Cambiar monto
- Cambiar categoría
- Cambiar fecha
- Cambiar nota
- Anular el movimiento
- Reclasificar (ej. gasto → pago de cuota)

---

## 1.5 Cómo se ve el historial tras corregir

**Decisión:** **Opción B**

- Se **actualiza** el valor del movimiento.
- Queda un **log de auditoría** (quién pidió, quién aprobó, qué cambió).

---

## 1.6 Quién gestiona las deudas

**Decisión:** **Opción A** — **solo el admin** crea, edita o desactiva deudas del hogar.

---

## 1.7 Pago de cuota y saldo de deuda

**Decisión:** Las cuotas **se van pagando** y el **saldo de la deuda debe ir bajando**.

---

## 1.8 Categorías de gasto (MVP)

**Decisión:** Lista fija **completa** confirmada:

- Alimentación
- Servicios
- Transporte
- Vivienda
- Salud
- Educación
- Ocio / caprichos
- Otros

---

## 1.9 Categorías en ingresos

**Decisión:** Categorías también en **ingresos** (interpretación de “todas”: aplican a gastos e ingresos).

**Propuesta operativa pendiente de matizar si hace falta:** al menos **Salario** y **Otros** para ingresos.

---

## 1.10 Fecha del movimiento

**Decisión:**

- Solo se pueden **registrar** movimientos del **mes vigente**.
- Sí se puede **ver el historial** de meses anteriores.
- **No** se pueden modificar cosas de meses anteriores (salvo el flujo de corrección ya definido, si aplica al mes vigente / reglas que se detallen después).

---

## Resumen de decisiones — Sección 1

| Tema | Decisión |
|------|----------|
| Semáforo | Presupuesto personal vs gasto real |
| Quién presupuesta | Cada usuario; admin ve dashboard |
| Deuda vs gasto | Fechas de pago + corrección si hay doble conteo |
| Atribución | Solo quien registra; no registrar por otros |
| Correcciones | Todo editable vía admin + log auditoría |
| Deudas | Solo admin; saldo baja con pagos |
| Categorías | Lista fija gastos; también ingresos |
| Fechas | Alta solo mes vigente; historial solo lectura |

---

*Sección 1 cerrada en entrevista. Siguiente: Sección 2 — Roles y hogar.*
