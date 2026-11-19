import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/auth_repository.dart';
import '../application/auth_controller.dart';

/// Pantalla de Perfil provisional (Slice 1) con opción para Cerrar sesión.
class PerfilProvisionalScreen extends ConsumerWidget {
  const PerfilProvisionalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAsync = ref.watch(usuarioActualProvider);
    final authState = ref.watch(authControllerProvider);
    final usuario = usuarioAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            child: Icon(
                              Icons.person_rounded,
                              size: 30,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  usuario?.nombre ?? 'Miembro',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  usuario?.email ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Día de inicio de período: ${usuario?.diaInicioPeriodo ?? 1}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (usuario?.hogarId != null &&
                  usuario!.hogarId!.trim().isNotEmpty)
                ListTile(
                  key: const Key('btn_ir_gastos_fijos'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_repeat_rounded),
                  title: const Text('Mis gastos fijos'),
                  subtitle: const Text('Arriendo, servicios y otros que se repiten'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/gastos-fijos'),
                ),
              const Spacer(),
              OutlinedButton.icon(
                key: const Key('btn_cerrar_sesion'),
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .cerrarSesion();
                      },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
