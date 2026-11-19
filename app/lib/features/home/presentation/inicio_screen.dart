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
import '../../../data/models/movimiento.dart';
import '../../../data/models/resumen_periodo.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/correcciones_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';
import '../../movimientos/presentation/nuevo_movimiento_sheet.dart';
import '../application/home_providers.dart';
import 'widgets/alerta_presupuesto_banner.dart';
import 'widgets/barra_presupuesto.dart';
import 'widgets/desglose_categorias.dart';
import 'widgets/semaforo_card.dart';

/// Pantalla de Inicio (Slice 4): semáforo, disponible/día, proyección, alertas.
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

  /// Guarda solo localmente los banners ya vistos; `presupuestos.alertasEnviadas`
  /// lo escribe exclusivamente el servidor (`alCrearMovimiento`) para evitar
  /// condición de carrera con el envío de push FCM.
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

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogar = ref.watch(hogarActualProvider).value;
    final presupuesto = ref.watch(presupuestoVigenteProvider).value;
    final indicadores = ref.watch(indicadoresPropiosProvider);
    final pendientes = ref.watch(gastosFijosPendientesHoyProvider);
    final cuotas = ref.watch(cuotasComprometidasProvider);
    final proximosPagos = ref.watch(proximosPagosProvider);
    final resumenAnterior = ref.watch(resumenPeriodoAnteriorProvider).value;
    final ahora = ref.watch(clockProvider).now();
    final esAdmin = hogar != null &&
        usuario != null &&
        hogar.adminUid == usuario.uid;

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

    // Detectar alertas nuevas para banner in-app (sin escribir en Firestore).
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

    final periodoId = usuario == null
        ? null
        : periodoDe(ahora, usuario.diaInicioPeriodo).periodoId;

    final recientesAsync = periodoId == null || usuario == null
        ? const AsyncValue<List<Movimiento>>.data(<Movimiento>[])
        : ref.watch(
            movimientosPeriodoProvider((
              periodoId: periodoId,
              uid: usuario.uid,
              categoria: null,
            )),
          );

    final colores =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(hogar?.nombre ?? 'Inicio'),
        actions: [
          if (esAdmin) ...[
            Builder(
              builder: (context) {
                final nPendientes =
                    ref.watch(correccionesPendientesProvider).value?.length ?? 0;
                return IconButton(
                  key: const Key('btn_ir_a_correcciones'),
                  tooltip: 'Correcciones',
                  onPressed: () => context.push('/correcciones'),
                  icon: Badge(
                    isLabelVisible: nPendientes > 0,
                    label: Text('$nPendientes'),
                    child: const Icon(Icons.rate_review_outlined),
                  ),
                );
              },
            ),
            IconButton(
              key: const Key('btn_ir_a_dashboard_admin'),
              tooltip: 'Ver a todos',
              onPressed: () => context.push('/dashboard-admin'),
              icon: const Icon(Icons.dashboard_outlined),
            ),
          ],
          IconButton(
            key: const Key('btn_ir_a_chat'),
            tooltip: 'Chat',
            onPressed: () => context.push('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          IconButton(
            key: const Key('btn_ir_a_miembros_desde_inicio'),
            tooltip: 'Miembros y QR',
            onPressed: () => context.push('/miembros-qr'),
            icon: const Icon(Icons.group_outlined),
          ),
          IconButton(
            key: const Key('btn_ir_a_perfil_desde_inicio'),
            tooltip: 'Mi perfil',
            onPressed: () => context.push('/perfil'),
            icon: const Icon(Icons.account_circle_outlined),
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
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 24),
                    DesgloseCategorias(indicadores: indicadores),
                  ],
                  if (proximosPagos.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Próximos pagos',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          key: const Key('btn_ver_todas_deudas'),
                          onPressed: () => context.push('/deudas'),
                          child: const Text('Ver todas'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...proximosPagos.take(5).map((p) {
                      return ListTile(
                        key: Key('proximo_pago_${p.deuda.id}'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_outlined),
                        title: Text(p.deuda.entidad),
                        subtitle: Text(
                          '${formatearDiaMesCorto(p.fecha)} · '
                          '${formatCop(p.deuda.cuotaMensual)}',
                        ),
                        onTap: () => context.push('/deudas'),
                      );
                    }),
                  ],
                  if (pendientes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Gastos fijos por registrar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...pendientes.map((g) {
                      return Card(
                        key: Key('tarjeta_gasto_fijo_${g.id}'),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: ListTile(
                          title: Text(
                            '¿Registrar ${g.nombre} ${formatCop(g.monto)}?',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => mostrarNuevoMovimientoSheet(
                            context,
                            desdeGastoFijo: g,
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    key: const Key('btn_abrir_miembros_qr'),
                    onPressed: () => context.push('/miembros-qr'),
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text('Miembros y código QR'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('btn_abrir_historial'),
                    onPressed: () => context.push('/historial'),
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: const Text('Ver historial'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('btn_abrir_deudas'),
                    onPressed: () => context.push('/deudas'),
                    icon: const Icon(Icons.account_balance_outlined),
                    label: const Text('Deudas del hogar'),
                  ),
                  if (esAdmin) ...[
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      key: const Key('btn_abrir_dashboard_admin'),
                      onPressed: () => context.push('/dashboard-admin'),
                      icon: const Icon(Icons.dashboard_outlined),
                      label: const Text('Ver a todos del hogar'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Tus movimientos recientes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
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
                          final esGasto =
                              m.tipo == 'gasto' || m.tipo == 'pagoCuota';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${esGasto ? '-' : '+'}${formatCop(m.monto)}',
                            ),
                            subtitle: Text(m.periodoId),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.push('/movimiento/${m.id}'),
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
          Text('Período ${resumen.periodoId}'),
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
