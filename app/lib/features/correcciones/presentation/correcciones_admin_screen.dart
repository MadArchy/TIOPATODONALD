import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/categorias.dart';
import '../../../core/utils/conectividad.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/correccion.dart';
import '../../../data/models/movimiento.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/correcciones_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';

/// Bandeja de correcciones pendientes para el admin.
class CorreccionesAdminScreen extends ConsumerWidget {
  const CorreccionesAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogar = ref.watch(hogarActualProvider).value;
    final esAdmin = hogar != null &&
        usuario != null &&
        hogar.adminUid == usuario.uid;
    final pendientes = ref.watch(correccionesPendientesProvider);
    final hayInternet = ref.watch(tieneInternetProvider).value ?? true;

    if (!esAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Correcciones')),
        body: const Center(
          child: Text('Solo el administrador puede revisar correcciones.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Correcciones')),
      body: Column(
        children: [
          if (!hayInternet)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Text(
                kMensajeNecesitasInternet,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          Expanded(
            child: pendientes.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('No pudimos cargar las correcciones.'),
              ),
              data: (lista) {
                if (lista.isEmpty) {
                  return const Center(
                    child: Text('No hay correcciones pendientes.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    return _TarjetaCorreccion(
                      correccion: lista[i],
                      hayInternet: hayInternet,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCorreccion extends ConsumerStatefulWidget {
  const _TarjetaCorreccion({
    required this.correccion,
    required this.hayInternet,
  });

  final Correccion correccion;
  final bool hayInternet;

  @override
  ConsumerState<_TarjetaCorreccion> createState() => _TarjetaCorreccionState();
}

class _TarjetaCorreccionState extends ConsumerState<_TarjetaCorreccion> {
  bool _trabajando = false;

  Future<void> _resolver({required bool aprobar, String? motivo}) async {
    if (!widget.hayInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(kMensajeNecesitasInternet)),
      );
      return;
    }
    final hogarId = ref.read(usuarioActualProvider).value?.hogarId;
    if (hogarId == null) return;

    setState(() => _trabajando = true);
    try {
      await ref.read(correccionesRepositoryProvider).resolverCorreccion(
            hogarId: hogarId,
            correccionId: widget.correccion.id,
            aprobar: aprobar,
            motivoRechazo: motivo,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              aprobar ? 'Corrección aprobada.' : 'Corrección rechazada.',
            ),
          ),
        );
      }
    } on CorreccionesException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.mensaje)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos resolver la corrección. Intenta de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _pedirMotivoRechazo() async {
    final ctrl = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar corrección'),
        content: TextField(
          controller: ctrl,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo del rechazo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (motivo == null || motivo.isEmpty) return;
    await _resolver(aprobar: false, motivo: motivo);
  }

  @override
  Widget build(BuildContext context) {
    final asyncMov =
        ref.watch(movimientoPorIdProvider(widget.correccion.movimientoId));
    final miembros = ref.watch(miembrosHogarProvider).value ?? const [];
    String nombreDe(String uid) {
      for (final m in miembros) {
        if (m.uid == uid) return m.nombre;
      }
      return 'Alguien';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: asyncMov.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const Text('No se pudo cargar el movimiento.'),
          data: (mov) {
            if (mov == null) {
              return const Text('El movimiento ya no existe.');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pide ${nombreDe(widget.correccion.solicitanteUid)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.correccion.motivo,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ColumnaAntesDespues(
                        titulo: 'Antes',
                        movimiento: mov,
                      ),
                    ),
                    const Icon(Icons.arrow_forward),
                    Expanded(
                      child: _ColumnaAntesDespues(
                        titulo: 'Después',
                        movimiento: mov,
                        cambios: widget.correccion.cambios,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      context.push('/movimiento/${mov.id}'),
                  child: const Text('Ver movimiento'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _trabajando || !widget.hayInternet
                            ? null
                            : _pedirMotivoRechazo,
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: Key('btn_aprobar_${widget.correccion.id}'),
                        onPressed: _trabajando || !widget.hayInternet
                            ? null
                            : () => _resolver(aprobar: true),
                        child: _trabajando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Aprobar'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ColumnaAntesDespues extends StatelessWidget {
  const _ColumnaAntesDespues({
    required this.titulo,
    required this.movimiento,
    this.cambios,
  });

  final String titulo;
  final Movimiento movimiento;
  final Map<String, dynamic>? cambios;

  String _textoMonto() {
    if (cambios != null && cambios!.containsKey('monto')) {
      final m = cambios!['monto'];
      final n = m is int ? m : (m as num?)?.toInt();
      return formatCop(n ?? movimiento.monto);
    }
    return formatCop(movimiento.monto);
  }

  String _textoTipo() {
    final tipo = (cambios != null && cambios!.containsKey('tipo'))
        ? cambios!['tipo'] as String?
        : movimiento.tipo;
    final estado = (cambios != null && cambios!.containsKey('estado'))
        ? cambios!['estado'] as String?
        : movimiento.estado;
    if (estado == 'anulado') return 'Anulado';
    switch (tipo) {
      case 'ingreso':
        return 'Ingreso';
      case 'pagoCuota':
        return 'Pago de cuota';
      default:
        return 'Gasto';
    }
  }

  String _textoCategoria() {
    if (cambios != null && cambios!.containsKey('categoria')) {
      final c = cambios!['categoria'];
      if (c == null) return '—';
      return etiquetaCategoria(c as String);
    }
    if (cambios != null &&
        cambios!['tipo'] == 'pagoCuota') {
      return '—';
    }
    final c = movimiento.categoria;
    return c == null ? '—' : etiquetaCategoria(c);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.labelLarge),
        Text(_textoMonto(), style: Theme.of(context).textTheme.titleMedium),
        Text(_textoTipo()),
        Text(_textoCategoria(), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
