import 'movimientos_validacion.dart';
import 'periodo.dart';

/// Próxima fecha de pago según [diaPago] (1–31) desde [hoy] en America/Bogota.
/// Si el día no existe en el mes, usa el último día del mes.
/// Si hoy es el día de pago (efectivo), la próxima es la de este mes;
/// si ya pasó, la del mes siguiente.
DateTime proximaFechaPago({
  required int diaPago,
  required DateTime hoy,
}) {
  final bogota = aHoraBogota(hoy);
  final hoySolo = DateTime(bogota.year, bogota.month, bogota.day);

  final diaEsteMes = diaEfectivoEnMes(bogota.year, bogota.month, diaPago);
  final fechaEsteMes = DateTime(bogota.year, bogota.month, diaEsteMes);
  if (!fechaEsteMes.isBefore(hoySolo)) {
    return fechaEsteMes;
  }

  final anioSig = bogota.month == 12 ? bogota.year + 1 : bogota.year;
  final mesSig = bogota.month == 12 ? 1 : bogota.month + 1;
  final diaSig = diaEfectivoEnMes(anioSig, mesSig, diaPago);
  return DateTime(anioSig, mesSig, diaSig);
}

/// Avance pagado / inicial (0.0–1.0). Si inicial ≤ 0, retorna 0.
double avanceDeuda({
  required int saldoInicial,
  required int saldoActual,
}) {
  if (saldoInicial <= 0) return 0;
  final pagado = saldoInicial - saldoActual;
  if (pagado <= 0) return 0;
  if (pagado >= saldoInicial) return 1;
  return pagado / saldoInicial;
}
