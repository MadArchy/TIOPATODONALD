import 'package:app/core/utils/clock.dart';
import 'package:app/core/utils/dinero.dart';
import 'package:flutter/services.dart';
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
    test('convierte entradas con puntos, comas y signo pesos a int', () {
      expect(parseCopInput('85000'), 85000);
      expect(parseCopInput('85.000'), 85000);
      expect(parseCopInput('85,000'), 85000);
      expect(parseCopInput('\$1.200.000'), 1200000);
      expect(parseCopInput('\$1,250,000'), 1250000);
      expect(parseCopInput(''), isNull);
    });
  });

  group('CopInputFormatter', () {
    const formatter = CopInputFormatter();

    TextEditingValue aplicar(String texto, {int? cursor}) {
      final pos = cursor ?? texto.length;
      return formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: texto,
          selection: TextSelection.collapsed(offset: pos),
        ),
      );
    }

    test('distingue decenas, centenas, miles y millones con puntos', () {
      expect(aplicar('5').text, '5');
      expect(aplicar('50').text, '50');
      expect(aplicar('500').text, '500');
      expect(aplicar('5000').text, '5.000');
      expect(aplicar('85000').text, '85.000');
      expect(aplicar('500000').text, '500.000');
      expect(aplicar('1250000').text, '1.250.000');
      expect(aplicar('12500000').text, '12.500.000');
    });

    test('limpia símbolos, comas, letras y ceros a la izquierda', () {
      expect(aplicar('\$1,250,000').text, '1.250.000');
      expect(aplicar('0085000').text, '85.000');
      expect(aplicar('abc').text, '');
      expect(aplicar('0').text, '0');
    });

    test('mantiene posición correcta del cursor al escribir', () {
      final res = aplicar('1250000');
      expect(res.text, '1.250.000');
      expect(res.selection.baseOffset, '1.250.000'.length);

      // Cursor después de "12" en "125000" → "125.000", cursor en 2.
      final medio = aplicar('125000', cursor: 2);
      expect(medio.text, '125.000');
      expect(medio.selection.baseOffset, 2);
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
