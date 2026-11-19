import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/dinero.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/hogar_repository.dart';

/// Pantalla de Inicio provisional para el Slice 2 (antes del Home real del Slice 4).
/// Permite acceder a "Miembros y QR" y a "Tu presupuesto y tu período".
class InicioProvisionalScreen extends ConsumerWidget {
  const InicioProvisionalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogar = ref.watch(hogarActualProvider).value;
    final presupuesto = ref.watch(presupuestoVigenteProvider).value;

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.home_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
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
                      'Tu presupuesto del período (${presupuesto.periodoId}): ${formatCop(presupuesto.monto)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      'Aún no has fijado tu presupuesto para este período.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),
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
                      'Tu presupuesto y período (Día ${usuario?.diaInicioPeriodo ?? 1})',
                    ),
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
