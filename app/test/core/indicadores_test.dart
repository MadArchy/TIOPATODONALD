import 'package:app/core/indicadores.dart';
import 'package:app/core/periodo.dart';
import 'package:flutter_test/flutter_test.dart';

MovimientoIndicador _gasto(int monto, {String categoria = 'alimentacion'}) {
  return MovimientoIndicador(
    tipo: 'gasto',
    monto: monto,
    estado: 'activo',
    categoria: categoria,
  );
}

MovimientoIndicador _ingreso(int monto) {
  return MovimientoIndicador(
    tipo: 'ingreso',
    monto: monto,
    estado: 'activo',
    categoria: 'salario',
  );
}

MovimientoIndicador _pagoCuota(int monto, {String deudaId = 'd1'}) {
  return MovimientoIndicador(
    tipo: 'pagoCuota',
    monto: monto,
    estado: 'activo',
    deudaId: deudaId,
  );
}

void main() {
  group('Indicadores — ejemplo oficial docs/02_reglas_negocio.md §2', () {
    test(
      'presupuesto 4.000.000, D=15, hoy 2026-11-25, gastado 1.800.000',
      () {
        final hoy = DateTime(2026, 11, 25);
        final periodo = periodoDe(hoy, 15);
        const presupuesto = 4000000;
        final movimientos = <MovimientoIndicador>[
          _gasto(1800000),
        ];

        final ind = calcularIndicadoresPeriodo(
          presupuesto: presupuesto,
          movimientos: movimientos,
          periodo: periodo,
          hoy: hoy,
        );

        expect(periodo.diasTotales, 30);
        expect(ind.diasPeriodo, 30);
        expect(ind.diasTranscurridos, 11);
        expect(ind.diasRestantes, 20);
        expect(ind.gastado, 1800000);
        expect(ind.disponible, 2200000);
        expect(ind.disponiblePorDia, 110000);
        expect(ind.proyeccion, 4909090);
        expect(ind.semaforo, Semaforo.verde);
        expect(ind.avisoPreventivo, isTrue);
      },
    );
  });

  group('gastado e ingresos', () {
    test('suma gasto + pagoCuota activos; ignora anulados e ingresos', () {
      final movimientos = [
        _gasto(1000),
        _pagoCuota(500),
        _ingreso(2000),
        const MovimientoIndicador(
          tipo: 'gasto',
          monto: 999,
          estado: 'anulado',
          categoria: 'ocio',
        ),
      ];
      expect(gastado(movimientos), 1500);
      expect(ingresos(movimientos), 2000);
    });

    test('sin movimientos → 0', () {
      expect(gastado(const []), 0);
      expect(ingresos(const []), 0);
    });
  });

  group('disponible y disponiblePorDia', () {
    test('disponible puede ser negativo', () {
      expect(disponible(presupuesto: 100, gastado: 150), -50);
    });

    test('disponiblePorDia usa floor y max(0, disponible)', () {
      expect(
        disponiblePorDia(disponible: 2200000, diasRestantes: 20),
        110000,
      );
      expect(
        disponiblePorDia(disponible: -100, diasRestantes: 5),
        0,
      );
      expect(
        disponiblePorDia(disponible: 100, diasRestantes: 0),
        0,
      );
      expect(
        disponiblePorDia(disponible: 10, diasRestantes: 3),
        3, // 10 ~/ 3
      );
    });
  });

  group('proyeccion y avisoPreventivo', () {
    test('null en día 1 y día 2; aplica desde día 3', () {
      expect(
        proyeccion(gastado: 100, diasTranscurridos: 1, diasPeriodo: 30),
        isNull,
      );
      expect(
        proyeccion(gastado: 100, diasTranscurridos: 2, diasPeriodo: 30),
        isNull,
      );
      expect(
        proyeccion(gastado: 300, diasTranscurridos: 3, diasPeriodo: 30),
        3000,
      );
    });

    test('trunca hacia abajo', () {
      // 1800000/11*30 = 4909090.909...
      expect(
        proyeccion(gastado: 1800000, diasTranscurridos: 11, diasPeriodo: 30),
        4909090,
      );
    });

    test('avisoPreventivo solo si proyección > presupuesto y verde', () {
      expect(
        avisoPreventivo(
          proyeccion: 4909090,
          presupuesto: 4000000,
          semaforo: Semaforo.verde,
        ),
        isTrue,
      );
      expect(
        avisoPreventivo(
          proyeccion: 3000000,
          presupuesto: 4000000,
          semaforo: Semaforo.verde,
        ),
        isFalse,
      );
      expect(
        avisoPreventivo(
          proyeccion: 5000000,
          presupuesto: 4000000,
          semaforo: Semaforo.rojo,
        ),
        isFalse,
      );
      expect(
        avisoPreventivo(
          proyeccion: null,
          presupuesto: 4000000,
          semaforo: Semaforo.verde,
        ),
        isFalse,
      );
    });
  });

  group('semaforo', () {
    test('verde si gastado ≤ presupuesto; rojo si no', () {
      expect(semaforo(gastado: 100, presupuesto: 100), Semaforo.verde);
      expect(semaforo(gastado: 99, presupuesto: 100), Semaforo.verde);
      expect(semaforo(gastado: 101, presupuesto: 100), Semaforo.rojo);
      expect(semaforo(gastado: 0, presupuesto: 0), Semaforo.verde);
    });
  });

  group('bordes de período', () {
    test('día 1 del período: proyección null, restantes = días totales', () {
      final hoy = DateTime(2026, 11, 15);
      final periodo = periodoDe(hoy, 15);
      final ind = calcularIndicadoresPeriodo(
        presupuesto: 4000000,
        movimientos: [_gasto(100000)],
        periodo: periodo,
        hoy: hoy,
      );
      expect(ind.diasTranscurridos, 1);
      expect(ind.diasRestantes, 30);
      expect(ind.proyeccion, isNull);
      expect(ind.avisoPreventivo, isFalse);
      expect(ind.disponiblePorDia, 3900000 ~/ 30);
    });

    test('día 2: proyección aún null', () {
      final hoy = DateTime(2026, 11, 16);
      final periodo = periodoDe(hoy, 15);
      final ind = calcularIndicadoresPeriodo(
        presupuesto: 4000000,
        movimientos: [_gasto(200000)],
        periodo: periodo,
        hoy: hoy,
      );
      expect(ind.diasTranscurridos, 2);
      expect(ind.proyeccion, isNull);
    });

    test('último día del período', () {
      final hoy = DateTime(2026, 12, 14);
      final periodo = periodoDe(hoy, 15);
      final ind = calcularIndicadoresPeriodo(
        presupuesto: 4000000,
        movimientos: [_gasto(1000000)],
        periodo: periodo,
        hoy: hoy,
      );
      expect(ind.diasRestantes, 1);
      expect(ind.diasTranscurridos, 30);
      expect(ind.disponiblePorDia, 3000000);
      expect(ind.proyeccion, 1000000); // 1e6/30*30
    });

    test('presupuesto 0: semáforo rojo si hay gasto; disponible negativo', () {
      final hoy = DateTime(2026, 11, 25);
      final periodo = periodoDe(hoy, 15);
      final ind = calcularIndicadoresPeriodo(
        presupuesto: 0,
        movimientos: [_gasto(500)],
        periodo: periodo,
        hoy: hoy,
      );
      expect(ind.semaforo, Semaforo.rojo);
      expect(ind.disponible, -500);
      expect(ind.disponiblePorDia, 0);
    });

    test('sin movimientos: disponible = presupuesto, proyección 0 desde día 3', () {
      final hoy = DateTime(2026, 11, 25);
      final periodo = periodoDe(hoy, 15);
      final ind = calcularIndicadoresPeriodo(
        presupuesto: 4000000,
        movimientos: const [],
        periodo: periodo,
        hoy: hoy,
      );
      expect(ind.gastado, 0);
      expect(ind.ingresos, 0);
      expect(ind.disponible, 4000000);
      expect(ind.disponiblePorDia, 200000);
      expect(ind.proyeccion, 0);
      expect(ind.semaforo, Semaforo.verde);
      expect(ind.avisoPreventivo, isFalse);
      expect(ind.porcentajeReducible, 0);
    });
  });

  group('porcentajeReducible y por categoría', () {
    test('ocio + otros / gastado; pagoCuota no cuenta como reducible', () {
      final movimientos = [
        _gasto(700, categoria: 'alimentacion'),
        _gasto(200, categoria: 'ocio'),
        _gasto(100, categoria: 'otros'),
        _pagoCuota(50),
      ];
      // gastado = 1050; reducible = 300 → 300/1050
      expect(
        porcentajeReducible(movimientos: movimientos, gastado: 1050),
        closeTo(300 / 1050, 1e-9),
      );
      expect(porcentajeReducible(movimientos: movimientos, gastado: 0), 0);

      final porCat = gastadoPorCategoria(movimientos);
      expect(porCat['alimentacion'], 700);
      expect(porCat['ocio'], 200);
      expect(porCat['otros'], 100);
      expect(porCat['pagoCuota'], 50);
    });
  });

  group('cuotas y margen real', () {
    test('cuotasComprometidas solo activas', () {
      final deudas = [
        const DeudaCuotaIndicador(id: 'a', cuotaMensual: 100, estado: 'activa'),
        const DeudaCuotaIndicador(id: 'b', cuotaMensual: 50, estado: 'pagada'),
        const DeudaCuotaIndicador(
          id: 'c',
          cuotaMensual: 20,
          estado: 'desactivada',
        ),
      ];
      expect(cuotasComprometidas(deudas), 100);
    });

    test('cuotasPendientes excluye deudas con pagoCuota en el período', () {
      final deudas = [
        const DeudaCuotaIndicador(id: 'a', cuotaMensual: 100, estado: 'activa'),
        const DeudaCuotaIndicador(id: 'b', cuotaMensual: 80, estado: 'activa'),
      ];
      final movs = [_pagoCuota(100, deudaId: 'a')];
      expect(
        cuotasPendientes(deudas: deudas, movimientosPeriodoAdmin: movs),
        80,
      );
    });

    test('margenReal = ingresos − gastado − cuotasPendientes', () {
      expect(
        margenReal(
          ingresosHogar: 5000000,
          gastadoHogar: 3000000,
          cuotasPendientes: 200000,
        ),
        1800000,
      );
    });

    test('hooks vacíos de deudas → 0', () {
      expect(cuotasComprometidas(const []), 0);
      expect(
        cuotasPendientes(
          deudas: const [],
          movimientosPeriodoAdmin: const [],
        ),
        0,
      );
    });
  });

  group('alertasNuevas', () {
    test('dispara 50, 80 y 100 una vez cada una', () {
      expect(
        alertasNuevas(
          gastado: 2000000,
          presupuesto: 4000000,
          alertasEnviadas: const [],
        ),
        [50],
      );
      expect(
        alertasNuevas(
          gastado: 3200000,
          presupuesto: 4000000,
          alertasEnviadas: const [50],
        ),
        [80],
      );
      expect(
        alertasNuevas(
          gastado: 4000000,
          presupuesto: 4000000,
          alertasEnviadas: const [50, 80],
        ),
        [100],
      );
      expect(
        alertasNuevas(
          gastado: 5000000,
          presupuesto: 4000000,
          alertasEnviadas: const [50, 80, 100],
        ),
        isEmpty,
      );
    });

    test('presupuesto 0 no genera alertas', () {
      expect(
        alertasNuevas(
          gastado: 1,
          presupuesto: 0,
          alertasEnviadas: const [],
        ),
        isEmpty,
      );
    });
  });

  group('periodoAnteriorDe', () {
    test('período D=15 que inicia 2026-11-15 → anterior inicia 2026-10-15', () {
      final actual = periodoDe(DateTime(2026, 11, 15), 15);
      final ant = periodoAnteriorDe(actual);
      expect(ant.periodoId, '2026-10-15');
      expect(ant.fin.day, 14);
      expect(ant.fin.month, 11);
    });
  });
}
