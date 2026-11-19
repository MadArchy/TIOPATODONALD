import 'categorias.dart';
import 'periodo.dart';

/// Ventana de edición menor sin admin (`docs/02_reglas_negocio.md` §6): 24 horas.
const Duration kVentanaEdicionMenor = Duration(hours: 24);

/// Margen offline permitido por rules/cliente para período anterior (48 h).
const Duration kMargenOfflinePeriodoAnterior = Duration(hours: 48);

/// Resultado de validar la creación de un movimiento en el cliente.
class ValidacionMovimiento {
  const ValidacionMovimiento.ok()
      : esValido = true,
        mensaje = null;

  const ValidacionMovimiento.error(this.mensaje) : esValido = false;

  final bool esValido;
  final String? mensaje;
}

/// ¿Se puede editar nota/categoría sin admin?
/// Autor + período vigente del dueño + < 24 h desde [creadoEn].
bool puedeEdicionMenor({
  required String autorUid,
  required String uidActual,
  required DateTime creadoEn,
  required DateTime ahora,
  required int diaInicioPeriodo,
  required String periodoIdMovimiento,
}) {
  if (autorUid != uidActual) return false;
  final vigente = periodoDe(ahora, diaInicioPeriodo);
  if (periodoIdMovimiento != vigente.periodoId) return false;
  return !ahora.isAfter(creadoEn.add(kVentanaEdicionMenor));
}

/// Períodos en los que el usuario puede registrar ahora (vigente + anterior si
/// [ahora] está a menos de 48 h del cierre del anterior).
List<Periodo> periodosPermitidosParaRegistrar({
  required DateTime ahora,
  required int diaInicioPeriodo,
}) {
  final vigente = periodoDe(ahora, diaInicioPeriodo);
  final resultado = <Periodo>[vigente];

  // El período anterior termina 1 ms antes del inicio del vigente.
  final instanteAntes = vigente.inicio.subtract(const Duration(milliseconds: 1));
  final anterior = periodoDe(instanteAntes, diaInicioPeriodo);
  final cierreMasMargen = anterior.fin.add(kMargenOfflinePeriodoAnterior);
  if (!ahora.isAfter(cierreMasMargen)) {
    resultado.add(anterior);
  }
  return resultado;
}

/// Valida creación de gasto/ingreso en el cliente (rules hacen la validación final).
ValidacionMovimiento validarCreacionMovimiento({
  required String tipo,
  required int monto,
  required String? categoria,
  required DateTime fecha,
  required DateTime ahora,
  required int diaInicioPeriodo,
  required String periodoId,
  String? deudaId,
  String nota = '',
}) {
  if (tipo != 'gasto' && tipo != 'ingreso' && tipo != 'pagoCuota') {
    return const ValidacionMovimiento.error('Tipo de movimiento no válido.');
  }
  if (monto <= 0) {
    return const ValidacionMovimiento.error('Escribe un monto mayor a \$0.');
  }
  if (nota.length > 200) {
    return const ValidacionMovimiento.error(
      'La nota puede tener máximo 200 caracteres.',
    );
  }
  if (fecha.isAfter(ahora)) {
    return const ValidacionMovimiento.error(
      'La fecha no puede ser en el futuro.',
    );
  }

  if (tipo == 'pagoCuota') {
    if (categoria != null) {
      return const ValidacionMovimiento.error(
        'El pago de cuota no lleva categoría.',
      );
    }
    if (deudaId == null || deudaId.isEmpty) {
      return const ValidacionMovimiento.error(
        'Falta la deuda del pago de cuota.',
      );
    }
  } else if (!categoriaValidaParaTipo(tipo, categoria)) {
    return const ValidacionMovimiento.error(
      'Elige una categoría válida.',
    );
  }

  final periodoFecha = periodoDe(fecha, diaInicioPeriodo);
  if (periodoFecha.periodoId != periodoId) {
    return const ValidacionMovimiento.error(
      'La fecha no corresponde al período indicado.',
    );
  }

  final permitidos = periodosPermitidosParaRegistrar(
    ahora: ahora,
    diaInicioPeriodo: diaInicioPeriodo,
  );
  final idsPermitidos = permitidos.map((p) => p.periodoId).toSet();
  if (!idsPermitidos.contains(periodoId)) {
    return const ValidacionMovimiento.error(
      'Solo puedes registrar en tu período vigente.',
    );
  }

  if (fecha.isBefore(periodoFecha.inicio) || fecha.isAfter(periodoFecha.fin)) {
    return const ValidacionMovimiento.error(
      'La fecha debe estar dentro del período.',
    );
  }

  return const ValidacionMovimiento.ok();
}

/// Día de calendario a usar para un [diaEsperado] 1–31 (ajusta fin de mes).
int diaEfectivoEnMes(int anio, int mes, int diaEsperado) {
  final ultimo = DateTime(anio, mes + 1, 0).day;
  if (diaEsperado < 1) return 1;
  return diaEsperado > ultimo ? ultimo : diaEsperado;
}

/// ¿Hoy es el día esperado de un gasto fijo (America/Bogota vía [ahora] local)?
bool esDiaEsperadoGastoFijo({
  required DateTime ahora,
  required int diaEsperado,
}) {
  final bogota = aHoraBogota(ahora);
  final efectivo = diaEfectivoEnMes(bogota.year, bogota.month, diaEsperado);
  return bogota.day == efectivo;
}
