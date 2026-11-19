/// Lógica pura de períodos presupuestales por usuario en zona horaria America/Bogota (UTC-5).
///
/// Fuente de verdad: `docs/02_reglas_negocio.md` §1 y `.agents/rules/negocio.md`.
/// - Cada usuario tiene `diaInicioPeriodo` ∈ [1, 28]. Por defecto 1.
/// - Período = desde el día D de un mes (00:00:00.000 America/Bogota)
///   hasta el día D−1 del mes siguiente (23:59:59.999 America/Bogota).
///   - D = 15 → 15 nov – 14 dic.
///   - D = 1 → mes calendario (1 nov – 30 nov).
/// - `periodoId` = fecha de inicio en texto `YYYY-MM-DD`.
class Periodo {
  const Periodo({
    required this.inicio,
    required this.fin,
    required this.periodoId,
    required this.diasTotales,
  });

  /// Inicio del período en hora local de Bogotá (00:00:00.000).
  final DateTime inicio;

  /// Fin del período en hora local de Bogotá (23:59:59.999).
  final DateTime fin;

  /// Identificador de texto `YYYY-MM-DD` correspondiente a la fecha de inicio.
  final String periodoId;

  /// Cantidad total de días calendario del período.
  final int diasTotales;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Periodo &&
        other.inicio == inicio &&
        other.fin == fin &&
        other.periodoId == periodoId &&
        other.diasTotales == diasTotales;
  }

  @override
  int get hashCode => Object.hash(inicio, fin, periodoId, diasTotales);

  @override
  String toString() =>
      'Periodo(periodoId: $periodoId, inicio: $inicio, fin: $fin, diasTotales: $diasTotales)';
}

/// Convierte cualquier [DateTime] a su fecha/hora equivalente en America/Bogota (UTC-5).
/// Si el [instante] ya es local (`!instante.isUtc`), toma sus componentes año/mes/día/hora
/// directamente (útil en tests con `DateTime(2026, 11, 25)` o dispositivo en hora de Colombia);
/// si viene en UTC (`instante.isUtc`), le resta 5 horas (America/Bogota no tiene horario de verano).
DateTime aHoraBogota(DateTime instante) {
  if (!instante.isUtc) {
    return instante;
  }
  final bogota = instante.subtract(const Duration(hours: 5));
  return DateTime(
    bogota.year,
    bogota.month,
    bogota.day,
    bogota.hour,
    bogota.minute,
    bogota.second,
    bogota.millisecond,
    bogota.microsecond,
  );
}

String _formatearFechaId(DateTime fecha) {
  final y = fecha.year.toString().padLeft(4, '0');
  final m = fecha.month.toString().padLeft(2, '0');
  final d = fecha.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Calcula el [Periodo] vigente para un [instante] y un [diaInicio] ∈ [1, 28].
Periodo periodoDe(DateTime instante, int diaInicio) {
  if (diaInicio < 1 || diaInicio > 28) {
    throw ArgumentError.value(
      diaInicio,
      'diaInicio',
      'El día de inicio del período debe estar entre 1 y 28.',
    );
  }

  final bogota = aHoraBogota(instante);
  final int anioInicio;
  final int mesInicio;

  if (bogota.day >= diaInicio) {
    anioInicio = bogota.year;
    mesInicio = bogota.month;
  } else {
    if (bogota.month == 1) {
      anioInicio = bogota.year - 1;
      mesInicio = 12;
    } else {
      anioInicio = bogota.year;
      mesInicio = bogota.month - 1;
    }
  }

  final inicio = DateTime(anioInicio, mesInicio, diaInicio, 0, 0, 0, 0);

  // El siguiente período arranca el día D del mes siguiente a las 00:00:00.000
  final int anioSiguiente = mesInicio == 12 ? anioInicio + 1 : anioInicio;
  final int mesSiguiente = mesInicio == 12 ? 1 : mesInicio + 1;
  final inicioSiguiente =
      DateTime(anioSiguiente, mesSiguiente, diaInicio, 0, 0, 0, 0);

  final fin = inicioSiguiente.subtract(const Duration(milliseconds: 1));

  // Usamos DateTime.utc con los componentes calendario para evitar cualquier
  // distorsión por DST del sistema operativo anfitrión al restar fechas.
  final inicioUtcCal = DateTime.utc(inicio.year, inicio.month, inicio.day);
  final siguienteUtcCal = DateTime.utc(
    inicioSiguiente.year,
    inicioSiguiente.month,
    inicioSiguiente.day,
  );
  final diasTotales = siguienteUtcCal.difference(inicioUtcCal).inDays;

  return Periodo(
    inicio: inicio,
    fin: fin,
    periodoId: _formatearFechaId(inicio),
    diasTotales: diasTotales,
  );
}

/// Días transcurridos del período [p] hasta [hoy], contando el día de [hoy].
///
/// Ejemplo (`docs/02_reglas_negocio.md` §2):
/// D = 15, inicio = 2026-11-15, hoy = 2026-11-25 → 11 días transcurridos (del 15 al 25 inclusive).
int diasTranscurridos(Periodo p, DateTime hoy) {
  final bogota = aHoraBogota(hoy);
  final hoyCal = DateTime.utc(bogota.year, bogota.month, bogota.day);
  final inicioCal = DateTime.utc(p.inicio.year, p.inicio.month, p.inicio.day);
  final finCal = DateTime.utc(p.fin.year, p.fin.month, p.fin.day);

  if (hoyCal.isBefore(inicioCal)) {
    return 0;
  }
  if (hoyCal.isAfter(finCal)) {
    return p.diasTotales;
  }
  return hoyCal.difference(inicioCal).inDays + 1;
}

/// Días restantes del período [p] desde [hoy], contando el día de [hoy].
///
/// Ejemplo (`docs/02_reglas_negocio.md` §2):
/// D = 15, fin = 2026-12-14, hoy = 2026-11-25 → 20 días restantes (del 25 nov al 14 dic inclusive).
int diasRestantes(Periodo p, DateTime hoy) {
  final bogota = aHoraBogota(hoy);
  final hoyCal = DateTime.utc(bogota.year, bogota.month, bogota.day);
  final inicioCal = DateTime.utc(p.inicio.year, p.inicio.month, p.inicio.day);
  final finCal = DateTime.utc(p.fin.year, p.fin.month, p.fin.day);

  if (hoyCal.isAfter(finCal)) {
    return 0;
  }
  if (hoyCal.isBefore(inicioCal)) {
    return p.diasTotales;
  }
  return finCal.difference(hoyCal).inDays + 1;
}
