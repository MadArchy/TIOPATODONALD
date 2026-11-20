import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/indicadores.dart';
import '../../../core/periodo.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/conectividad.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/deuda.dart';
import '../../../data/models/gasto_fijo.dart';
import '../../../data/models/movimiento.dart';
import '../../../data/models/resumen_periodo.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/correcciones_repository.dart';
import '../../../data/repositories/deudas_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';
import '../../deudas_internas/application/avisos_internos_provider.dart';
import '../../movimientos/presentation/nuevo_movimiento_sheet.dart';
import '../../movimientos/presentation/widgets/fila_movimiento.dart';
import '../application/home_providers.dart';
import 'widgets/alerta_presupuesto_banner.dart';
import 'widgets/barra_presupuesto.dart';
import 'widgets/desglose_categorias.dart';
import 'widgets/semaforo_card.dart';

/// Pantalla de Inicio (Slice 4 + Slice 8.5):
/// 3 bloques claros: "¿Cómo voy?" → "Pendientes" → "En qué se va" + recientes.
class InicioScreen extends ConsumerStatefulWidget {
  const InicioScreen({super.key});

  @override
  ConsumerState<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends ConsumerState<InicioScreen> {
  List<int> _alertasPendientesUi = const [];
  Set<int> _alertasDescartadasLocal = <int>{};
  String? _presupuestoIdCargado;

  String _claveLocalAlertas(String presupuestoId) =>
      'alertas_banner_vistas_$presupuestoId';

  Future<void> _cargarDescartadasLocal(String presupuestoId) async {
    if (_presupuestoIdCargado == presupuestoId) return;
    _presupuestoIdCargado = presupuestoId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardadas = prefs.getStringList(_claveLocalAlertas(presupuestoId));
      final parsed = (guardadas ?? const <String>[])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
      if (!mounted) return;
      setState(() {
        _alertasDescartadasLocal = parsed;
        _alertasPendientesUi = _alertasPendientesUi
            .where((u) => !parsed.contains(u))
            .toList();
      });
    } catch (_) {
      // Sin persistencia local disponible: solo estado en memoria.
    }
  }

  Future<void> _descartarAlertasUi(List<int> umbrales) async {
    final presupuesto = ref.read(presupuestoVigenteProvider).value;
    final actualizadas = <int>{..._alertasDescartadasLocal, ...umbrales};
    setState(() {
      _alertasDescartadasLocal = actualizadas;
      _alertasPendientesUi = const [];
    });
    if (presupuesto == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lista = actualizadas.toList()..sort();
      await prefs.setStringList(
        _claveLocalAlertas(presupuesto.id),
        lista.map((e) => '$e').toList(),
      );
    } catch (_) {
      // Ignorar si SharedPreferences falla en entornos de prueba.
    }
  }

  /// C6: registra un gasto fijo con un toque (sin abrir el formulario).
  Future<void> _registrarGastoFijoDirecto(GastoFijo gasto) async {
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (usuario == null || hogarId == null || hogarId.isEmpty) return;

    final ahora = ref.read(clockProvider).now();
    final fecha = DateTime(ahora.year, ahora.month, ahora.day);
    try {
      await ref.read(movimientosRepositoryProvider).crearMovimiento(
            hogarId: hogarId,
            uid: usuario.uid,
            diaInicioPeriodo: usuario.diaInicioPeriodo,
            tipo: 'gasto',
            monto: gasto.monto,
            categoria: gasto.categoria,
            fecha: fecha,
            ahora: ahora,
            nota: gasto.nombre,
            origen: 'gastoFijo',
            gastoFijoId: gasto.id,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Listo: ${gasto.nombre} (${formatCop(gasto.monto)}) guardado.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos registrar el gasto fijo. Intenta de nuevo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogar = ref.watch(hogarActualProvider).value;
    final presupuesto = ref.watch(presupuestoVigenteProvider).value;
    final indicadores = ref.watch(indicadoresPropiosProvider);
    final gastosFijosPendientes = ref.watch(gastosFijosPendientesHoyProvider);
    final cuotas = ref.watch(cuotasComprometidasProvider);
    final proximosPagos = ref.watch(proximosPagosProvider);
    final resumenAnterior = ref.watch(resumenPeriodoAnteriorProvider).value;
    final avisosInternos = ref.watch(avisosInternosProvider);
    final pendientesEnvio =
        ref.watch(movimientosPendientesEnvioProvider).value ?? 0;
    final ahora = ref.watch(clockProvider).now();
    final esAdmin =
        hogar != null && usuario != null && hogar.adminUid == usuario.uid;
    final correccionesPendientes = esAdmin
        ? (ref.watch(correccionesPendientesProvider).value?.length ?? 0)
        : 0;

    ref.listen(tieneInternetProvider, (prev, next) {
      final hogarId = usuario?.hogarId;
      if ((next.value ?? false) && hogarId != null) {
        // ignore: discarded_futures
        ref
            .read(movimientosRepositoryProvider)
            .sincronizarFotosPendientes(hogarId);
      }
    });

    if (presupuesto != null && _presupuestoIdCargado != presupuesto.id) {
      // ignore: discarded_futures
      _cargarDescartadasLocal(presupuesto.id);
    }

    ref.listen(indicadoresPropiosProvider, (prev, next) {
      final prep = ref.read(presupuestoVigenteProvider).value;
      if (next == null || prep == null) return;
      final yaVistas = <int>{
        ...prep.alertasEnviadas,
        ..._alertasDescartadasLocal,
      }.toList();
      final nuevas = alertasNuevas(
        gastado: next.gastado,
        presupuesto: next.presupuesto,
        alertasEnviadas: yaVistas,
      );
      if (nuevas.isNotEmpty) {
        setState(() => _alertasPendientesUi = nuevas);
      }
    });

    final periodoVigente =
        usuario == null ? null : periodoDe(ahora, usuario.diaInicioPeriodo);
    final periodoId = periodoVigente?.periodoId;

    final recientesAsync = periodoId == null || usuario == null
        ? const AsyncValue<List<Movimiento>>.data(<Movimiento>[])
        : ref.watch(
            movimientosPeriodoProvider((
              periodoId: periodoId,
              uid: usuario.uid,
              categoria: null,
            )),
          );

    final deudas = ref.watch(deudasHogarProvider).value ?? const <Deuda>[];
    final nombresDeuda = <String, String>{
      for (final d in deudas) d.id: d.entidad,
    };

    // Cuotas que vencen en los próximos 3 días (C2).
    final hoySoloFecha = DateTime(ahora.year, ahora.month, ahora.day);
    final cuotasProximas3Dias = proximosPagos.where((p) {
      final diff = DateTime(p.fecha.year, p.fecha.month, p.fecha.day)
          .difference(hoySoloFecha)
          .inDays;
      return diff >= 0 && diff <= 3;
    }).toList();

    final hayPendientes = gastosFijosPendientes.isNotEmpty ||
        cuotasProximas3Dias.isNotEmpty ||
        correccionesPendientes > 0 ||
        avisosInternos.isNotEmpty;

    final colores =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hogar?.nombre ?? 'Inicio'),
            if (periodoVigente != null)
              Text(
                formatearRangoPeriodo(periodoVigente),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          if (pendientesEnvio > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                key: const Key('chip_pendientes_envio'),
                avatar: const Icon(Icons.cloud_upload_outlined, size: 18),
                label: Text('$pendientesEnvio por enviar'),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('fab_nuevo_movimiento'),
        tooltip: 'Nuevo movimiento',
        onPressed: () => mostrarNuevoMovimientoSheet(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── BLOQUE 1: ¿Cómo voy? ───────────────────────────────────
                  if (_alertasPendientesUi.isNotEmpty) ...[
                    AlertaPresupuestoBanner(
                      umbrales: _alertasPendientesUi,
                      onDismiss: () {
                        // ignore: discarded_futures
                        _descartarAlertasUi(_alertasPendientesUi);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (resumenAnterior != null) ...[
                    _TarjetaCierrePeriodo(resumen: resumenAnterior),
                    const SizedBox(height: 16),
                  ],
                  if (indicadores == null || presupuesto == null)
                    Text(
                      'Aún no has fijado tu presupuesto para este período.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    )
                  else ...[
                    SemaforoCard(indicadores: indicadores),
                    const SizedBox(height: 16),
                    Text(
                      key: const Key('texto_disponible_por_dia'),
                      indicadores.disponible <= 0
                          ? 'Ya usaste todo tu presupuesto'
                          : 'Te quedan ${formatCop(indicadores.disponiblePorDia)} por día',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quedan ${indicadores.diasRestantes} días de tu período',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    BarraPresupuesto(indicadores: indicadores),
                    if (indicadores.avisoPreventivo &&
                        indicadores.proyeccion != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        key: const Key('aviso_preventivo'),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colores.preventivoFondo,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colores.preventivo),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.trending_up, color: colores.preventivo),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'A este ritmo terminas en ${formatCop(indicadores.proyeccion!)}',
                                style: TextStyle(
                                  color: colores.preventivo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniDato(
                            etiqueta: 'Ingresos del período',
                            valor: formatCop(indicadores.ingresos),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniDato(
                            etiqueta: 'Cuotas comprometidas',
                            valor: cuotas > 0 ? formatCop(cuotas) : '—',
                            subtitulo: cuotas == 0 ? 'Sin deudas aún' : null,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── BLOQUE 2: Pendientes (accionable arriba) ───────────────
                  if (hayPendientes) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Pendientes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...gastosFijosPendientes.map((g) {
                      return Card(
                        key: Key('tarjeta_gasto_fijo_${g.id}'),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '¿Registrar ${g.nombre} ${formatCop(g.monto)}?',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      key: Key('btn_registrar_fijo_${g.id}'),
                                      onPressed: () =>
                                          _registrarGastoFijoDirecto(g),
                                      child: const Text('Registrar'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    key: Key('btn_cambiar_fijo_${g.id}'),
                                    onPressed: () =>
                                        mostrarNuevoMovimientoSheet(
                                      context,
                                      desdeGastoFijo: g,
                                    ),
                                    child: const Text('Cambiar monto'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    ...cuotasProximas3Dias.map((p) {
                      return Card(
                        key: Key('proximo_pago_${p.deuda.id}'),
                        child: ListTile(
                          leading: const Icon(Icons.event_outlined),
                          title: Text('Cuota: ${p.deuda.entidad}'),
                          subtitle: Text(
                            'Vence ${formatearDiaMesCorto(p.fecha)} · '
                            '${formatCop(p.deuda.cuotaMensual)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/deudas'),
                        ),
                      );
                    }),
                    if (correccionesPendientes > 0)
                      Card(
                        key: const Key('tarjeta_pendiente_correcciones'),
                        child: ListTile(
                          leading: const Icon(Icons.fact_check_outlined),
                          title: Text(
                            correccionesPendientes == 1
                                ? '1 corrección por revisar'
                                : '$correccionesPendientes correcciones por revisar',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/correcciones'),
                        ),
                      ),
                    ...avisosInternos.take(3).map((aviso) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.handshake_outlined),
                          title: Text(aviso.titulo),
                          subtitle: Text(aviso.detalle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              context.push('/deudas-internas/${aviso.deudaId}'),
                        ),
                      );
                    }),
                  ],

                  // ── BLOQUE 3: En qué se va ─────────────────────────────────
                  if (indicadores != null && presupuesto != null) ...[
                    const SizedBox(height: 24),
                    DesgloseCategorias(indicadores: indicadores),
                  ],

                  // ── Movimientos recientes (legibles, sin periodoId) ────────
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tus movimientos recientes',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/historial'),
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  recientesAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, _) => const Text(
                      'No pudimos cargar tus movimientos.',
                    ),
                    data: (lista) {
                      final recientes = lista.take(5).toList();
                      if (recientes.isEmpty) {
                        return const Text(
                          'Aún no has registrado nada. Toca + para empezar.',
                        );
                      }
                      return Column(
                        children: recientes.map((m) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FilaMovimiento(
                              movimiento: m,
                              ahora: ahora,
                              nombreDeuda: m.deudaId != null
                                  ? nombresDeuda[m.deudaId!]
                                  : null,
                              onTap: () =>
                                  context.push('/movimiento/${m.id}'),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniDato extends StatelessWidget {
  const _MiniDato({
    required this.etiqueta,
    required this.valor,
    this.subtitulo,
  });

  final String etiqueta;
  final String valor;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            valor,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (subtitulo != null)
            Text(subtitulo!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TarjetaCierrePeriodo extends StatelessWidget {
  const _TarjetaCierrePeriodo({required this.resumen});

  final ResumenPeriodo resumen;

  @override
  Widget build(BuildContext context) {
    final colores =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;
    final verde = resumen.semaforo == 'verde';
    return Container(
      key: const Key('tarjeta_cierre_periodo'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cierre de tu período',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(formatearRangoDesdePeriodoId(resumen.periodoId)),
          const SizedBox(height: 8),
          Text(
            'Gastaste ${formatCop(resumen.gastado)} de ${formatCop(resumen.presupuesto)}',
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                verde ? Icons.check_circle : Icons.error,
                color: verde ? colores.verde : colores.rojo,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                verde ? 'Cerraste en verde' : 'Cerraste en rojo',
                style: TextStyle(
                  color: verde ? colores.verde : colores.rojo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
