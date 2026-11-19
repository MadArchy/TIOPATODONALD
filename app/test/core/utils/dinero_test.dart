import 'package:app/core/utils/clock.dart';
import 'package:app/core/utils/dinero.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatCop', () {
    test('formatea 85000 como \$85.000 y 1200000 como \$1.200.000', () {
      expect(formatCop(85000), '\$85.000');
      expect(formatCop(1200000), '\$1.200.000');
    });

    test('formatea 0, cientos, millones y montos negativos correctamente', () {
      expect(formatCop(0), '\$0');
      expect(formatCop(500), '\$500');
      expect(formatCop(4000000), '\$4.000.000');
      expect(formatCop(-85000), '-\$85.000');
    });
  });

  group('parseCopInput', () {
    test('convierte entradas con o sin puntos y signo pesos a int', () {
      expect(parseCopInput('85000'), 85000);
      expect(parseCopInput('85.000'), 85000);
      expect(parseCopInput('\$1.200.000'), 1200000);
      expect(parseCopInput(''), isNull);
    });
  });

  group('Clock inyectable', () {
    test('FixedClock devuelve siempre el instante configurado', () {
      final instante = DateTime(2026, 11, 18, 20, 0);
      final clock = FixedClock(instante);
      expect(clock.now(), instante);
    });
  });
}
