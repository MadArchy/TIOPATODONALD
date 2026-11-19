# Slice 9 — Avisos, pulido y piloto familiar

**Objetivo:** la familia usa la app un período completo sin ayuda.

**Lee primero:** `docs/01_producto.md` (criterio de éxito), `docs/02_reglas_negocio.md` §2 (alertas), `docs/08_operacion.md`.

## Construye
1. Push (FCM): alertas 50/80/100, recordatorio diario a la hora elegida, cuota que vence mañana, corrección pendiente (admin), corrección resuelta, deuda interna nueva/pago por confirmar. Function `avisosDiarios`. Ajustes en Perfil para apagar cada tipo.
2. Pulido de usabilidad: revisar cada pantalla con texto grande activado, contraste, mensajes de error, estados vacíos ("Aún no registras nada este período. Toca + para empezar").
3. Onboarding corto (3 pantallas) la primera vez.
4. Ícono, nombre visible "PATO DONALD", splash. Firma de release.
5. Despliegue a `pato-donald-prod`: rules, índices, Functions. Respaldo semanal activado.
6. Google Play: pista de prueba interna con los correos de la familia.
7. Guía de prueba de una página para la familia + formulario simple de comentarios.

## Listo cuando
- Toda la familia instaló desde la prueba interna y registró al menos un movimiento.
- Recibe el recordatorio diario y la alerta del 80%.
- Revisión `/revisar-reglas` sin hallazgos graves.
- Al cerrar el primer período, cada uno ve su tarjeta de cierre.
