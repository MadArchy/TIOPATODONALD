import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/categorias.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/gasto_fijo.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';

/// CRUD de plantillas "Mis gastos fijos" (Perfil).
class GastosFijosScreen extends ConsumerWidget {
  const GastosFijosScreen({super.key});

  Future<void> _abrirFormulario(
    BuildContext context,
    WidgetRef ref, {
    GastoFijo? existente,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _FormularioGastoFijo(existente: existente),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gastosFijosPropiosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis gastos fijos')),
      floatingActionButton: FloatingActionButton(
        key: const Key('fab_nuevo_gasto_fijo'),
        onPressed: () => _abrirFormulario(context, ref),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('No pudimos cargar tus gastos fijos.'),
        ),
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aquí puedes guardar arriendo, servicios y otros gastos '
                  'que se repiten. El día esperado te preguntaremos si quieres registrarlos.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final g = lista[i];
              return Card(
                child: ListTile(
                  leading: Icon(iconoCategoria(g.categoria)),
                  title: Text(g.nombre),
                  subtitle: Text(
                    '${formatCop(g.monto)} · Día ${g.diaEsperado}'
                    '${g.activo ? '' : ' · Pausado'}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      final usuario = ref.read(usuarioActualProvider).value;
                      final hogarId = usuario?.hogarId;
                      if (hogarId == null) return;
                      if (v == 'editar') {
                        await _abrirFormulario(context, ref, existente: g);
                      } else if (v == 'eliminar') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('¿Eliminar gasto fijo?'),
                            content: Text(
                              'Se quitará "${g.nombre}" de tus plantillas.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await ref
                              .read(movimientosRepositoryProvider)
                              .eliminarGastoFijo(
                                hogarId: hogarId,
                                gastoFijoId: g.id,
                              );
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FormularioGastoFijo extends ConsumerStatefulWidget {
  const _FormularioGastoFijo({this.existente});

  final GastoFijo? existente;

  @override
  ConsumerState<_FormularioGastoFijo> createState() =>
      _FormularioGastoFijoState();
}

class _FormularioGastoFijoState extends ConsumerState<_FormularioGastoFijo> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _montoCtrl;
  late final TextEditingController _diaCtrl;
  late String _categoria;
  late bool _activo;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existente;
    _nombreCtrl = TextEditingController(text: e?.nombre ?? '');
    _montoCtrl = TextEditingController(
      text: e != null ? e.monto.toString() : '',
    );
    _diaCtrl = TextEditingController(
      text: e != null ? e.diaEsperado.toString() : '1',
    );
    _categoria = e?.categoria ?? CategoriasGasto.vivienda;
    _activo = e?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _montoCtrl.dispose();
    _diaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (usuario == null || hogarId == null) {
      setState(() => _error = 'No encontramos tu hogar.');
      return;
    }

    final monto = parseCopInput(_montoCtrl.text);
    final dia = int.tryParse(_diaCtrl.text.trim());
    if (monto == null || monto <= 0) {
      setState(() => _error = 'Escribe un monto mayor a \$0.');
      return;
    }
    if (dia == null || dia < 1 || dia > 31) {
      setState(() => _error = 'El día esperado debe estar entre 1 y 31.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final repo = ref.read(movimientosRepositoryProvider);
      final existente = widget.existente;
      if (existente == null) {
        await repo.crearGastoFijo(
          hogarId: hogarId,
          uid: usuario.uid,
          nombre: _nombreCtrl.text,
          monto: monto,
          categoria: _categoria,
          diaEsperado: dia,
        );
      } else {
        await repo.actualizarGastoFijo(
          hogarId: hogarId,
          gasto: existente,
          nombre: _nombreCtrl.text,
          monto: monto,
          categoria: _categoria,
          diaEsperado: dia,
          activo: _activo,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on MovimientosException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No pudimos guardar. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existente == null ? 'Nuevo gasto fijo' : 'Editar gasto fijo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('campo_nombre_gasto_fijo'),
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre (ej. Arriendo)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('campo_monto_gasto_fijo'),
              controller: _montoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
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
              onChanged: (v) {
                if (v != null) setState(() => _categoria = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('campo_dia_gasto_fijo'),
              controller: _diaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Día esperado (1–31)',
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.existente != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('btn_guardar_gasto_fijo'),
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? 'Guardando…' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
