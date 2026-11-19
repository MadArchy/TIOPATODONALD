import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/periodo.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/conectividad.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/movimiento.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';
import '../../movimientos/presentation/nuevo_movimiento_sheet.dart';

/// Pantalla de Inicio provisional (Slice 2–3) con FAB de nuevo movimiento.
class InicioProvisionalScreen extends ConsumerWidget {
  const InicioProvisionalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogar = ref.watch(hogarActualProvider).value;
    final presupuesto = ref.watch(presupuestoVigenteProvider).value;
    final pendientes = ref.watch(gastosFijosPendientesHoyProvider);
    final ahora = ref.watch(clockProvider).now();

    // Reintentar fotos pendientes al abrir inicio.
    ref.listen(tieneInternetProvider, (prev, next) {
      final hogarId = usuario?.hogarId;
      if ((next.value ?? false) && hogarId != null) {
        // ignore: discarded_futures
        ref
            .read(movimientosRepositoryProvider)
            .sincronizarFotosPendientes(hogarId);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(hogar?.nombre ?? 'Inicio'),
        actions: [
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
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.home_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hogar?.nombre ?? 'Inicio del hogar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (presupuesto != null)
                    Text(
                      'Tu presupuesto del período (${presupuesto.periodoId}): '
                      '${formatCop(presupuesto.monto)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      'Aún no has fijado tu presupuesto para este período.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  if (pendientes.isNotEmpty) ...[
                    const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const Key('btn_abrir_miembros_qr'),
                    onPressed: () => context.push('/miembros-qr'),
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text('Miembros y código QR'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('btn_abrir_configurar_periodo'),
                    onPressed: () => context.push('/configurar-periodo'),
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(
                      'Tu presupuesto y período '
                      '(Día ${usuario?.diaInicioPeriodo ?? 1})',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('btn_abrir_historial'),
                    onPressed: () => context.push('/historial'),
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: const Text('Ver historial'),
                  ),
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
                          final esGasto = m.tipo == 'gasto' ||
                              m.tipo == 'pagoCuota';
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
