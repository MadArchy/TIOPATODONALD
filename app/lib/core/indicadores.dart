import 'categorias.dart';
import 'periodo.dart';

/// Semáforo presupuestal (`docs/02_reglas_negocio.md` §2).
enum Semaforo { verde, rojo }

/// Movimiento mínimo para agregar indicadores (evita acoplar a Firestore).
class MovimientoIndicador {
  const MovimientoIndicador({
    required this.tipo,
    required this.monto,
    required this.estado,
    this.categoria,
    this.deudaId,
  });

  final String tipo;
  final int monto;
  final String estado;
  final String? categoria;
  final String? deudaId;
}

/// Deuda externa mínima para cuotas (Slice 5 las llenará; hoy puede ir vacío).
class DeudaCuotaIndicador {
  const DeudaCuotaIndicador({
    required this.id,
    required this.cuotaMensual,
    required this.estado,
  });

  final String id;
  final int cuotaMensual;
  final String estado;
}

/// Σ monto de `gasto` + `pagoCuota` con `estado == activo`.
int gastado(Iterable<MovimientoIndicador> movimientos) {
  var total = 0;
  for (final m in movimientos) {
    if (m.estado != 'activo') continue;
    if (m.tipo == 'gasto' || m.tipo == 'pagoCuota') {
      total += m.monto;
    }
  }
  return total;
}

/// Σ monto de `ingreso` con `estado == activo`.
int ingresos(Iterable<MovimientoIndicador> movimientos) {
  var total = 0;
  for (final m in movimientos) {
    if (m.estado != 'activo') continue;
    if (m.tipo == 'ingreso') {
      total += m.monto;
    }
  }
  return total;
}

/// presupuesto − gastado (puede ser negativo).
int disponible({required int presupuesto, required int gastado}) {
  return presupuesto - gastado;
}

/// max(0, disponible) ÷ diasRestantes, redondeo hacia abajo a pesos.
/// Si no quedan días, retorna 0.
int disponiblePorDia({
  required int disponible,
  required int diasRestantes,
}) {
  if (diasRestantes <= 0) return 0;
  final positivo = disponible < 0 ? 0 : disponible;
  return positivo ~/ diasRestantes;
}

/// gastado ÷ diasTranscurridos × diasPeriodo; solo si diasTranscurridos ≥ 3.
/// Truncación hacia abajo (ej. 1.800.000/11*30 → 4.909.090).
/// Retorna `null` si aún no aplica.
int? proyeccion({
  required int gastado,
  required int diasTranscurridos,
  required int diasPeriodo,
}) {
  if (diasTranscurridos < 3) return null;
  if (diasTranscurridos <= 0 || diasPeriodo <= 0) return null;
  return (gastado * diasPeriodo) ~/ diasTranscurridos;
}

Semaforo semaforo({required int gastado, required int presupuesto}) {
  return gastado <= presupuesto ? Semaforo.verde : Semaforo.rojo;
}

/// proyeccion > presupuesto y semáforo verde.
bool avisoPreventivo({
  required int? proyeccion,
  required int presupuesto,
  required Semaforo semaforo,
}) {
  if (proyeccion == null) return false;
  return proyeccion > presupuesto && semaforo == Semaforo.verde;
}

/// Σ gastos en categorías reducibles ÷ gastado. 0 si gastado es 0.
/// Retorna fracción 0.0–1.0 (no porcentaje entero).
double porcentajeReducible({
  required Iterable<MovimientoIndicador> movimientos,
  required int gastado,
}) {
  if (gastado <= 0) return 0;
  var reducible = 0;
  for (final m in movimientos) {
    if (m.estado != 'activo') continue;
    if (m.tipo != 'gasto') continue;
    final cat = m.categoria;
    if (cat != null && CategoriasGasto.esReducible(cat)) {
      reducible += m.monto;
    }
  }
  return reducible / gastado;
}

/// Σ `cuotaMensual` de deudas externas con `estado == activa`.
int cuotasComprometidas(Iterable<DeudaCuotaIndicador> deudas) {
  var total = 0;
  for (final d in deudas) {
    if (d.estado == 'activa') {
      total += d.cuotaMensual;
    }
  }
  return total;
}

/// Σ `cuotaMensual` de deudas activas sin `pagoCuota` en el período (del admin).
int cuotasPendientes({
  required Iterable<DeudaCuotaIndicador> deudas,
  required Iterable<MovimientoIndicador> movimientosPeriodoAdmin,
}) {
  final pagadas = <String>{};
  for (final m in movimientosPeriodoAdmin) {
    if (m.estado != 'activo') continue;
    if (m.tipo != 'pagoCuota') continue;
    final id = m.deudaId;
    if (id != null && id.isNotEmpty) {
      pagadas.add(id);
    }
  }

  var total = 0;
  for (final d in deudas) {
    if (d.estado != 'activa') continue;
    if (pagadas.contains(d.id)) continue;
    total += d.cuotaMensual;
  }
  return total;
}

/// ingresos hogar − gastado hogar − cuotasPendientes.
int margenReal({
  required int ingresosHogar,
  required int gastadoHogar,
  required int cuotasPendientes,
}) {
  return ingresosHogar - gastadoHogar - cuotasPendientes;
}

/// Umbrales de alerta presupuestal (50, 80, 100) aún no enviados.
/// Una vez cada uno por período.
List<int> alertasNuevas({
  required int gastado,
  required int presupuesto,
  required List<int> alertasEnviadas,
}) {
  if (presupuesto <= 0) return const <int>[];
  final ratio = gastado / presupuesto;
  final ya = alertasEnviadas.toSet();
  final nuevas = <int>[];
  for (final umbral in const [50, 80, 100]) {
    if (ya.contains(umbral)) continue;
    if (ratio * 100 >= umbral) {
      nuevas.add(umbral);
    }
  }
  return nuevas;
}

/// Desglose de gasto (+ pagoCuota como "Cuotas") por categoría.
/// Solo movimientos activos de tipo gasto; pagoCuota se agrupa en clave `pagoCuota`.
Map<String, int> gastadoPorCategoria(Iterable<MovimientoIndicador> movimientos) {
  final map = <String, int>{};
  for (final m in movimientos) {
    if (m.estado != 'activo') continue;
    if (m.tipo == 'gasto') {
      final cat = m.categoria ?? CategoriasGasto.otros;
      map[cat] = (map[cat] ?? 0) + m.monto;
    } else if (m.tipo == 'pagoCuota') {
      map['pagoCuota'] = (map['pagoCuota'] ?? 0) + m.monto;
    }
  }
  return map;
}

/// Indicadores del usuario en su período vigente.
class IndicadoresPeriodo {
  const IndicadoresPeriodo({
    required this.presupuesto,
    required this.gastado,
    required this.ingresos,
    required this.disponible,
    required this.disponiblePorDia,
    required this.proyeccion,
    required this.semaforo,
    required this.avisoPreventivo,
    required this.porcentajeReducible,
    required this.diasPeriodo,
    required this.diasTranscurridos,
    required this.diasRestantes,
    required this.porCategoria,
  });

  final int presupuesto;
  final int gastado;
  final int ingresos;
  final int disponible;
  final int disponiblePorDia;
  final int? proyeccion;
  final Semaforo semaforo;
  final bool avisoPreventivo;
  final double porcentajeReducible;
  final int diasPeriodo;
  final int diasTranscurridos;
  final int diasRestantes;
  final Map<String, int> porCategoria;
}

/// Calcula todos los indicadores personales a partir de movimientos y período.
IndicadoresPeriodo calcularIndicadoresPeriodo({
  required int presupuesto,
  required Iterable<MovimientoIndicador> movimientos,
  required Periodo periodo,
  required DateTime hoy,
}) {
  final g = gastado(movimientos);
  final ing = ingresos(movimientos);
  final disp = disponible(presupuesto: presupuesto, gastado: g);
  final restantes = diasRestantes(periodo, hoy);
  final transcurridos = diasTranscurridos(periodo, hoy);
  final proy = proyeccion(
    gastado: g,
    diasTranscurridos: transcurridos,
    diasPeriodo: periodo.diasTotales,
  );
  final sem = semaforo(gastado: g, presupuesto: presupuesto);
  return IndicadoresPeriodo(
    presupuesto: presupuesto,
    gastado: g,
    ingresos: ing,
    disponible: disp,
    disponiblePorDia: disponiblePorDia(
      disponible: disp,
      diasRestantes: restantes,
    ),
    proyeccion: proy,
    semaforo: sem,
    avisoPreventivo: avisoPreventivo(
      proyeccion: proy,
      presupuesto: presupuesto,
      semaforo: sem,
    ),
    porcentajeReducible: porcentajeReducible(
      movimientos: movimientos,
      gastado: g,
    ),
    diasPeriodo: periodo.diasTotales,
    diasTranscurridos: transcurridos,
    diasRestantes: restantes,
    porCategoria: gastadoPorCategoria(movimientos),
  );
}

/// Período inmediatamente anterior al [actual] (mismo día de inicio D).
Periodo periodoAnteriorDe(Periodo actual) {
  final diaInicio = actual.inicio.day;
  final instanteAnterior = actual.inicio.subtract(const Duration(days: 1));
  return periodoDe(instanteAnterior, diaInicio);
}
