import 'package:app/core/categorias.dart';
import 'package:app/features/chat/domain/intencion.dart';
import 'package:app/features/chat/domain/interprete.dart';
import 'package:app/features/chat/domain/interprete_reglas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const interprete = InterpreteReglas();
  final deudas = <DeudaContextoChat>[
    const DeudaContextoChat(
      id: 'd-banco',
      entidad: 'Banco Bogotá',
      saldoActual: 5000000,
      diaPago: 15,
    ),
    const DeudaContextoChat(
      id: 'd-carro',
      entidad: 'Crédito carro',
      saldoActual: 12000000,
      diaPago: 5,
    ),
  ];

  ContextoUsuario ctx({DateTime? ahora}) => ContextoUsuario(
        ahora: ahora ?? DateTime(2026, 11, 19, 10),
        diaInicioPeriodo: 1,
        presupuesto: 4000000,
        gastado: 1800000,
        disponiblePorDia: 183333,
        gastadoPorCategoria: const {
          CategoriasGasto.alimentacion: 400000,
          CategoriasGasto.transporte: 120000,
        },
        deudas: deudas,
      );

  Future<Intencion> interp(String frase) =>
      interprete.interpretar(frase, ctx());

  group('parseMontoChat', () {
    test('formatos comunes COP', () {
      expect(parseMontoChat('gaste 85 mil'), 85000);
      expect(parseMontoChat('85000'), 85000);
      expect(parseMontoChat(r'$85.000'), 85000);
      expect(parseMontoChat('1,2 millones'), 1200000);
      expect(parseMontoChat('1.2 M'), 1200000);
      expect(parseMontoChat('un millón en arriendo'), 1000000);
      expect(parseMontoChat('2 millones'), 2000000);
    });
  });

  group('tabla familiar ≥ 60 frases (≥ 90% acierto)', () {
    final casos = <({String frase, String accion, String? tipo, int? monto, String? categoria})>[
      // Gastos alimentación
      (frase: 'gasté 85 mil en mercado', accion: 'proponerMovimiento', tipo: 'gasto', monto: 85000, categoria: 'alimentacion'),
      (frase: 'compré 40 mil de almuerzo', accion: 'proponerMovimiento', tipo: 'gasto', monto: 40000, categoria: 'alimentacion'),
      (frase: 'pagué 120 mil en el supermercado', accion: 'proponerMovimiento', tipo: 'gasto', monto: 120000, categoria: 'alimentacion'),
      (frase: 'gaste 25 mil en restaurante', accion: 'proponerMovimiento', tipo: 'gasto', monto: 25000, categoria: 'alimentacion'),
      (frase: 'me gasté 15 mil en café', accion: 'proponerMovimiento', tipo: 'gasto', monto: 15000, categoria: 'alimentacion'),
      (frase: 'desayuno 12 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 12000, categoria: 'alimentacion'),
      (frase: 'gaste 8 mil en pan', accion: 'proponerMovimiento', tipo: 'gasto', monto: 8000, categoria: 'alimentacion'),
      (frase: 'en el mercado 95.000', accion: 'proponerMovimiento', tipo: 'gasto', monto: 95000, categoria: 'alimentacion'),
      // Transporte
      (frase: 'uber 18 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 18000, categoria: 'transporte'),
      (frase: 'gasté 50 mil en gasolina', accion: 'proponerMovimiento', tipo: 'gasto', monto: 50000, categoria: 'transporte'),
      (frase: 'pagué 3 mil de bus', accion: 'proponerMovimiento', tipo: 'gasto', monto: 3000, categoria: 'transporte'),
      (frase: 'taxi 22 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 22000, categoria: 'transporte'),
      (frase: 'gaste 10 mil en transmilenio', accion: 'proponerMovimiento', tipo: 'gasto', monto: 10000, categoria: 'transporte'),
      (frase: 'peaje 16000', accion: 'proponerMovimiento', tipo: 'gasto', monto: 16000, categoria: 'transporte'),
      // Servicios / vivienda
      (frase: 'pagué 180 mil de luz', accion: 'proponerMovimiento', tipo: 'gasto', monto: 180000, categoria: 'servicios'),
      (frase: 'agua 65000', accion: 'proponerMovimiento', tipo: 'gasto', monto: 65000, categoria: 'servicios'),
      (frase: 'internet 89000', accion: 'proponerMovimiento', tipo: 'gasto', monto: 89000, categoria: 'servicios'),
      (frase: 'celular 45000', accion: 'proponerMovimiento', tipo: 'gasto', monto: 45000, categoria: 'servicios'),
      (frase: 'arriendo 1,2 millones', accion: 'proponerMovimiento', tipo: 'gasto', monto: 1200000, categoria: 'vivienda'),
      (frase: 'administración 250 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 250000, categoria: 'vivienda'),
      // Salud / educación / ocio
      (frase: 'droguería 38000', accion: 'proponerMovimiento', tipo: 'gasto', monto: 38000, categoria: 'salud'),
      (frase: 'médico 120 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 120000, categoria: 'salud'),
      (frase: 'colegio 400 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 400000, categoria: 'educacion'),
      (frase: 'curso 150000', accion: 'proponerMovimiento', tipo: 'gasto', monto: 150000, categoria: 'educacion'),
      (frase: 'cine 45 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 45000, categoria: 'ocio'),
      (frase: 'gasté 80 mil en ropa', accion: 'proponerMovimiento', tipo: 'gasto', monto: 80000, categoria: 'ocio'),
      (frase: 'salida 60 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 60000, categoria: 'ocio'),
      // Ingresos
      (frase: 'me pagaron 2 millones', accion: 'proponerMovimiento', tipo: 'ingreso', monto: 2000000, categoria: 'salario'),
      (frase: 'recibí 500 mil', accion: 'proponerMovimiento', tipo: 'ingreso', monto: 500000, categoria: 'salario'),
      (frase: 'me entró un millón', accion: 'proponerMovimiento', tipo: 'ingreso', monto: 1000000, categoria: 'salario'),
      (frase: 'me depositaron 850000', accion: 'proponerMovimiento', tipo: 'ingreso', monto: 850000, categoria: 'salario'),
      // Cuotas
      (frase: 'pagué la cuota del banco 350 mil', accion: 'proponerMovimiento', tipo: 'pagoCuota', monto: 350000, categoria: null),
      (frase: 'pagué cuota del carro 800000', accion: 'proponerMovimiento', tipo: 'pagoCuota', monto: 800000, categoria: null),
      (frase: 'cuota banco bogotá 350.000', accion: 'proponerMovimiento', tipo: 'pagoCuota', monto: 350000, categoria: null),
      // Preguntas estado
      (frase: '¿cómo voy?', accion: 'consultarEstado', tipo: null, monto: null, categoria: null),
      (frase: 'como voy', accion: 'consultarEstado', tipo: null, monto: null, categoria: null),
      (frase: '¿cuánto me queda?', accion: 'consultarEstado', tipo: null, monto: null, categoria: null),
      (frase: 'cuanto me queda por dia', accion: 'consultarEstado', tipo: null, monto: null, categoria: null),
      (frase: 'cómo estoy', accion: 'consultarEstado', tipo: null, monto: null, categoria: null),
      (frase: 'resumen del mes', accion: 'consultarEstado', tipo: null, monto: null, categoria: null),
      // Preguntas categoría
      (frase: '¿cuánto llevo en mercado?', accion: 'consultarCategoria', tipo: null, monto: null, categoria: 'alimentacion'),
      (frase: 'cuanto he gastado en uber', accion: 'consultarCategoria', tipo: null, monto: null, categoria: 'transporte'),
      (frase: 'cuanto llevo en ocio', accion: 'consultarCategoria', tipo: null, monto: null, categoria: 'ocio'),
      (frase: 'cuanto gaste en luz', accion: 'consultarCategoria', tipo: null, monto: null, categoria: 'servicios'),
      // Preguntas deuda
      (frase: '¿cuánto debo del banco?', accion: 'consultarDeuda', tipo: null, monto: null, categoria: null),
      (frase: 'cuando pago el carro', accion: 'consultarDeuda', tipo: null, monto: null, categoria: null),
      (frase: 'saldo del banco bogotá', accion: 'consultarDeuda', tipo: null, monto: null, categoria: null),
      // Más gastos cotidianos
      (frase: 'gaste 200 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 200000, categoria: 'otros'),
      (frase: 'pagué 75 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 75000, categoria: 'otros'),
      (frase: 'compré 30 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 30000, categoria: 'otros'),
      (frase: 'farmacia 22000', accion: 'proponerMovimiento', tipo: 'gasto', monto: 22000, categoria: 'salud'),
      (frase: 'netflix 30 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 30000, categoria: 'ocio'),
      (frase: 'parqueadero 8 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 8000, categoria: 'transporte'),
      (frase: 'matrícula 900 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 900000, categoria: 'educacion'),
      (frase: 'gaste ayer 50 mil en mercado', accion: 'proponerMovimiento', tipo: 'gasto', monto: 50000, categoria: 'alimentacion'),
      (frase: 'gas 42000', accion: 'proponerMovimiento', tipo: 'gasto', monto: 42000, categoria: 'servicios'),
      (frase: 'fiesta 150 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 150000, categoria: 'ocio'),
      (frase: 'libros 55 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 55000, categoria: 'educacion'),
      (frase: 'medicina 19 mil', accion: 'proponerMovimiento', tipo: 'gasto', monto: 19000, categoria: 'salud'),
      (frase: 'hipoteca 2 millones', accion: 'proponerMovimiento', tipo: 'gasto', monto: 2000000, categoria: 'vivienda'),
      (frase: 'se me fueron 10 mil en arepa', accion: 'proponerMovimiento', tipo: 'gasto', monto: 10000, categoria: 'alimentacion'),
      (frase: 'sueldo 3,5 millones', accion: 'proponerMovimiento', tipo: 'ingreso', monto: 3500000, categoria: 'salario'),
      (frase: '¿cuánto puedo gastar?', accion: 'consultarEstado', tipo: null, monto: null, categoria: null),
      // noEntendido
      (frase: 'hola', accion: 'noEntendido', tipo: null, monto: null, categoria: null),
      (frase: 'qué hay', accion: 'noEntendido', tipo: null, monto: null, categoria: null),
      (frase: 'ayúdame', accion: 'noEntendido', tipo: null, monto: null, categoria: null),
    ];

    test('hay al menos 60 frases', () {
      expect(casos.length, greaterThanOrEqualTo(60));
    });

    test('≥ 90% coinciden en accion (y tipo/monto/categoria cuando aplica)', () async {
      var ok = 0;
      final fallos = <String>[];
      for (final c in casos) {
        final r = await interp(c.frase);
        var bien = r.accion == c.accion;
        if (c.tipo != null) bien = bien && r.tipo == c.tipo;
        if (c.monto != null) bien = bien && r.monto == c.monto;
        if (c.categoria != null) bien = bien && r.categoria == c.categoria;
        if (c.accion == 'consultarDeuda') {
          bien = bien && (r.deudaId == 'd-banco' || r.deudaId == 'd-carro');
        }
        if (bien) {
          ok++;
        } else {
          fallos.add(
            '"${c.frase}" → ${r.accion}/${r.tipo}/${r.monto}/${r.categoria} '
            '(esperaba ${c.accion}/${c.tipo}/${c.monto}/${c.categoria})',
          );
        }
      }
      final ratio = ok / casos.length;
      expect(
        ratio,
        greaterThanOrEqualTo(0.9),
        reason: 'Acierto ${(ratio * 100).toStringAsFixed(1)}%. Fallos:\n${fallos.join('\n')}',
      );
    });
  });

  group('desacople Interprete', () {
    test('un Interprete falso no requiere cambiar firmas', () async {
      final falso = _InterpreteFijo(
        const Intencion(accion: AccionesIntencion.consultarEstado, confianza: 1),
      );
      final Interprete i = falso;
      final r = await i.interpretar('cualquier cosa', ctx());
      expect(r.accion, AccionesIntencion.consultarEstado);
    });
  });
}

class _InterpreteFijo implements Interprete {
  _InterpreteFijo(this.fija);
  final Intencion fija;
  @override
  Future<Intencion> interpretar(String texto, ContextoUsuario ctx) async => fija;
}
