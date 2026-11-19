# PATO DONALD — kit de arranque para Antigravity y Cursor

App Android de finanzas del hogar (Flutter + Firebase). Este repo todavía no tiene código:
trae las reglas para los agentes, la especificación del MVP y un prompt por slice para
que Antigravity o Cursor construyan la app paso a paso.

## Qué hay aquí

```
AGENTS.md                 Reglas comunes. Las leen Antigravity y Cursor.
.agents/rules/            Reglas por tema para Antigravity (flutter, firebase, negocio)
.agents/workflows/        Comandos /iniciar-slice, /cerrar-slice, /revisar-reglas (Antigravity)
.cursor/rules/*.mdc       Las mismas reglas por tema, con frontmatter para Cursor
.cursor/commands/         Los mismos tres comandos para Cursor
docs/                     Fuente de verdad del MVP (01 producto … 08 operación, CHANGELOG)
docs/entrevista/          Documentos originales de la entrevista
prompts/                  Un prompt por slice (00 a 09)
```

Las reglas por tema están duplicadas a propósito (`.agents/rules/*.md` y `.cursor/rules/*.mdc`).
Si cambias una, cambia la otra. `AGENTS.md` es uno solo para las dos.

## Cómo arrancar

1. Crea un repo en GitHub y sube esta carpeta tal cual.
2. Ábrela en **Antigravity** o en **Cursor** (la carpeta raíz, no `app/`).
3. Escribe `/iniciar-slice` (o pega el contenido de `prompts/slice-00-base.md` en el chat del agente).
4. Revisa el plan que te propone el agente antes de dejarlo escribir código.
5. Al terminar, `/cerrar-slice`. Prueba en un teléfono real. Commit. Siguiente slice.

## Cómo repartir el trabajo entre las dos herramientas

- **Un slice, una herramienta, una rama.** No pongas a Antigravity y a Cursor a editar la misma rama al mismo tiempo.
- Una forma práctica:
  - **Antigravity** para construir cada slice (plan, implementación por pasos, correr tests).
  - **Cursor** para revisar lo que hizo (`/revisar-reglas`), ajustes finos de UI y corregir tests.
- Si un agente quiere cambiar reglas de negocio, modelo de datos o security rules, primero se actualiza `docs/` y después el código.

## Qué necesitas tú (no lo puede hacer el agente)

- Crear los proyectos `pato-donald-dev` y `pato-donald-prod` en la consola de Firebase y activar el plan Blaze.
- Tener Flutter, Android Studio (SDK), Node 20+ y Firebase CLI instalados.
- Un teléfono Android con depuración USB.
- Cuenta de Google Play Console para la prueba interna (slice 9).

## Decisiones

Las contradicciones de la entrevista se resolvieron con valores por defecto en
`docs/07_decisiones.md`. Si cambias alguna, actualiza ese archivo y `docs/02_reglas_negocio.md`
antes de pedirle código al agente.
