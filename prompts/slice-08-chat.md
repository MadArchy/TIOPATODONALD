# Slice 8 — Chat Nivel 1 y puertas de IA

**Objetivo:** registrar y preguntar escribiendo como se le habla a alguien de la casa, sin IA, y dejar todo listo para conectar IA después.

**Lee primero:** `docs/05_ia.md` completo; `docs/03_modelo_datos.md` (chats, hogares.ia).

## Construye
1. Modelo `Intencion` (freezed) con las acciones de `05_ia.md`. Es el contrato entre intérprete y app.
2. Interfaz `Interprete { Future<Intencion> interpretar(String texto, ContextoUsuario ctx); }`. Implementación `InterpreteReglas` (montos, tipo, categorías por diccionario, deudas por nombre aproximado, preguntas fijas). Deja `InterpreteIA` declarado pero sin usar.
3. Pestaña Chat: burbujas, campo de texto, sugerencias rápidas ("¿Cómo voy?", "Gasté…"). Cada `proponerMovimiento` muestra tarjeta [Guardar] [Cambiar] — nunca guarda solo. `noEntendido` abre el formulario prellenado.
4. Guardar mensajes en `hogares/{h}/chats/{uid}/mensajes` con intención y estado. Movimientos creados con `origen: chat`.
5. Puertas de IA: campo `hogares/{h}.ia` con `activa: false`; Function `asistente` desplegada que responde "próximamente"; `resumenes` ya existen desde el slice 4.
6. Funciona offline.

## Listo cuando
- Tabla de ≥ 60 frases (pide a la familia frases reales) con intención esperada: ≥ 90% correctas en tests.
- "gasté 85 mil en mercado" → tarjeta Gasto $85.000 Alimentación hoy → 1 toque y queda guardado.
- "¿cómo voy?" responde con los mismos números del Inicio.
- Cambiar `InterpreteReglas` por otra implementación no requiere tocar la UI (test con un intérprete falso).
