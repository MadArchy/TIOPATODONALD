# 07 — Decisiones tomadas por defecto y preguntas abiertas

La entrevista dejó choques entre secciones. Se resolvieron con estas propuestas por defecto.
Si el product owner cambia alguna, actualizar aquí y en `02_reglas_negocio.md`.

## Resueltas por defecto

| # | Tema | Decisión adoptada |
| --- | --- | --- |
| 1 | Nombre | "PATO DONALD" solo interno; nombre propio antes de publicar |
| 2 | Período por usuario vs datos del hogar | Cada dato se mide con el período de su dueño; dashboard muestra a cada miembro en su período; totales del hogar con el período del admin |
| 3 | Cambio de día de inicio | Se guarda en `diaInicioPendiente` y nunca parte el período actual. Al cerrar el período vigente, si aún no es el día D nuevo, corre un **período puente** hasta el día D nuevo copiando automáticamente el presupuesto vigente (para que la familia no quede bloqueada ni pierda días); al llegar el día D nuevo, `cerrarPeriodos` cierra el puente, aplica `diaInicioPeriodo = D nuevo`, guarda `diaInicioAnterior` para tolerar movimientos offline en transición y copia el presupuesto vigente si aún no existe |
| 4 | Ediciones menores | Nota o categoría (gasto→gasto), autor, < 24 h, período vigente; con auditoría |
| 5 | Ventana de corrección | Período vigente + 5 días |
| 6 | Admin se corrige a sí mismo | Se aplica y se notifica a todos |
| 7 | Deudas entre miembros | Crea el acreedor, acepta el deudor, pagos confirmados por el acreedor |
| 8 | Doble conteo de cuotas | Tipo "Pago de cuota" propio; la corrección queda para errores |
| 9 | Cuota en el semáforo | Sí cuenta como gastado; se muestra aparte |
| 10 | Offline vs servidor | Movimientos y fotos offline; QR, correcciones y deudas requieren red |
| 11 | Admin pierde acceso | Correo; si no, reasignación manual por el desarrollador |
| 12 | Probar todo junto | Prueba oficial con todo, pero cada slice se muestra a 1 persona |
| 13 | Mejoras 1–8 | Entran al MVP (disponible/día, proyección, alertas, gastos fijos, recordatorio, reducible, resumen de cierre, margen real) |
| 14 | Chat Nivel 1 + puertas de IA | Entran al MVP (slice 8) |
| 15 | Visibilidad | Todos ven los movimientos del hogar; solo editan los suyos |

## Abiertas

- [ ] Nombre definitivo para publicar.
- [ ] Avisos por push (FCM) o solo dentro de la app. Por defecto: push.
- [ ] Quién pone la tarjeta del plan Blaze.
- [ ] ¿Tercera categoría de ingreso (p. ej. "Independiente")?
- [ ] Proveedor de IA para la Etapa 4.
