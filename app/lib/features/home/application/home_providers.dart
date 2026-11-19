import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/deudas_fecha.dart';
import '../../../core/indicadores.dart';
import '../../../core/periodo.dart';
import '../../../core/utils/clock.dart';
import '../../../data/models/deuda.dart';
import '../../../data/models/movimiento.dart';
import '../../../data/models/presupuesto.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/deudas_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';

/// Convierte [Movimiento] de Firestore a [MovimientoIndicador].
MovimientoIndicador movimientoAIndicador(Movimiento m) {
  return MovimientoIndicador(
    tipo: m.tipo,
    monto: m.monto,
    estado: m.estado,
    categoria: m.categoria,
    deudaId: m.deudaId,
  );
}

/// Extrae el día de inicio D desde un `periodoId` `YYYY-MM-DD`.
int? diaInicioDesdePeriodoId(String periodoId) {
  if (periodoId.length < 10) return null;
  return int.tryParse(periodoId.substring(8, 10));
}

/// Infiera el período vigente de un miembro a partir de sus presupuestos
/// (sin leer `usuarios/{uid}` ajeno — el admin no puede).
Periodo? periodoVigenteDeMiembro({
  required String uid,
  required List<Presupuesto> presupuestos,
  required DateTime ahora,
}) {
  final delUid = presupuestos.where((p) => p.uid == uid).toList();
  if (delUid.isEmpty) return null;

  // Preferir un presupuesto cuyo período cubra "ahora".
  for (final p in delUid) {
    final d = diaInicioDesdePeriodoId(p.periodoId);
    if (d == null) continue;
    final periodo = periodoDe(ahora, d);
    if (periodo.periodoId == p.periodoId) {
      return periodo;
    }
  }

  // Si ninguno coincide (presupuesto atrasado), usar el D del más reciente.
  delUid.sort((a, b) => b.periodoId.compareTo(a.periodoId));
  final d = diaInicioDesdePeriodoId(delUid.first.periodoId);
  if (d == null) return null;
  return periodoDe(ahora, d);
}

Presupuesto? presupuestoDePeriodo({
  required String uid,
  required String periodoId,
  required List<Presupuesto> presupuestos,
}) {
  for (final p in presupuestos) {
    if (p.uid == uid && p.periodoId == periodoId) return p;
  }
  return null;
}

/// Indicadores del usuario autenticado en su período vigente.
final indicadoresPropiosProvider = Provider<IndicadoresPeriodo?>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final presupuesto = ref.watch(presupuestoVigenteProvider).value;
  if (usuario == null || presupuesto == null) return null;

  final ahora = ref.watch(clockProvider).now();
  final periodo = periodoDe(ahora, usuario.diaInicioPeriodo);
  final movs = ref
          .watch(
            movimientosPeriodoProvider((
              periodoId: periodo.periodoId,
              uid: usuario.uid,
              categoria: null,
            )),
          )
          .value ??
      const <Movimiento>[];

  return calcularIndicadoresPeriodo(
    presupuesto: presupuesto.monto,
    movimientos: movs.map(movimientoAIndicador),
    periodo: periodo,
    hoy: ahora,
  );
});

/// Deudas del hogar → indicadores de cuota (Slice 5).
final deudasCuotaHookProvider = Provider<List<DeudaCuotaIndicador>>((ref) {
  final deudas = ref.watch(deudasHogarProvider).value ?? const <Deuda>[];
  return deudas
      .map(
        (d) => DeudaCuotaIndicador(
          id: d.id,
          cuotaMensual: d.cuotaMensual,
          estado: d.estado,
        ),
      )
      .toList();
});

final cuotasComprometidasProvider = Provider<int>((ref) {
  return cuotasComprometidas(ref.watch(deudasCuotaHookProvider));
});

/// Próximo pago de una deuda activa (para Inicio).
class ProximoPagoDeuda {
  const ProximoPagoDeuda({
    required this.deuda,
    required this.fecha,
  });

  final Deuda deuda;
  final DateTime fecha;
}

/// Deudas activas ordenadas por próxima fecha de pago.
final proximosPagosProvider = Provider<List<ProximoPagoDeuda>>((ref) {
  final activas = ref.watch(deudasActivasProvider);
  final ahora = ref.watch(clockProvider).now();
  final lista = activas
      .map(
        (d) => ProximoPagoDeuda(
          deuda: d,
          fecha: proximaFechaPago(diaPago: d.diaPago, hoy: ahora),
        ),
      )
      .toList()
    ..sort((a, b) => a.fecha.compareTo(b.fecha));
  return lista;
});

/// Fecha en que aplicaría un `diaInicioPendiente` (primer D pendiente
/// posterior al fin del período actual).
DateTime fechaAplicaDiaPendiente({
  required Periodo periodoActual,
  required int diaPendiente,
}) {
  final fin = periodoActual.fin;
  var y = fin.year;
  var m = fin.month;
  var candidate = DateTime(y, m, diaPendiente);
  if (!candidate.isAfter(fin)) {
    if (m == 12) {
      y += 1;
      m = 1;
    } else {
      m += 1;
    }
    candidate = DateTime(y, m, diaPendiente);
  }
  return candidate;
}

const _mesesCortos = <String>[
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String formatearDiaMesCorto(DateTime fecha) {
  final mes = _mesesCortos[fecha.month - 1];
  return '${fecha.day} $mes';
}

/// Datos de una tarjeta del dashboard admin.
class TarjetaMiembroDashboard {
  const TarjetaMiembroDashboard({
    required this.uid,
    required this.nombre,
    required this.indicadores,
    required this.periodoId,
    required this.tienePresupuesto,
  });

  final String uid;
  final String nombre;
  final IndicadoresPeriodo? indicadores;
  final String? periodoId;
  final bool tienePresupuesto;
}

/// Dashboard: una tarjeta por miembro activo en SU propio período.
final dashboardMiembrosProvider = Provider<List<TarjetaMiembroDashboard>>((ref) {
  final miembros = ref.watch(miembrosHogarProvider).value ?? const [];
  final presupuestos =
      ref.watch(presupuestosHogarProvider).value ?? const <Presupuesto>[];
  final ahora = ref.watch(clockProvider).now();
  final resultado = <TarjetaMiembroDashboard>[];

  for (final m in miembros) {
    final periodo = periodoVigenteDeMiembro(
      uid: m.uid,
      presupuestos: presupuestos,
      ahora: ahora,
    );
    if (periodo == null) {
      resultado.add(
        TarjetaMiembroDashboard(
          uid: m.uid,
          nombre: m.nombre,
          indicadores: null,
          periodoId: null,
          tienePresupuesto: false,
        ),
      );
      continue;
    }

    final prep = presupuestoDePeriodo(
      uid: m.uid,
      periodoId: periodo.periodoId,
      presupuestos: presupuestos,
    );

    final movs = ref
            .watch(
              movimientosPeriodoProvider((
                periodoId: periodo.periodoId,
                uid: m.uid,
                categoria: null,
              )),
            )
            .value ??
        const <Movimiento>[];

    final ind = prep == null
        ? null
        : calcularIndicadoresPeriodo(
            presupuesto: prep.monto,
            movimientos: movs.map(movimientoAIndicador),
            periodo: periodo,
            hoy: ahora,
          );

    resultado.add(
      TarjetaMiembroDashboard(
        uid: m.uid,
        nombre: m.nombre,
        indicadores: ind,
        periodoId: periodo.periodoId,
        tienePresupuesto: prep != null,
      ),
    );
  }

  return resultado;
});

/// Margen real del hogar: suma de ingresos/gastado de cada miembro en su
/// período vigente − cuotasPendientes (deudas activas sin pagoCuota del admin).
final margenRealHogarProvider = Provider<int>((ref) {
  final tarjetas = ref.watch(dashboardMiembrosProvider);
  var ingresosHogar = 0;
  var gastadoHogar = 0;
  for (final t in tarjetas) {
    final ind = t.indicadores;
    if (ind == null) continue;
    ingresosHogar += ind.ingresos;
    gastadoHogar += ind.gastado;
  }

  final deudas = ref.watch(deudasCuotaHookProvider);
  final admin = ref.watch(usuarioActualProvider).value;
  final ahora = ref.watch(clockProvider).now();
  var movsAdmin = const <MovimientoIndicador>[];
  if (admin != null) {
    final periodoAdmin = periodoDe(ahora, admin.diaInicioPeriodo);
    final movs = ref
            .watch(
              movimientosPeriodoProvider((
                periodoId: periodoAdmin.periodoId,
                uid: null,
                categoria: null,
              )),
            )
            .value ??
        const <Movimiento>[];
    movsAdmin = movs.map(movimientoAIndicador).toList();
  }

  final pendientes = cuotasPendientes(
    deudas: deudas,
    movimientosPeriodoAdmin: movsAdmin,
  );

  return margenReal(
    ingresosHogar: ingresosHogar,
    gastadoHogar: gastadoHogar,
    cuotasPendientes: pendientes,
  );
});
