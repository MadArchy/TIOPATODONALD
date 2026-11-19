import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/deudas_internas.dart';
import '../../../core/utils/conectividad.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/deuda_interna.dart';
import '../../../data/models/pago_interno.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/deudas_internas_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import 'registrar_pago_interno_sheet.dart';

class DetalleDeudaInternaScreen extends ConsumerWidget {
  const DetalleDeudaInternaScreen({super.key, required this.deudaId});

  final String deudaId;

  Future<void> _responder(
    BuildContext context,
    WidgetRef ref,
    DeudaInterna deuda, {
    required bool aceptar,
  }) async {
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    final uid = usuario?.uid;
    if (hogarId == null || uid == null) return;
    try {
      await ref.read(deudasInternasRepositoryProvider).responderDeuda(
            hogarId: hogarId,
            deudaId: deuda.id,
            deudorUid: uid,
            aceptar: aceptar,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              aceptar ? 'Aceptaste el cobro.' : 'Rechazaste el cobro.',
            ),
          ),
        );
      }
    } on DeudasInternasException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.mensaje)),
        );
      }
    }
  }

  Future<void> _confirmarPago(
    BuildContext context,
    WidgetRef ref,
    String pagoId,
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
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (hogarId == null) return;
    try {
      final r = await ref.read(deudasInternasRepositoryProvider).confirmarPago(
            hogarId: hogarId,
            deudaInternaId: deudaId,
            pagoId: pagoId,
          );
      if (context.mounted) {
        final msg = r.estado == 'pagada'
            ? 'Pago confirmado. La deuda quedó pagada.'
            : 'Pago confirmado. Saldo: ${formatCop(r.saldo)}.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } on DeudasInternasException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.mensaje)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(usuarioActualProvider).value?.uid;
    final deudas = ref.watch(deudasInternasHogarProvider).value ?? const [];
    final miembros = ref.watch(miembrosHogarProvider).value ?? const [];
    final nombres = {for (final m in miembros) m.uid: m.nombre};
    DeudaInterna? deuda;
    for (final d in deudas) {
      if (d.id == deudaId) {
        deuda = d;
        break;
      }
    }
    final pagosAsync = ref.watch(pagosInternosProvider(deudaId));

    if (deuda == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deuda')),
        body: const Center(child: Text('No encontramos esta deuda.')),
      );
    }

    final d = deuda;
    final soyDeudor = uid == d.deudorUid;
    final soyAcreedor = uid == d.acreedorUid;
    final nombreAcreedor = nombres[d.acreedorUid] ?? 'Alguien';
    final nombreDeudor = nombres[d.deudorUid] ?? 'Alguien';

    return Scaffold(
      appBar: AppBar(title: const Text('Entre nosotros')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            d.concepto,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text('$nombreDeudor le debe a $nombreAcreedor'),
          Text('Estado: ${etiquetaEstadoDeudaInterna(d.estado)}'),
          Text('Saldo: ${formatCop(d.saldo)}'),
          Text('Monto inicial: ${formatCop(d.montoInicial)}'),
          const SizedBox(height: 16),
          if (soyDeudor && d.estado == 'pendiente') ...[
            FilledButton(
              key: const Key('btn_aceptar_deuda_interna'),
              onPressed: () => _responder(context, ref, d, aceptar: true),
              child: const Text('Aceptar cobro'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('btn_rechazar_deuda_interna'),
              onPressed: () => _responder(context, ref, d, aceptar: false),
              child: const Text('Rechazar'),
            ),
            const SizedBox(height: 16),
          ],
          if (soyDeudor && d.estado == 'aceptada' && d.saldo > 0) ...[
            FilledButton(
              key: const Key('btn_abrir_registrar_pago'),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => RegistrarPagoInternoSheet(
                    deudaId: d.id,
                    saldo: d.saldo,
                  ),
                );
              },
              child: const Text('Registrar pago'),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Pagos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          pagosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('No pudimos cargar los pagos.'),
            data: (pagos) {
              if (pagos.isEmpty) {
                return const Text('Aún no hay pagos registrados.');
              }
              return Column(
                children: [
                  for (final p in pagos)
                    _PagoTile(
                      pago: p,
                      puedeConfirmar: soyAcreedor && !p.confirmado,
                      onConfirmar: () => _confirmarPago(context, ref, p.id),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PagoTile extends StatelessWidget {
  const _PagoTile({
    required this.pago,
    required this.puedeConfirmar,
    required this.onConfirmar,
  });

  final PagoInterno pago;
  final bool puedeConfirmar;
  final VoidCallback onConfirmar;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('pago_interno_${pago.id}'),
      child: ListTile(
        title: Text(formatCop(pago.monto)),
        subtitle: Text(
          pago.confirmado ? 'Confirmado' : 'Pendiente de confirmación',
        ),
        trailing: puedeConfirmar
            ? FilledButton(
                key: Key('btn_confirmar_pago_${pago.id}'),
                onPressed: onConfirmar,
                child: const Text('Confirmar'),
              )
            : null,
      ),
    );
  }
}
