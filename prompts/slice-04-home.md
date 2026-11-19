# Slice 4 — Home, presupuesto y dashboard admin

**Objetivo:** al abrir la app cada uno sabe cómo va su período y qué hacer; el admin ve a todos.

**Lee primero:** `docs/02_reglas_negocio.md` §1, §2, §3; `docs/03_modelo_datos.md` (presupuestos, resumenes).

## Construye
1. `core/indicadores.dart`: funciones puras para gastado, ingresos, disponible, disponiblePorDia, proyeccion, semaforo, avisoPreventivo, porcentajeReducible, cuotasComprometidas, cuotasPendientes, margenReal. Tests con el ejemplo de `02_reglas_negocio.md` y bordes (día 1, día 2, último día, presupuesto 0, sin movimientos).
2. Inicio (de arriba hacia abajo):
   - Semáforo grande con texto: "Vas bien" / "Te pasaste por $X" + ícono.
   - "Te quedan $110.000 por día" (o "Ya usaste todo tu presupuesto").
   - Barra gastado / presupuesto con 50 / 80 / 100%.
   - Aviso preventivo: "A este ritmo terminas en $4.909.090".
   - Ingresos del período · cuotas comprometidas (si hay deudas, slice 5 las llena).
   - Desglose por categorías (barras horizontales), con % reducible.
   - Tarjetas de gastos fijos por registrar.
3. Perfil: cambiar presupuesto (auditoría `cambioPresupuesto`) y día de inicio (queda en `diaInicioPendiente`, se muestra "Aplica desde el 15 dic").
4. Admin → Dashboard: una tarjeta por miembro con su semáforo, gastado/presupuesto en su propio período, % reducible; tocar abre su desglose. Encima: margen real del hogar.
5. Alertas 50/80/100 en la app (banner) — el push llega en slice 9.
6. Function programada `cerrarPeriodos`: genera `resumenes/{uid}_{periodoId}` y aplica `diaInicioPendiente`. Tarjeta "Cierre de tu período" en el Inicio el primer día del nuevo período.

## Listo cuando
- Pasarse del presupuesto pone rojo con texto, no solo color.
- Los números del Inicio coinciden con los tests del ejemplo.
- El admin ve a cada miembro en su propio período (dos miembros con D distinto, test de widget o integración).
- Funciona offline con los datos en caché.
- Una persona de la familia, sin explicación, responde "¿cuánto puedes gastar hoy?" mirando el Inicio.
