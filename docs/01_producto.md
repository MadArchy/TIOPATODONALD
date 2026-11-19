# 01 — Producto (MVP consolidado)

Versión: 2026-11-18. Consolida `PRODUCTO.md` + entrevista (secciones 1–7, en `docs/entrevista/`).

## Visión

Un hogar ve en un solo lugar quién gasta y en qué, cuánto entra y sale, qué deudas pesan y
si cada quien va en **verde** o **rojo** frente a su presupuesto. Transparencia "como una dieta",
no camisa de fuerza. Más adelante, un asistente de IA sugiere mejoras.

## Nombre

"PATO DONALD" es el nombre interno del piloto familiar. Es un personaje registrado de Disney:
**no publicar en Google Play con ese nombre**. Elegir nombre propio antes de cualquier
publicación abierta (pregunta abierta en `07_decisiones.md`).

## Usuarios

| Rol | Puede |
| --- | --- |
| Admin (uno por hogar, no transferible) | Todo lo del miembro + generar QR, sacar miembros, crear/editar deudas externas, aprobar o rechazar correcciones, ver dashboard de cada miembro y margen real del hogar |
| Miembro | Registrar sus propios gastos, ingresos y pagos de cuota; fijar su presupuesto y día de inicio; ver el historial del hogar; pedir correcciones; crear deudas entre miembros como acreedor |

## Módulos del MVP

| Módulo | Qué hace |
| --- | --- |
| Auth | Email/contraseña + "olvidé mi contraseña" |
| Hogar / QR | Crear hogar, QR de 4 horas, unirse, sacar miembros |
| Movimientos | Gasto, ingreso, pago de cuota; foto de recibo opcional; solo período vigente |
| Presupuesto y período | Monto de gasto por período + día de inicio (1–28) por usuario |
| Home | Gastado, ingresos, cuotas, semáforo, categorías, disponible por día, proyección; dashboard si es admin |
| Gastos fijos | Plantillas que se registran con un toque |
| Deudas externas | Entidad, saldo, cuota, día de pago; el saldo baja con cada pago |
| Deudas entre miembros | Acreedor crea, deudor acepta, pagos confirmados por el acreedor |
| Correcciones | Solicitud → admin aprueba → se actualiza + auditoría |
| Ediciones menores | Nota o categoría por el autor en < 24 h, con auditoría |
| Chat Nivel 1 | Registrar y preguntar escribiendo; intérprete por reglas, sin IA |
| Avisos | Alertas 50/80/100%, recordatorio diario, cuotas por vencer, correcciones pendientes |
| Offline | Lectura y escritura sin internet |

## Fuera del MVP

Metas y gamificación · perfil hijo · IA activa (solo se dejan las "puertas") · login social ·
multi-moneda · iOS · exportar CSV · presupuesto por categoría.

## Criterio de éxito del piloto

La familia usa la app durante **un período completo**: todos registran, el home responde
"¿cómo voy?" sin hojas de cálculo, y nadie puede reescribir el historial sin pasar por el admin.
