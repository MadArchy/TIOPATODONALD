import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/dinero.dart';
import '../../../data/models/miembro_hogar.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/deudas_internas_repository.dart';
import '../../../data/repositories/hogar_repository.dart';

/// Formulario: acreedor crea cobro a otro miembro (estado pendiente).
class CrearDeudaInternaSheet extends ConsumerStatefulWidget {
  const CrearDeudaInternaSheet({super.key});

  @override
  ConsumerState<CrearDeudaInternaSheet> createState() =>
      _CrearDeudaInternaSheetState();
}

class _CrearDeudaInternaSheetState
    extends ConsumerState<CrearDeudaInternaSheet> {
  final _montoCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  String? _deudorUid;
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _montoCtrl.dispose();
    _conceptoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    final uid = usuario?.uid;
    if (hogarId == null || uid == null) {
      setState(() => _error = 'No encontramos tu hogar.');
      return;
    }
    if (_deudorUid == null) {
      setState(() => _error = 'Elige a quién le cobras.');
      return;
    }
    final monto = parseCopInput(_montoCtrl.text);
    if (monto == null || monto <= 0) {
      setState(() => _error = 'Escribe un monto mayor a \$0.');
      return;
    }
    if (_conceptoCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Escribe un concepto.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref.read(deudasInternasRepositoryProvider).crearDeudaInterna(
            hogarId: hogarId,
            acreedorUid: uid,
            deudorUid: _deudorUid!,
            monto: monto,
            concepto: _conceptoCtrl.text,
          );
      if (mounted) Navigator.of(context).pop();
    } on DeudasInternasException catch (e) {
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
    final uid = ref.watch(usuarioActualProvider).value?.uid;
    final miembros =
        (ref.watch(miembrosHogarProvider).value ?? const <MiembroHogar>[])
            .where((m) => m.uid != uid && m.estado == 'activo')
            .toList();

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
              'Cobrar a alguien',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'La otra persona debe aceptar el cobro.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('dropdown_deudor_interno'),
              initialValue: _deudorUid,
              decoration: const InputDecoration(
                labelText: 'Quién te debe',
                border: OutlineInputBorder(),
              ),
              items: miembros
                  .map(
                    (m) => DropdownMenuItem(
                      value: m.uid,
                      child: Text(m.nombre),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _deudorUid = v),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('campo_monto_interno'),
              controller: _montoCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: const [CopInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('campo_concepto_interno'),
              controller: _conceptoCtrl,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Concepto',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
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
              key: const Key('btn_crear_deuda_interna'),
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear cobro'),
            ),
          ],
        ),
      ),
    );
  }
}
