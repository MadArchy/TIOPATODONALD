# Entrevista — Sección 2: Roles y hogar

Respuestas capturadas en la entrevista de implementación de **Nuestras Finanzas**.  
Fuente de preguntas: `PREGUNTAS_IMPLEMENTACION.md`.

---

## 2.1 Cantidad de admins

**Decisión:** **Opción A** — **un solo admin** por hogar en el MVP.

---

## 2.2 Transferir el rol admin

**Decisión:**

- **No se puede transferir** el admin en el MVP.
- El admin **debe poder recuperar la cuenta y sus datos**.

---

## 2.3 Salir / sacar miembros del hogar

**Decisión:**

- **Sí se pueden sacar miembros** del hogar.
- El **histórico permanece** en el hogar (los movimientos no se borran al sacar al miembro).

---

## 2.4 Usuario ya en un hogar + nuevo QR

**Decisión:** **Opción A** — **un solo hogar activo** por usuario.

Si ya pertenece a un hogar y escanea el QR de otro → **error** (no se une al segundo).

---

## 2.5 Usuario sin hogar

**Decisión:** Si no tiene hogar, **puede crear uno**.

*(El flujo de unirse por QR se mantiene alineado con el producto, salvo decisión contraria posterior.)*

---

## 2.6 Caducidad del QR

**Decisión:** **Opción B** — el QR **expira en 4 horas**.

---

## 2.7 Quién genera el QR

**Decisión:** **Opción A** — **solo el admin** genera y muestra el QR de invitación.

---

## Resumen de decisiones — Sección 2

| Tema | Decisión |
|------|----------|
| Admins | Uno solo |
| Transferencia admin | No en MVP; sí recuperación de cuenta/datos |
| Miembros | Se pueden sacar; histórico queda en el hogar |
| Multi-hogar | No; un hogar activo por usuario |
| Sin hogar | Puede crear uno |
| QR | Solo admin; expira en 4 horas |

---

*Sección 2 cerrada en entrevista. Siguiente: Sección 3 — Home e indicadores.*
