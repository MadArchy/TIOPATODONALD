import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/categorias.dart';
import '../../../core/movimientos_validacion.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/deudas_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';

/// Detalle de un movimiento; edición menor de nota/categoría si < 24 h.
class DetalleMovimientoScreen extends ConsumerStatefulWidget {
  const DetalleMovimientoScreen({super.key, required this.movimientoId});

  final String movimientoId;

  @override
  ConsumerState<DetalleMovimientoScreen> createState() =>
      _DetalleMovimientoScreenState();
}

class _DetalleMovimientoScreenState
    extends ConsumerState<DetalleMovimientoScreen> {
  final _notaCtrl = TextEditingController();
  String? _categoria;
  bool _editando = false;
  bool _guardando = false;
  String? _error;
  bool _camposCargados = false;

  @override
  void dispose() {
    _notaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarEdicionMenor() async {
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    final mov = ref.read(movimientoPorIdProvider(widget.movimientoId)).value;
    if (usuario == null || hogarId == null || mov == null) return;

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await ref.read(movimientosRepositoryProvider).edicionMenor(
            hogarId: hogarId,
            movimiento: mov,
            uidActual: usuario.uid,
            diaInicioPeriodo: usuario.diaInicioPeriodo,
            ahora: ref.read(clockProvider).now(),
            nota: _notaCtrl.text,
            categoria: mov.tipo == 'gasto' ? _categoria : null,
          );
      if (mounted) {
        setState(() => _editando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados')),
        );
      }
    } on MovimientosException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No pudimos guardar los cambios. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncMov = ref.watch(movimientoPorIdProvider(widget.movimientoId));
    final usuario = ref.watch(usuarioActualProvider).value;
    final ahora = ref.watch(clockProvider).now();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: asyncMov.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('No pudimos cargar este movimiento.'),
        ),
        data: (mov) {
          if (mov == null) {
            return const Center(child: Text('Este movimiento ya no existe.'));
          }

          if (!_camposCargados) {
            _notaCtrl.text = mov.nota;
            _categoria = mov.categoria;
            _camposCargados = true;
          }

          final puedeEditar = usuario != null &&
              puedeEdicionMenor(
                autorUid: mov.uid,
                uidActual: usuario.uid,
                creadoEn: mov.creadoEn,
                ahora: ahora,
                diaInicioPeriodo: usuario.diaInicioPeriodo,
                periodoIdMovimiento: mov.periodoId,
              );

          final esGasto =
              mov.tipo == 'gasto' || mov.tipo == 'pagoCuota';
          final fecha = mov.fecha;
          final fechaTxt =
              '${fecha.day.toString().padLeft(2, '0')}/'
              '${fecha.month.toString().padLeft(2, '0')}/'
              '${fecha.year}';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '${esGasto ? '-' : '+'}${formatCop(mov.monto)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                mov.tipo == 'gasto'
                    ? 'Gasto'
                    : mov.tipo == 'ingreso'
                        ? 'Ingreso'
                        : 'Pago de cuota',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (mov.tipo == 'pagoCuota')
                Builder(
                  builder: (context) {
                    final deudas =
                        ref.watch(deudasHogarProvider).value ?? const [];
                    String etiqueta = 'Pago de cuota';
                    final id = mov.deudaId;
                    if (id != null) {
                      for (final d in deudas) {
                        if (d.id == id) {
                          etiqueta = d.entidad;
                          break;
                        }
                      }
                    }
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.account_balance_outlined),
                      title: const Text('Deuda'),
                      subtitle: Text(etiqueta),
                    );
                  },
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    mov.categoria != null
                        ? iconoCategoria(mov.categoria!)
                        : Icons.payments_rounded,
                  ),
                  title: const Text('Categoría'),
                  subtitle: Text(
                    mov.categoria != null
                        ? etiquetaCategoria(mov.categoria!)
                        : 'Sin categoría',
                  ),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_rounded),
                title: const Text('Fecha'),
                subtitle: Text(fechaTxt),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notes_rounded),
                title: const Text('Nota'),
                subtitle: Text(
                  mov.nota.isEmpty ? 'Sin nota' : mov.nota,
                ),
              ),
              if (mov.fotoPath != null)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.photo_outlined),
                  title: Text('Tiene foto de recibo'),
                ),
              if (mov.estado == 'anulado')
                Text(
                  'Este movimiento está anulado.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (puedeEditar && !_editando) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const Key('btn_edicion_menor'),
                  onPressed: () => setState(() => _editando = true),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar nota o categoría'),
                ),
              ],
              if (_editando) ...[
                const SizedBox(height: 16),
                Text(
                  'Puedes cambiar la nota y la categoría (solo gasto) '
                  'durante las primeras 24 horas.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('campo_editar_nota'),
                  controller: _notaCtrl,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Nota',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (mov.tipo == 'gasto') ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: const Key('campo_editar_categoria'),
                    // ignore: deprecated_member_use
                    value: _categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: CategoriasGasto.ids
                        .map(
                          (id) => DropdownMenuItem(
                            value: id,
                            child: Text(etiquetaCategoria(id)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('btn_guardar_edicion_menor'),
                  onPressed: _guardando ? null : _guardarEdicionMenor,
                  child: _guardando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar cambios'),
                ),
                TextButton(
                  onPressed: _guardando
                      ? null
                      : () => setState(() {
                            _editando = false;
                            _notaCtrl.text = mov.nota;
                            _categoria = mov.categoria;
                            _error = null;
                          }),
                  child: const Text('Cancelar'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
