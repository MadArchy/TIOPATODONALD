import 'categorias.dart';
import 'indicadores.dart' show periodoAnteriorDe;
import 'periodo.dart';

/// Días extra tras el fin del período del movimiento (`docs/02_reglas_negocio.md` §6).
const int kDiasExtraPlazoCorreccion = 5;

/// Campos que una solicitud de corrección puede proponer.
const Set<String> kCamposCorreccionPermitidos = <String>{
  'monto',
  'fecha',
  'categoria',
  'estado',
  'tipo',
  'deudaId',
  'nota',
};

/// Reconstruye el [Periodo] a partir de un `periodoId` `YYYY-MM-DD`.
Periodo periodoDesdeId(String periodoId, int diaInicio) {
  final partes = periodoId.split('-');
  if (partes.length != 3) {
    throw ArgumentError.value(periodoId, 'periodoId', 'Formato inválido.');
  }
  final y = int.parse(partes[0]);
  final m = int.parse(partes[1]);
  final d = int.parse(partes[2]);
  final p = periodoDe(DateTime(y, m, d, 12), diaInicio);
  if (p.periodoId != periodoId) {
    throw ArgumentError.value(
      periodoId,
      'periodoId',
      'No coincide con diaInicio $diaInicio.',
    );
  }
  return p;
}

/// ¿Aún se puede pedir/aprobar corrección sobre un movimiento de ese período?
///
/// Plazo = fin del período del movimiento + [kDiasExtraPlazoCorreccion] días.
bool dentroDePlazoCorreccion({
  required String periodoIdMovimiento,
  required int diaInicioDueno,
  required DateTime ahora,
}) {
  final Periodo periodo;
  try {
    periodo = periodoDesdeId(periodoIdMovimiento, diaInicioDueno);
  } on ArgumentError {
    return false;
  }
  final limite =
      periodo.fin.add(const Duration(days: kDiasExtraPlazoCorreccion));
  final ahoraB = aHoraBogota(ahora);
  return !ahoraB.isAfter(limite);
}

/// ¿El período del movimiento es el vigente del dueño o el anterior aún en gracia?
bool periodoMovimientoElegibleParaCorreccion({
  required String periodoIdMovimiento,
  required int diaInicioDueno,
  required DateTime ahora,
}) {
  if (!dentroDePlazoCorreccion(
    periodoIdMovimiento: periodoIdMovimiento,
    diaInicioDueno: diaInicioDueno,
    ahora: ahora,
  )) {
    return false;
  }
  final vigente = periodoDe(ahora, diaInicioDueno);
  if (periodoIdMovimiento == vigente.periodoId) return true;
  final anterior = periodoAnteriorDe(vigente);
  return periodoIdMovimiento == anterior.periodoId;
}

/// Resultado de validar el mapa `cambios` de una solicitud.
class ValidacionCorreccion {
  const ValidacionCorreccion.ok()
      : esValida = true,
        mensaje = null;

  const ValidacionCorreccion.error(this.mensaje) : esValida = false;

  final bool esValida;
  final String? mensaje;
}

/// Valida el mapa de cambios propuestos contra el movimiento actual.
ValidacionCorreccion validarCambiosCorreccion({
  required Map<String, dynamic> cambios,
  required String tipoActual,
  required String estadoActual,
  required String? categoriaActual,
  required String? deudaIdActual,
  required String motivo,
}) {
  final motivoTrim = motivo.trim();
  if (motivoTrim.isEmpty) {
    return const ValidacionCorreccion.error(
      'Escribe el motivo de la corrección.',
    );
  }
  if (cambios.isEmpty) {
    return const ValidacionCorreccion.error(
      'Indica qué quieres corregir.',
    );
  }
  for (final key in cambios.keys) {
    if (!kCamposCorreccionPermitidos.contains(key)) {
      return ValidacionCorreccion.error('No se puede corregir el campo "$key".');
    }
  }
  if (estadoActual == 'anulado') {
    return const ValidacionCorreccion.error(
      'Este movimiento ya está anulado.',
    );
  }

  final tipoNuevo = (cambios['tipo'] as String?) ?? tipoActual;
  final estadoNuevo = (cambios['estado'] as String?) ?? estadoActual;

  if (cambios.containsKey('estado') && estadoNuevo != 'anulado') {
    return const ValidacionCorreccion.error(
      'Solo puedes anular el movimiento (estado: anulado).',
    );
  }

  if (cambios.containsKey('monto')) {
    final monto = cambios['monto'];
    if (monto is! int || monto <= 0) {
      return const ValidacionCorreccion.error(
        'El monto debe ser un entero mayor a \$0.',
      );
    }
  }

  if (cambios.containsKey('tipo')) {
    if (tipoNuevo != 'gasto' &&
        tipoNuevo != 'ingreso' &&
        tipoNuevo != 'pagoCuota') {
      return const ValidacionCorreccion.error('Tipo de movimiento no válido.');
    }
  }

  final categoriaNueva = cambios.containsKey('categoria')
      ? cambios['categoria'] as String?
      : categoriaActual;
  final deudaIdNueva = cambios.containsKey('deudaId')
      ? cambios['deudaId'] as String?
      : deudaIdActual;

  if (estadoNuevo != 'anulado') {
    if (tipoNuevo == 'pagoCuota') {
      if (deudaIdNueva == null || deudaIdNueva.trim().isEmpty) {
        return const ValidacionCorreccion.error(
          'Elige la deuda del pago de cuota.',
        );
      }
      if (categoriaNueva != null) {
        return const ValidacionCorreccion.error(
          'Un pago de cuota no lleva categoría.',
        );
      }
    } else if (tipoNuevo == 'gasto') {
      if (!CategoriasGasto.esValida(categoriaNueva)) {
        return const ValidacionCorreccion.error(
          'Elige una categoría de gasto válida.',
        );
      }
    } else if (tipoNuevo == 'ingreso') {
      if (!CategoriasIngreso.esValida(categoriaNueva)) {
        return const ValidacionCorreccion.error(
          'Elige una categoría de ingreso válida.',
        );
      }
    }
  }

  return const ValidacionCorreccion.ok();
}

/// Delta a aplicar sobre `saldoActual` de una deuda (positivo = devolver).
class DeltaSaldoDeuda {
  const DeltaSaldoDeuda({required this.deudaId, required this.delta});

  final String deudaId;
  final int delta;
}

/// Resultado del cálculo de saldos al aprobar una corrección.
class ResultadoAjusteSaldoCorreccion {
  const ResultadoAjusteSaldoCorreccion({
    required this.deltas,
    required this.nuevoSaldoAplicado,
  });

  final List<DeltaSaldoDeuda> deltas;
  final bool nuevoSaldoAplicado;
}

/// Calcula el efecto en saldo de deudas al aplicar una corrección.
///
/// - Reclasificar gasto → pagoCuota baja el saldo.
/// - Reclasificar / anular desde pagoCuota lo devuelve si ya estaba aplicado.
/// - Cambio de monto o de deuda en pagoCuota: revierte y reaplica.
ResultadoAjusteSaldoCorreccion calcularAjustesSaldoPorCorreccion({
  required String tipoAntes,
  required String tipoDespues,
  required String estadoDespues,
  required int montoAntes,
  required int montoDespues,
  required String? deudaIdAntes,
  required String? deudaIdDespues,
  required bool saldoAplicadoAntes,
}) {
  final map = <String, int>{};

  void sumar(String? id, int delta) {
    if (id == null || id.isEmpty || delta == 0) return;
    map[id] = (map[id] ?? 0) + delta;
  }

  final eraPagoAplicado = tipoAntes == 'pagoCuota' &&
      saldoAplicadoAntes &&
      deudaIdAntes != null &&
      deudaIdAntes.isNotEmpty;

  final seraPagoActivo = tipoDespues == 'pagoCuota' &&
      estadoDespues == 'activo' &&
      deudaIdDespues != null &&
      deudaIdDespues.isNotEmpty;

  if (eraPagoAplicado) {
    sumar(deudaIdAntes, montoAntes);
  }

  if (seraPagoActivo) {
    sumar(deudaIdDespues, -montoDespues);
  }

  final deltas = map.entries
      .where((e) => e.value != 0)
      .map((e) => DeltaSaldoDeuda(deudaId: e.key, delta: e.value))
      .toList();

  return ResultadoAjusteSaldoCorreccion(
    deltas: deltas,
    nuevoSaldoAplicado: seraPagoActivo,
  );
}

/// Acción de auditoría según quién aprueba y qué cambió.
String accionAuditoriaCorreccion({
  required bool adminCorrigeLoSuyo,
  required bool anula,
}) {
  if (adminCorrigeLoSuyo) return 'correccionAdminPropia';
  if (anula) return 'anulacion';
  return 'correccion';
}
