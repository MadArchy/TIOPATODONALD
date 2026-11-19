import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/clock.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/deudas_internas_repository.dart';

/// Deudor registra un pago (queda pendiente de confirmación del acreedor).
class RegistrarPagoInternoSheet extends ConsumerStatefulWidget {
  const RegistrarPagoInternoSheet({
    super.key,
    required this.deudaId,
    required this.saldo,
  });

  final String deudaId;
  final int saldo;

  @override
  ConsumerState<RegistrarPagoInternoSheet> createState() =>
      _RegistrarPagoInternoSheetState();
}

class _RegistrarPagoInternoSheetState
    extends ConsumerState<RegistrarPagoInternoSheet> {
  late final TextEditingController _montoCtrl;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _montoCtrl = TextEditingController(text: widget.saldo.toString());
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
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
    final monto = parseCopInput(_montoCtrl.text);
    if (monto == null || monto <= 0) {
      setState(() => _error = 'Escribe un monto mayor a \$0.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final ahora = ref.read(clockProvider).now();
      await ref.read(deudasInternasRepositoryProvider).registrarPago(
            hogarId: hogarId,
            deudaId: widget.deudaId,
            deudorUid: uid,
            monto: monto,
            fecha: ahora,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pago registrado. Espera a que la otra persona lo confirme.',
            ),
          ),
        );
      }
    } on DeudasInternasException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'No pudimos registrar el pago. Intenta de nuevo.',
        );
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
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Registrar pago',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Saldo actual: ${formatCop(widget.saldo)}. '
            'Quedará pendiente hasta que te lo confirmen.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('campo_monto_pago_interno'),
            controller: _montoCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monto del pago',
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
            key: const Key('btn_registrar_pago_interno'),
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Registrar pago'),
          ),
        ],
      ),
    );
  }
}
