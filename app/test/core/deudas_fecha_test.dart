import 'package:app/core/deudas_fecha.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('proximaFechaPago', () {
    test('si hoy es antes del día de pago, usa este mes', () {
      final f = proximaFechaPago(
        diaPago: 20,
        hoy: DateTime(2026, 11, 10),
      );
      expect(f, DateTime(2026, 11, 20));
    });

    test('si hoy es el día de pago, usa hoy', () {
      final f = proximaFechaPago(
        diaPago: 18,
        hoy: DateTime(2026, 11, 18, 15),
      );
      expect(f, DateTime(2026, 11, 18));
    });

    test('si el día ya pasó, usa el mes siguiente', () {
      final f = proximaFechaPago(
        diaPago: 5,
        hoy: DateTime(2026, 11, 18),
      );
      expect(f, DateTime(2026, 12, 5));
    });

    test('día 31 en febrero → último día del mes', () {
      final f = proximaFechaPago(
        diaPago: 31,
        hoy: DateTime(2026, 2, 1),
      );
      expect(f, DateTime(2026, 2, 28));
    });

    test('día 31 en febrero bisiesto → 29', () {
      final f = proximaFechaPago(
        diaPago: 31,
        hoy: DateTime(2024, 2, 1),
      );
      expect(f, DateTime(2024, 2, 29));
    });

    test('fin de año pasa a enero', () {
      final f = proximaFechaPago(
        diaPago: 10,
        hoy: DateTime(2026, 12, 20),
      );
      expect(f, DateTime(2027, 1, 10));
    });
  });

  group('avanceDeuda', () {
    test('0 si no ha pagado', () {
      expect(
        avanceDeuda(saldoInicial: 1000, saldoActual: 1000),
        0,
      );
    });

    test('fracción pagada', () {
      expect(
        avanceDeuda(saldoInicial: 1000, saldoActual: 250),
        0.75,
      );
    });

    test('1 si saldo en 0', () {
      expect(
        avanceDeuda(saldoInicial: 1000, saldoActual: 0),
        1,
      );
    });
  });
}
