# Slice 1 — Auth

**Objetivo:** una persona crea su cuenta, entra, sale y recupera su contraseña.

**Lee primero:** `docs/02_reglas_negocio.md` §9, `docs/03_modelo_datos.md` (`usuarios`), `docs/04_seguridad_y_functions.md` (fila `usuarios`).

## Construye
1. Pantallas: Bienvenida → Registro (nombre, correo, contraseña) · Login · Olvidé mi contraseña · Cerrar sesión (en Perfil provisional).
2. Al registrarse: crear `usuarios/{uid}` con `diaInicioPeriodo: 1`, `hogarId: null`.
3. Router con guardas: sin sesión → Bienvenida; con sesión y `hogarId == null` → pantalla "Crea o únete a un hogar" (vacía por ahora); con hogar → Inicio (vacío).
4. Mensajes de error en español claro: correo ya registrado, contraseña débil (mínimo 8), correo o contraseña incorrectos, sin internet.
5. Rules para `usuarios` + tests.

## Fuera de alcance
Login social, verificación obligatoria de correo, hogar.

## Listo cuando
- Registro, login, logout y correo de recuperación funcionan en el teléfono.
- Un usuario no puede leer ni escribir el `usuarios` de otro (test de rules).
- Un usuario no puede escribir su propio `hogarId` (test de rules).
- Una persona de la familia crea su cuenta sin ayuda.
