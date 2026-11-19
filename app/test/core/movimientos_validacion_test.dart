import 'package:app/core/movimientos_validacion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validarCreacionMovimiento', () {
    final ahora = DateTime(2026, 11, 18, 12);
    const diaInicio = 1;

    test('acepta gasto válido del período vigente', () {
      final r = validarCreacionMovimiento(
        tipo: 'gasto',
        monto: 25000,
        categoria: 'alimentacion',
        fecha: DateTime(2026, 11, 18),
        ahora: ahora,
        diaInicioPeriodo: diaInicio,
        periodoId: '2026-11-01',
      );
      expect(r.esValido, isTrue);
    });

    test('rechaza monto <= 0', () {
      final r = validarCreacionMovimiento(
        tipo: 'gasto',
        monto: 0,
        categoria: 'alimentacion',
        fecha: DateTime(2026, 11, 18),
        ahora: ahora,
        diaInicioPeriodo: diaInicio,
        periodoId: '2026-11-01',
      );
      expect(r.esValido, isFalse);
    });

    test('rechaza fecha de otro período', () {
      final r = validarCreacionMovimiento(
        tipo: 'gasto',
        monto: 1000,
        categoria: 'ocio',
        fecha: DateTime(2026, 10, 15),
        ahora: ahora,
        diaInicioPeriodo: diaInicio,
        periodoId: '2026-10-01',
      );
      // 18 nov: período anterior cerró 31 oct; margen 48h ya pasó.
      expect(r.esValido, isFalse);
    });

    test('rechaza categoría de ingreso en gasto', () {
      final r = validarCreacionMovimiento(
        tipo: 'gasto',
        monto: 1000,
        categoria: 'salario',
        fecha: DateTime(2026, 11, 18),
        ahora: ahora,
        diaInicioPeriodo: diaInicio,
        periodoId: '2026-11-01',
      );
      expect(r.esValido, isFalse);
    });

    test('acepta pagoCuota con deudaId y sin categoría', () {
      final r = validarCreacionMovimiento(
        tipo: 'pagoCuota',
        monto: 150000,
        categoria: null,
        deudaId: 'deuda-banco',
        fecha: DateTime(2026, 11, 18),
        ahora: ahora,
        diaInicioPeriodo: diaInicio,
        periodoId: '2026-11-01',
      );
      expect(r.esValido, isTrue);
    });

    test('rechaza pagoCuota sin deudaId', () {
      final r = validarCreacionMovimiento(
        tipo: 'pagoCuota',
        monto: 150000,
        categoria: null,
        fecha: DateTime(2026, 11, 18),
        ahora: ahora,
        diaInicioPeriodo: diaInicio,
        periodoId: '2026-11-01',
      );
      expect(r.esValido, isFalse);
    });
  });

  group('puedeEdicionMenor', () {
    test('permite dentro de 24 h en período vigente', () {
      final creado = DateTime(2026, 11, 18, 10);
      final ahora = DateTime(2026, 11, 18, 20);
      expect(
        puedeEdicionMenor(
          autorUid: 'u1',
          uidActual: 'u1',
          creadoEn: creado,
          ahora: ahora,
          diaInicioPeriodo: 1,
          periodoIdMovimiento: '2026-11-01',
        ),
        isTrue,
      );
    });

    test('rechaza a las 25 h', () {
      final creado = DateTime(2026, 11, 17, 10);
      final ahora = DateTime(2026, 11, 18, 12);
      expect(
        puedeEdicionMenor(
          autorUid: 'u1',
          uidActual: 'u1',
          creadoEn: creado,
          ahora: ahora,
          diaInicioPeriodo: 1,
          periodoIdMovimiento: '2026-11-01',
        ),
        isFalse,
      );
    });

    test('rechaza si no es el autor', () {
      expect(
        puedeEdicionMenor(
          autorUid: 'u1',
          uidActual: 'u2',
          creadoEn: DateTime(2026, 11, 18, 10),
          ahora: DateTime(2026, 11, 18, 11),
          diaInicioPeriodo: 1,
          periodoIdMovimiento: '2026-11-01',
        ),
        isFalse,
      );
    });
  });

  group('esDiaEsperadoGastoFijo', () {
    test('día 5 de noviembre', () {
      expect(
        esDiaEsperadoGastoFijo(
          ahora: DateTime(2026, 11, 5),
          diaEsperado: 5,
        ),
        isTrue,
      );
      expect(
        esDiaEsperadoGastoFijo(
          ahora: DateTime(2026, 11, 6),
          diaEsperado: 5,
        ),
        isFalse,
      );
    });

    test('día 31 en febrero usa último día del mes', () {
      expect(
        esDiaEsperadoGastoFijo(
          ahora: DateTime(2026, 2, 28),
          diaEsperado: 31,
        ),
        isTrue,
      );
    });
  });
}
