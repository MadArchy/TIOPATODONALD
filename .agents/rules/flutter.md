# Reglas Flutter (app/)

- Estructura por feature: `features/<modulo>/{presentation,application,domain}`. Los widgets no hablan con Firestore: usan un repositorio de `data/`.
- Riverpod para estado (`Notifier`/`AsyncNotifier`); nada de `setState` para datos de negocio.
- Modelos inmutables con `freezed` + `json_serializable`. Montos como `int` (COP).
- Formato de dinero: utilidad única `formatCop(int)` → `$85.000` (separador de miles con punto, sin decimales).
- Entrada de montos: teclado numérico, acepta "85000", "85.000"; nunca decimales.
- Fechas y períodos: usar SOLO `core/periodo.dart` (ver `docs/02_reglas_negocio.md`). No uses `DateTime.now()` directo en la UI: inyecta un `Clock` para poder testear.
- Offline: Firestore con persistencia activada. Toda pantalla debe funcionar sin red para leer y registrar movimientos. Las acciones que requieren servidor (unirse con QR, aprobar corrección, crear deuda) muestran "Necesitas internet para esto" y no se intentan sin conexión.
- Fotos de recibo: comprimir a ~300 KB antes de subir; si no hay red, guardar en cola local y subir al reconectar.
- Usabilidad familiar (prioridad #1):
  - Registrar un gasto = máximo 3 toques desde el Inicio (botón "+", monto, categoría, Guardar).
  - Botones grandes, textos cortos, sin jerga contable ("Te quedan $110.000 por día", no "saldo disponible diario").
  - Todo error se explica en lenguaje simple y dice qué hacer.
  - Accesibilidad: tamaños mínimos de toque 48 dp, contraste AA, soporte a texto grande.
- Colores del semáforo: verde y rojo siempre acompañados de texto o ícono (no solo color).
- Tests: unit tests para lógica, widget tests para formularios clave (nuevo movimiento, presupuesto).
