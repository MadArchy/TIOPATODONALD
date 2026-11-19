import 'package:app/core/categorias.dart';
import 'package:app/core/movimientos_validacion.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/utils/clock.dart';
import 'package:app/data/models/usuario.dart';
import 'package:app/features/movimientos/presentation/nuevo_movimiento_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('router slice 3', () {
    final usuario = Usuario(
      uid: 'u1',
      nombre: 'Donald',
      email: 'donald@pato.co',
      hogarId: 'h1',
      diaInicioPeriodo: 1,
      creadoEn: DateTime(2026, 11, 1),
    );

    test('permite /historial, /gastos-fijos y /movimiento/:id con hogar', () {
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/historial',
          uid: 'u1',
          usuario: usuario,
          cargandoEstado: false,
          tienePresupuestoVigente: true,
        ),
        isNull,
      );
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/gastos-fijos',
          uid: 'u1',
          usuario: usuario,
          cargandoEstado: false,
          tienePresupuestoVigente: true,
        ),
        isNull,
      );
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/movimiento/abc123',
          uid: 'u1',
          usuario: usuario,
          cargandoEstado: false,
          tienePresupuestoVigente: true,
        ),
        isNull,
      );
    });
  });

  group('NuevoMovimientoSheet smoke', () {
    testWidgets('muestra Gasto/Ingreso, monto, categorías y Guardar',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clockProvider.overrideWithValue(
              FixedClock(DateTime(2026, 11, 18, 12)),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NuevoMovimientoSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nuevo'), findsOneWidget);
      expect(find.text('Gasto'), findsOneWidget);
      expect(find.text('Ingreso'), findsOneWidget);
      expect(find.byKey(const Key('campo_monto_movimiento')), findsOneWidget);
      expect(find.byKey(const Key('grid_categorias')), findsOneWidget);
      expect(find.byKey(const Key('btn_guardar_movimiento')), findsOneWidget);
      expect(find.text(etiquetaCategoria('alimentacion')), findsOneWidget);
    });
  });

  group('ventana edición menor (smoke lógico)', () {
    test('UI depende de puedeEdicionMenor < 24 h', () {
      final creado = DateTime(2026, 11, 18, 8);
      expect(
        puedeEdicionMenor(
          autorUid: 'u1',
          uidActual: 'u1',
          creadoEn: creado,
          ahora: creado.add(const Duration(hours: 23)),
          diaInicioPeriodo: 1,
          periodoIdMovimiento: '2026-11-01',
        ),
        isTrue,
      );
      expect(
        puedeEdicionMenor(
          autorUid: 'u1',
          uidActual: 'u1',
          creadoEn: creado,
          ahora: creado.add(const Duration(hours: 25)),
          diaInicioPeriodo: 1,
          periodoIdMovimiento: '2026-11-01',
        ),
        isFalse,
      );
    });
  });
}
