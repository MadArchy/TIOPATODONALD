import 'package:app/core/categorias.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoriasGasto / CategoriasIngreso', () {
    test('ids de gasto e ingreso coinciden con docs §3', () {
      expect(
        CategoriasGasto.ids,
        [
          'alimentacion',
          'servicios',
          'transporte',
          'vivienda',
          'salud',
          'educacion',
          'ocio',
          'otros',
        ],
      );
      expect(CategoriasIngreso.ids, ['salario', 'otros_ingreso']);
    });

    test('solo ocio y otros son reducibles', () {
      expect(CategoriasGasto.esReducible('ocio'), isTrue);
      expect(CategoriasGasto.esReducible('otros'), isTrue);
      expect(CategoriasGasto.esReducible('alimentacion'), isFalse);
      expect(CategoriasGasto.esReducible('vivienda'), isFalse);
    });

    test('categoriaValidaParaTipo', () {
      expect(categoriaValidaParaTipo('gasto', 'alimentacion'), isTrue);
      expect(categoriaValidaParaTipo('gasto', 'salario'), isFalse);
      expect(categoriaValidaParaTipo('ingreso', 'salario'), isTrue);
      expect(categoriaValidaParaTipo('ingreso', 'ocio'), isFalse);
      expect(categoriaValidaParaTipo('pagoCuota', null), isTrue);
      expect(categoriaValidaParaTipo('pagoCuota', 'vivienda'), isFalse);
    });

    test('etiquetas en español', () {
      expect(etiquetaCategoria('alimentacion'), 'Alimentación');
      expect(etiquetaCategoria('otros_ingreso'), 'Otros');
      expect(etiquetaCategoria('ocio'), contains('Ocio'));
    });
  });
}
