import 'package:app/core/periodo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('periodoDe, diasTranscurridos y diasRestantes (docs/02_reglas_negocio.md)', () {
    test('Ejemplo oficial de docs/02_reglas_negocio.md: D = 15, hoy = 2026-11-25', () {
      final hoy = DateTime(2026, 11, 25, 14, 30);
      final p = periodoDe(hoy, 15);

      expect(p.periodoId, '2026-11-15');
      expect(p.inicio, DateTime(2026, 11, 15, 0, 0, 0, 0));
      expect(p.fin, DateTime(2026, 12, 14, 23, 59, 59, 999));
      expect(p.diasTotales, 30);
      expect(diasTranscurridos(p, hoy), 11);
      expect(diasRestantes(p, hoy), 20);
    });

    test('D = 1 corresponde al mes calendario completo', () {
      final pNov = periodoDe(DateTime(2026, 11, 18), 1);
      expect(pNov.periodoId, '2026-11-01');
      expect(pNov.inicio, DateTime(2026, 11, 1));
      expect(pNov.fin, DateTime(2026, 11, 30, 23, 59, 59, 999));
      expect(pNov.diasTotales, 30);

      final pDic = periodoDe(DateTime(2026, 12, 31), 1);
      expect(pDic.periodoId, '2026-12-01');
      expect(pDic.diasTotales, 31);
    });

    test('D = 15 cuando la fecha es anterior al día 15 toma el período que inició el mes anterior', () {
      final p = periodoDe(DateTime(2026, 11, 10), 15);
      expect(p.periodoId, '2026-10-15');
      expect(p.inicio, DateTime(2026, 10, 15));
      expect(p.fin, DateTime(2026, 11, 14, 23, 59, 59, 999));
      expect(p.diasTotales, 31); // Octubre tiene 31 días
    });

    test('D = 28 y cruce de año (diciembre -> enero, y primeros días de enero -> diciembre anterior)', () {
      final pDic = periodoDe(DateTime(2026, 12, 29), 28);
      expect(pDic.periodoId, '2026-12-28');
      expect(pDic.inicio, DateTime(2026, 12, 28));
      expect(pDic.fin, DateTime(2027, 1, 27, 23, 59, 59, 999));
      expect(pDic.diasTotales, 31);

      final pEneAntesDe28 = periodoDe(DateTime(2027, 1, 10), 28);
      expect(pEneAntesDe28.periodoId, '2026-12-28');
      expect(pEneAntesDe28.fin, DateTime(2027, 1, 27, 23, 59, 59, 999));
    });

    test('Febrero no bisiesto (2026) vs Febrero bisiesto (2028) con D = 28 y D = 1', () {
      // Año no bisiesto 2026: 28 feb -> 27 mar (28 días)
      final pNoBisiesto = periodoDe(DateTime(2026, 2, 28), 28);
      expect(pNoBisiesto.periodoId, '2026-02-28');
      expect(pNoBisiesto.fin, DateTime(2026, 3, 27, 23, 59, 59, 999));
      expect(pNoBisiesto.diasTotales, 28);

      // Año bisiesto 2028: 28 feb -> 27 mar (29 días porque feb 2028 tiene 29 días)
      final pBisiesto = periodoDe(DateTime(2028, 2, 28), 28);
      expect(pBisiesto.periodoId, '2028-02-28');
      expect(pBisiesto.fin, DateTime(2028, 3, 27, 23, 59, 59, 999));
      expect(pBisiesto.diasTotales, 29);

      // Mes calendario feb bisiesto (D = 1)
      final pFebBisiestoCal = periodoDe(DateTime(2028, 2, 15), 1);
      expect(pFebBisiestoCal.periodoId, '2028-02-01');
      expect(pFebBisiestoCal.fin, DateTime(2028, 2, 29, 23, 59, 59, 999));
      expect(pFebBisiestoCal.diasTotales, 29);
    });

    test('Borde de medianoche en Bogotá cuando el DateTime viene en UTC', () {
      // 2026-11-15 03:00:00 UTC equivale a 2026-11-14 22:00:00 en Bogotá (UTC-5)
      final utcAntesDeMedianocheBogota = DateTime.utc(2026, 11, 15, 3, 0, 0);
      final pAntes = periodoDe(utcAntesDeMedianocheBogota, 15);
      expect(pAntes.periodoId, '2026-10-15');

      // 2026-11-15 05:00:00 UTC equivale a 2026-11-15 00:00:00 en Bogotá (UTC-5)
      final utcMedianocheBogota = DateTime.utc(2026, 11, 15, 5, 0, 0);
      final pDespues = periodoDe(utcMedianocheBogota, 15);
      expect(pDespues.periodoId, '2026-11-15');
    });

    test('Lanza ArgumentError si diaInicio está fuera de [1, 28]', () {
      expect(() => periodoDe(DateTime(2026, 11, 18), 0), throwsArgumentError);
      expect(() => periodoDe(DateTime(2026, 11, 18), 29), throwsArgumentError);
    });
  });

  group('Formato humano de períodos y fechas (C3/C4)', () {
    test('formatearRangoPeriodo y formatearRangoDesdePeriodoId', () {
      final p15 = periodoDe(DateTime(2026, 11, 25), 15);
      expect(formatearRangoPeriodo(p15), '15 nov – 14 dic');
      expect(formatearRangoDesdePeriodoId('2026-11-15'), '15 nov – 14 dic');
      expect(formatearRangoDesdePeriodoId('2026-11-01'), '1 nov – 30 nov');
    });

    test('formatearFechaHumana devuelve hoy, ayer, día corto o fecha corta', () {
      final ahora = DateTime(2026, 11, 19, 15, 0);
      expect(formatearFechaHumana(DateTime(2026, 11, 19, 9, 0), ahora), 'hoy');
      expect(formatearFechaHumana(DateTime(2026, 11, 18, 20, 0), ahora), 'ayer');
      expect(
        formatearFechaHumana(DateTime(2026, 11, 16, 10, 0), ahora),
        'lun 16',
      );
      expect(
        formatearFechaHumana(DateTime(2026, 11, 2, 10, 0), ahora),
        '2 nov',
      );
    });
  });
}
