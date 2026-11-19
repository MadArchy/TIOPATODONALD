import 'package:app/core/indicadores.dart';
import 'package:app/core/periodo.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/dinero.dart';
import 'package:app/data/models/miembro_hogar.dart';
import 'package:app/data/models/presupuesto.dart';
import 'package:app/features/home/application/home_providers.dart';
import 'package:app/features/home/presentation/widgets/barra_presupuesto.dart';
import 'package:app/features/home/presentation/widgets/semaforo_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('periodoVigenteDeMiembro (admin sin leer usuarios ajenos)', () {
    final ahora = DateTime(2026, 11, 25);

    test('dos miembros con D distinto → períodos distintos', () {
      final presupuestos = [
        Presupuesto(
          id: 'ana_2026-11-15',
          uid: 'ana',
          periodoId: '2026-11-15',
          monto: 4000000,
          actualizadoEn: ahora,
        ),
        Presupuesto(
          id: 'bob_2026-11-01',
          uid: 'bob',
          periodoId: '2026-11-01',
          monto: 2000000,
          actualizadoEn: ahora,
        ),
      ];

      final pAna = periodoVigenteDeMiembro(
        uid: 'ana',
        presupuestos: presupuestos,
        ahora: ahora,
      );
      final pBob = periodoVigenteDeMiembro(
        uid: 'bob',
        presupuestos: presupuestos,
        ahora: ahora,
      );

      expect(pAna?.periodoId, '2026-11-15');
      expect(pBob?.periodoId, '2026-11-01');
      expect(pAna!.diasTotales, 30);
      expect(pBob!.diasTotales, 30);
    });

    test('sin presupuesto → null', () {
      expect(
        periodoVigenteDeMiembro(
          uid: 'x',
          presupuestos: const [],
          ahora: ahora,
        ),
        isNull,
      );
    });
  });

  group('fechaAplicaDiaPendiente', () {
    test('D actual 1, pendiente 15 en noviembre → 15 dic', () {
      final periodo = periodoDe(DateTime(2026, 11, 18), 1);
      final fecha = fechaAplicaDiaPendiente(
        periodoActual: periodo,
        diaPendiente: 15,
      );
      expect(fecha.day, 15);
      expect(fecha.month, 12);
      expect(formatearDiaMesCorto(fecha), '15 dic');
    });
  });

  group('SemaforoCard y BarraPresupuesto (widget)', () {
    testWidgets('muestra Vas bien y disponible por día del ejemplo oficial',
        (tester) async {
      final hoy = DateTime(2026, 11, 25);
      final periodo = periodoDe(hoy, 15);
      final ind = calcularIndicadoresPeriodo(
        presupuesto: 4000000,
        movimientos: const [
          MovimientoIndicador(
            tipo: 'gasto',
            monto: 1800000,
            estado: 'activo',
            categoria: 'alimentacion',
          ),
        ],
        periodo: periodo,
        hoy: hoy,
      );

      expect(ind.disponiblePorDia, 110000);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                SemaforoCard(indicadores: ind),
                Text('Te quedan ${formatCop(ind.disponiblePorDia)} por día'),
                BarraPresupuesto(indicadores: ind),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Vas bien'), findsOneWidget);
      expect(find.text('Te quedan \$110.000 por día'), findsOneWidget);
      expect(find.byKey(const Key('barra_presupuesto')), findsOneWidget);
    });

    testWidgets('rojo muestra Te pasaste por', (tester) async {
      final hoy = DateTime(2026, 11, 25);
      final periodo = periodoDe(hoy, 15);
      final ind = calcularIndicadoresPeriodo(
        presupuesto: 1000000,
        movimientos: const [
          MovimientoIndicador(
            tipo: 'gasto',
            monto: 1500000,
            estado: 'activo',
            categoria: 'ocio',
          ),
        ],
        periodo: periodo,
        hoy: hoy,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: SemaforoCard(indicadores: ind)),
        ),
      );

      expect(find.textContaining('Te pasaste por'), findsOneWidget);
      expect(find.textContaining('\$500.000'), findsOneWidget);
    });
  });

  group('Tarjetas dashboard con D distintos', () {
    test('indicadores independientes por miembro', () {
      final ahora = DateTime(2026, 11, 25);
      final miembros = [
        MiembroHogar(
          uid: 'ana',
          nombre: 'Ana',
          rol: 'admin',
          unidoEn: ahora,
        ),
        MiembroHogar(
          uid: 'bob',
          nombre: 'Bob',
          rol: 'miembro',
          unidoEn: ahora,
        ),
      ];

      final presupuestos = [
        Presupuesto(
          id: 'ana_2026-11-15',
          uid: 'ana',
          periodoId: '2026-11-15',
          monto: 4000000,
          actualizadoEn: ahora,
        ),
        Presupuesto(
          id: 'bob_2026-11-01',
          uid: 'bob',
          periodoId: '2026-11-01',
          monto: 2000000,
          actualizadoEn: ahora,
        ),
      ];

      // Simula el cálculo que hace el provider (sin Riverpod).
      final tarjetas = <TarjetaMiembroDashboard>[];
      for (final m in miembros) {
        final periodo = periodoVigenteDeMiembro(
          uid: m.uid,
          presupuestos: presupuestos,
          ahora: ahora,
        )!;
        final prep = presupuestoDePeriodo(
          uid: m.uid,
          periodoId: periodo.periodoId,
          presupuestos: presupuestos,
        )!;
        final gastadoMonto = m.uid == 'ana' ? 1800000 : 500000;
        final ind = calcularIndicadoresPeriodo(
          presupuesto: prep.monto,
          movimientos: [
            MovimientoIndicador(
              tipo: 'gasto',
              monto: gastadoMonto,
              estado: 'activo',
              categoria: 'alimentacion',
            ),
          ],
          periodo: periodo,
          hoy: ahora,
        );
        tarjetas.add(
          TarjetaMiembroDashboard(
            uid: m.uid,
            nombre: m.nombre,
            indicadores: ind,
            periodoId: periodo.periodoId,
            tienePresupuesto: true,
          ),
        );
      }

      expect(tarjetas[0].periodoId, '2026-11-15');
      expect(tarjetas[1].periodoId, '2026-11-01');
      expect(tarjetas[0].indicadores!.disponiblePorDia, 110000);
      expect(tarjetas[1].indicadores!.diasTranscurridos, 25);
      expect(tarjetas[0].indicadores!.semaforo, Semaforo.verde);
      expect(tarjetas[1].indicadores!.semaforo, Semaforo.verde);
    });
  });
}
