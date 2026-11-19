import 'package:app/core/correcciones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dentroDePlazoCorreccion', () {
    test('dentro del período vigente del dueño → true', () {
      // D=15, período 15 nov – 14 dic; movimiento de ese período; hoy 25 nov.
      expect(
        dentroDePlazoCorreccion(
          periodoIdMovimiento: '2026-11-15',
          diaInicioDueno: 15,
          ahora: DateTime(2026, 11, 25, 10),
        ),
        isTrue,
      );
    });

    test('día 5 tras el cierre → aún true; día 6 → false', () {
      // Período fin = 14 dic 23:59:59.999; +5 días → 19 dic.
      expect(
        dentroDePlazoCorreccion(
          periodoIdMovimiento: '2026-11-15',
          diaInicioDueno: 15,
          ahora: DateTime(2026, 12, 19, 23, 59),
        ),
        isTrue,
      );
      expect(
        dentroDePlazoCorreccion(
          periodoIdMovimiento: '2026-11-15',
          diaInicioDueno: 15,
          ahora: DateTime(2026, 12, 20, 0, 0, 1),
        ),
        isFalse,
      );
    });

    test('período muy anterior → false', () {
      expect(
        dentroDePlazoCorreccion(
          periodoIdMovimiento: '2026-09-15',
          diaInicioDueno: 15,
          ahora: DateTime(2026, 11, 25),
        ),
        isFalse,
      );
    });
  });

  group('validarCambiosCorreccion', () {
    test('exige motivo y al menos un cambio', () {
      expect(
        validarCambiosCorreccion(
          cambios: {'monto': 1000},
          tipoActual: 'gasto',
          estadoActual: 'activo',
          categoriaActual: 'alimentacion',
          deudaIdActual: null,
          motivo: '   ',
        ).esValida,
        isFalse,
      );
      expect(
        validarCambiosCorreccion(
          cambios: {},
          tipoActual: 'gasto',
          estadoActual: 'activo',
          categoriaActual: 'alimentacion',
          deudaIdActual: null,
          motivo: 'Me equivoqué',
        ).esValida,
        isFalse,
      );
    });

    test('acepta anular y reclasificar a pagoCuota con deudaId', () {
      expect(
        validarCambiosCorreccion(
          cambios: {'estado': 'anulado'},
          tipoActual: 'gasto',
          estadoActual: 'activo',
          categoriaActual: 'ocio',
          deudaIdActual: null,
          motivo: 'Duplicado',
        ).esValida,
        isTrue,
      );
      expect(
        validarCambiosCorreccion(
          cambios: {
            'tipo': 'pagoCuota',
            'categoria': null,
            'deudaId': 'deuda-1',
          },
          tipoActual: 'gasto',
          estadoActual: 'activo',
          categoriaActual: 'vivienda',
          deudaIdActual: null,
          motivo: 'Era la cuota del banco',
        ).esValida,
        isTrue,
      );
    });

    test('rechaza pagoCuota sin deudaId', () {
      expect(
        validarCambiosCorreccion(
          cambios: {'tipo': 'pagoCuota', 'categoria': null},
          tipoActual: 'gasto',
          estadoActual: 'activo',
          categoriaActual: 'vivienda',
          deudaIdActual: null,
          motivo: 'Cuota',
        ).esValida,
        isFalse,
      );
    });
  });

  group('calcularAjustesSaldoPorCorreccion', () {
    test('gasto → pagoCuota baja el saldo', () {
      final r = calcularAjustesSaldoPorCorreccion(
        tipoAntes: 'gasto',
        tipoDespues: 'pagoCuota',
        estadoDespues: 'activo',
        montoAntes: 200000,
        montoDespues: 200000,
        deudaIdAntes: null,
        deudaIdDespues: 'd1',
        saldoAplicadoAntes: false,
      );
      expect(r.nuevoSaldoAplicado, isTrue);
      expect(r.deltas, hasLength(1));
      expect(r.deltas.first.deudaId, 'd1');
      expect(r.deltas.first.delta, -200000);
    });

    test('pagoCuota → gasto devuelve el saldo', () {
      final r = calcularAjustesSaldoPorCorreccion(
        tipoAntes: 'pagoCuota',
        tipoDespues: 'gasto',
        estadoDespues: 'activo',
        montoAntes: 150000,
        montoDespues: 150000,
        deudaIdAntes: 'd1',
        deudaIdDespues: null,
        saldoAplicadoAntes: true,
      );
      expect(r.nuevoSaldoAplicado, isFalse);
      expect(r.deltas.single.delta, 150000);
    });

    test('anular pagoCuota aplicado lo devuelve', () {
      final r = calcularAjustesSaldoPorCorreccion(
        tipoAntes: 'pagoCuota',
        tipoDespues: 'pagoCuota',
        estadoDespues: 'anulado',
        montoAntes: 80000,
        montoDespues: 80000,
        deudaIdAntes: 'd1',
        deudaIdDespues: 'd1',
        saldoAplicadoAntes: true,
      );
      expect(r.nuevoSaldoAplicado, isFalse);
      expect(r.deltas.single.delta, 80000);
    });

    test('cambio de monto en pagoCuota ajusta la diferencia', () {
      final r = calcularAjustesSaldoPorCorreccion(
        tipoAntes: 'pagoCuota',
        tipoDespues: 'pagoCuota',
        estadoDespues: 'activo',
        montoAntes: 100000,
        montoDespues: 70000,
        deudaIdAntes: 'd1',
        deudaIdDespues: 'd1',
        saldoAplicadoAntes: true,
      );
      expect(r.nuevoSaldoAplicado, isTrue);
      expect(r.deltas.single.delta, 30000); // +100k -70k
    });

    test('cambio de deuda: revierte una y baja la otra', () {
      final r = calcularAjustesSaldoPorCorreccion(
        tipoAntes: 'pagoCuota',
        tipoDespues: 'pagoCuota',
        estadoDespues: 'activo',
        montoAntes: 50000,
        montoDespues: 50000,
        deudaIdAntes: 'd1',
        deudaIdDespues: 'd2',
        saldoAplicadoAntes: true,
      );
      expect(r.deltas, hasLength(2));
      final porId = {for (final d in r.deltas) d.deudaId: d.delta};
      expect(porId['d1'], 50000);
      expect(porId['d2'], -50000);
    });
  });

  group('accionAuditoriaCorreccion', () {
    test('admin propia / anulación / corrección normal', () {
      expect(
        accionAuditoriaCorreccion(adminCorrigeLoSuyo: true, anula: true),
        'correccionAdminPropia',
      );
      expect(
        accionAuditoriaCorreccion(adminCorrigeLoSuyo: false, anula: true),
        'anulacion',
      );
      expect(
        accionAuditoriaCorreccion(adminCorrigeLoSuyo: false, anula: false),
        'correccion',
      );
    });
  });
}
