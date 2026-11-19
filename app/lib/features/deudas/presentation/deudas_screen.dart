import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/deudas_fecha.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/conectividad.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/deuda.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/deudas_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../../home/application/home_providers.dart';

/// Lista de deudas externas del hogar (Slice 5).
class DeudasScreen extends ConsumerWidget {
  const DeudasScreen({super.key});

  Future<void> _abrirFormulario(
    BuildContext context,
    WidgetRef ref, {
    Deuda? existente,
  }) async {
    final online = ref.read(tieneInternetProvider).value ?? false;
    if (!online) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kMensajeNecesitasInternet)),
        );
      }
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _FormularioDeuda(existente: existente),
    );
  }

  Future<void> _desactivar(
    BuildContext context,
    WidgetRef ref,
    Deuda deuda,
  ) async {
    final online = ref.read(tieneInternetProvider).value ?? false;
    if (!online) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kMensajeNecesitasInternet)),
        );
      }
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Desactivar esta deuda?'),
        content: Text(
          'Ya no aparecerá en la lista activa ni en las cuotas comprometidas. '
          'La deuda "${deuda.entidad}" quedará guardada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (hogarId == null) return;
    try {
      await ref.read(deudasRepositoryProvider).desactivarDeuda(
            hogarId: hogarId,
            deudaId: deuda.id,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deuda "${deuda.entidad}" desactivada.')),
        );
      }
    } on DeudasException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.mensaje)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(deudasHogarProvider);
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogar = ref.watch(hogarActualProvider).value;
    final esAdmin = hogar != null &&
        usuario != null &&
        hogar.adminUid == usuario.uid;
    final ahora = ref.watch(clockProvider).now();

    return Scaffold(
      appBar: AppBar(title: const Text('Deudas')),
      floatingActionButton: esAdmin
          ? FloatingActionButton(
              key: const Key('fab_nueva_deuda'),
              tooltip: 'Nueva deuda',
              onPressed: () => _abrirFormulario(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('No pudimos cargar las deudas del hogar.'),
        ),
        data: (lista) {
          final activas =
              lista.where((d) => d.estado == 'activa').toList();
          if (activas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  esAdmin
                      ? 'Aún no hay deudas activas. Toca + para registrar '
                          'un crédito, tarjeta o préstamo del hogar.'
                      : 'Aún no hay deudas activas en el hogar. '
                          'Cuando el admin las registre, las verás aquí.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: activas.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final d = activas[i];
              final proxima = proximaFechaPago(diaPago: d.diaPago, hoy: ahora);
              final avance = avanceDeuda(
                saldoInicial: d.saldoInicial,
                saldoActual: d.saldoActual,
              );
              final pagado = d.saldoInicial - d.saldoActual;
              return Card(
                key: Key('tarjeta_deuda_${d.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              d.entidad,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (esAdmin)
                            PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'editar') {
                                  await _abrirFormulario(
                                    context,
                                    ref,
                                    existente: d,
                                  );
                                } else if (v == 'desactivar') {
                                  await _desactivar(context, ref, d);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'editar',
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem(
                                  value: 'desactivar',
                                  child: Text('Desactivar'),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Saldo: ${formatCop(d.saldoActual)}'),
                      Text('Cuota: ${formatCop(d.cuotaMensual)}'),
                      Text(
                        'Próximo pago: ${formatearDiaMesCorto(proxima)}',
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: avance,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pagado ${formatCop(pagado < 0 ? 0 : pagado)} '
                        'de ${formatCop(d.saldoInicial)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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

class _FormularioDeuda extends ConsumerStatefulWidget {
  const _FormularioDeuda({this.existente});

  final Deuda? existente;

  @override
  ConsumerState<_FormularioDeuda> createState() => _FormularioDeudaState();
}

class _FormularioDeudaState extends ConsumerState<_FormularioDeuda> {
  late final TextEditingController _entidadCtrl;
  late final TextEditingController _saldoCtrl;
  late final TextEditingController _cuotaCtrl;
  late final TextEditingController _cuotasCtrl;
  late int _diaPago;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existente;
    _entidadCtrl = TextEditingController(text: e?.entidad ?? '');
    _saldoCtrl = TextEditingController(
      text: e == null ? '' : e.saldoInicial.toString(),
    );
    _cuotaCtrl = TextEditingController(
      text: e == null ? '' : e.cuotaMensual.toString(),
    );
    _cuotasCtrl = TextEditingController(
      text: e?.numeroCuotas?.toString() ?? '',
    );
    _diaPago = e?.diaPago ?? 1;
  }

  @override
  void dispose() {
    _entidadCtrl.dispose();
    _saldoCtrl.dispose();
    _cuotaCtrl.dispose();
    _cuotasCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (hogarId == null) {
      setState(() => _error = 'No encontramos tu hogar.');
      return;
    }

    final cuota = parseCopInput(_cuotaCtrl.text);
    if (cuota == null || cuota <= 0) {
      setState(() => _error = 'Escribe una cuota mensual mayor a \$0.');
      return;
    }

    int? numeroCuotas;
    final cuotasTxt = _cuotasCtrl.text.trim();
    if (cuotasTxt.isNotEmpty) {
      numeroCuotas = int.tryParse(cuotasTxt);
      if (numeroCuotas == null || numeroCuotas <= 0) {
        setState(() => _error = 'El número de cuotas debe ser mayor a 0.');
        return;
      }
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final repo = ref.read(deudasRepositoryProvider);
      final existente = widget.existente;
      if (existente == null) {
        final saldo = parseCopInput(_saldoCtrl.text);
        if (saldo == null || saldo <= 0) {
          setState(() {
            _error = 'Escribe un saldo inicial mayor a \$0.';
            _guardando = false;
          });
          return;
        }
        await repo.crearDeuda(
          hogarId: hogarId,
          entidad: _entidadCtrl.text,
          saldoInicial: saldo,
          cuotaMensual: cuota,
          diaPago: _diaPago,
          numeroCuotas: numeroCuotas,
        );
      } else {
        await repo.actualizarDeuda(
          hogarId: hogarId,
          deuda: existente,
          entidad: _entidadCtrl.text,
          cuotaMensual: cuota,
          diaPago: _diaPago,
          numeroCuotas: numeroCuotas,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on DeudasException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'No pudimos guardar. Revisa los datos e intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.existente != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              editando ? 'Editar deuda' : 'Nueva deuda',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('campo_entidad_deuda'),
              controller: _entidadCtrl,
              decoration: const InputDecoration(
                labelText: 'Entidad (banco, tarjeta…)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            if (!editando)
              TextField(
                key: const Key('campo_saldo_inicial_deuda'),
                controller: _saldoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial',
                  border: OutlineInputBorder(),
                ),
              ),
            if (!editando) const SizedBox(height: 12),
            if (editando) ...[
              Text(
                'Saldo actual: ${formatCop(widget.existente!.saldoActual)} '
                '(solo baja con pagos de cuota)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              key: const Key('campo_cuota_mensual_deuda'),
              controller: _cuotaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cuota mensual',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              key: const Key('dropdown_dia_pago_deuda'),
              initialValue: _diaPago,
              decoration: const InputDecoration(
                labelText: 'Día de pago (1–31)',
                border: OutlineInputBorder(),
              ),
              items: List.generate(31, (i) {
                final dia = i + 1;
                return DropdownMenuItem(value: dia, child: Text('Día $dia'));
              }),
              onChanged: (v) {
                if (v != null) setState(() => _diaPago = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('campo_numero_cuotas_deuda'),
              controller: _cuotasCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de cuotas (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('btn_guardar_deuda'),
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(editando ? 'Guardar cambios' : 'Crear deuda'),
            ),
          ],
        ),
      ),
    );
  }
}
