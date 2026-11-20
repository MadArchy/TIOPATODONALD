import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/categorias.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/movimiento.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/correcciones_repository.dart';
import '../../../data/repositories/deudas_repository.dart';
import '../../../data/repositories/hogar_repository.dart';

/// Hoja para solicitar corrección de un movimiento (Slice 7).
Future<void> mostrarPedirCorreccionSheet(
  BuildContext context, {
  required Movimiento movimiento,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => PedirCorreccionSheet(movimiento: movimiento),
  );
}

class PedirCorreccionSheet extends ConsumerStatefulWidget {
  const PedirCorreccionSheet({super.key, required this.movimiento});

  final Movimiento movimiento;

  @override
  ConsumerState<PedirCorreccionSheet> createState() =>
      _PedirCorreccionSheetState();
}

enum _TipoCambio {
  monto,
  categoria,
  anular,
  reclasificarCuota,
}

class _PedirCorreccionSheetState extends ConsumerState<PedirCorreccionSheet> {
  final _motivoCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  _TipoCambio _tipo = _TipoCambio.monto;
  String? _categoria;
  String? _deudaId;
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _montoCtrl.text = formatCopSinSimbolo(widget.movimiento.monto);
    _categoria = widget.movimiento.categoria;
    _deudaId = widget.movimiento.deudaId;
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _construirCambios() {
    final mov = widget.movimiento;
    switch (_tipo) {
      case _TipoCambio.monto:
        final monto = parseCopInput(_montoCtrl.text);
        if (monto == null || monto <= 0) {
          setState(() => _error = 'Escribe un monto válido mayor a \$0.');
          return null;
        }
        if (monto == mov.monto) {
          setState(() => _error = 'El monto es el mismo. Cambia algo.');
          return null;
        }
        return {'monto': monto};
      case _TipoCambio.categoria:
        if (_categoria == null) {
          setState(() => _error = 'Elige una categoría.');
          return null;
        }
        if (_categoria == mov.categoria) {
          setState(() => _error = 'La categoría es la misma. Cambia algo.');
          return null;
        }
        return {'categoria': _categoria};
      case _TipoCambio.anular:
        return {'estado': 'anulado'};
      case _TipoCambio.reclasificarCuota:
        if (_deudaId == null || _deudaId!.isEmpty) {
          setState(() => _error = 'Elige la deuda del pago de cuota.');
          return null;
        }
        return {
          'tipo': 'pagoCuota',
          'categoria': null,
          'deudaId': _deudaId,
        };
    }
  }

  Future<void> _enviar() async {
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (usuario == null || hogarId == null) return;

    final hogar = ref.read(hogarActualProvider).value;
    final diaParaPlazo = int.tryParse(
          widget.movimiento.periodoId.split('-').last,
        ) ??
        usuario.diaInicioPeriodo;

    setState(() {
      _enviando = true;
      _error = null;
    });

    final cambios = _construirCambios();
    if (cambios == null) {
      setState(() => _enviando = false);
      return;
    }

    try {
      await ref.read(correccionesRepositoryProvider).pedirCorreccion(
            hogarId: hogarId,
            movimiento: widget.movimiento,
            solicitanteUid: usuario.uid,
            diaInicioDueno: diaParaPlazo,
            ahora: ref.read(clockProvider).now(),
            motivo: _motivoCtrl.text,
            cambios: cambios,
          );
      if (mounted) {
        Navigator.of(context).pop();
        final esAdmin =
            hogar != null && hogar.adminUid == usuario.uid;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              esAdmin && widget.movimiento.uid == usuario.uid
                  ? 'Corrección pedida. Apruébala en Correcciones.'
                  : 'Pediste la corrección. El admin la revisará.',
            ),
          ),
        );
      }
    } on CorreccionesException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'No pudimos enviar la corrección. Revisa tu conexión e intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mov = widget.movimiento;
    final deudas = (ref.watch(deudasHogarProvider).value ?? const [])
        .where((d) => d.estado == 'activa')
        .toList();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pedir corrección',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Actual: ${formatCop(mov.monto)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Monto'),
                  selected: _tipo == _TipoCambio.monto,
                  onSelected: (_) => setState(() => _tipo = _TipoCambio.monto),
                ),
                if (mov.tipo == 'gasto' || mov.tipo == 'ingreso')
                  ChoiceChip(
                    label: const Text('Categoría'),
                    selected: _tipo == _TipoCambio.categoria,
                    onSelected: (_) =>
                        setState(() => _tipo = _TipoCambio.categoria),
                  ),
                ChoiceChip(
                  label: const Text('Anular'),
                  selected: _tipo == _TipoCambio.anular,
                  onSelected: (_) => setState(() => _tipo = _TipoCambio.anular),
                ),
                if (mov.tipo == 'gasto')
                  ChoiceChip(
                    label: const Text('Era pago de cuota'),
                    selected: _tipo == _TipoCambio.reclasificarCuota,
                    onSelected: (_) =>
                        setState(() => _tipo = _TipoCambio.reclasificarCuota),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tipo == _TipoCambio.monto)
              TextField(
                key: const Key('campo_correccion_monto'),
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: const [CopInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Monto correcto',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_tipo == _TipoCambio.categoria)
              DropdownButtonFormField<String>(
                key: const Key('campo_correccion_categoria'),
                // ignore: deprecated_member_use
                value: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría correcta',
                  border: OutlineInputBorder(),
                ),
                items: (mov.tipo == 'ingreso'
                        ? CategoriasIngreso.ids
                        : CategoriasGasto.ids)
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(etiquetaCategoria(id)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v),
              ),
            if (_tipo == _TipoCambio.anular)
              Text(
                'Se pedirá anular este movimiento. No se borra: queda como anulado.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (_tipo == _TipoCambio.reclasificarCuota)
              DropdownButtonFormField<String>(
                key: const Key('campo_correccion_deuda'),
                // ignore: deprecated_member_use
                value: _deudaId,
                decoration: const InputDecoration(
                  labelText: 'Deuda',
                  border: OutlineInputBorder(),
                ),
                items: deudas
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.id,
                        child: Text('${d.entidad} (${formatCop(d.cuotaMensual)})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _deudaId = v),
              ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('campo_correccion_motivo'),
              controller: _motivoCtrl,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo (obligatorio)',
                border: OutlineInputBorder(),
              ),
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
              key: const Key('btn_enviar_correccion'),
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
