import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/correcciones_repository.dart';
import '../../../data/repositories/hogar_repository.dart';

/// Pestaña "Hogar" de la barra inferior (Slice 8.5 — C1).
/// Centraliza Perfil, Mis gastos fijos, Miembros y QR, y (para admin)
/// Panel del hogar y Correcciones con contador.
class HogarTabScreen extends ConsumerWidget {
  const HogarTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogar = ref.watch(hogarActualProvider).value;
    final esAdmin =
        hogar != null && usuario != null && hogar.adminUid == usuario.uid;
    final pendientesAdmin = esAdmin
        ? (ref.watch(correccionesPendientesProvider).value?.length ?? 0)
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(hogar?.nombre ?? 'Hogar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  key: const Key('hogar_item_perfil'),
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Mi perfil y presupuesto'),
                  subtitle: Text(usuario?.nombre ?? 'Configuración personal'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/perfil'),
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('hogar_item_gastos_fijos'),
                  leading: const Icon(Icons.event_repeat_rounded),
                  title: const Text('Mis gastos fijos'),
                  subtitle: const Text('Arriendo, servicios y pagos repetitivos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/gastos-fijos'),
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('hogar_item_miembros_qr'),
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('Miembros y código QR'),
                  subtitle: const Text('Quién está en el hogar e invitar'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/miembros-qr'),
                ),
              ],
            ),
          ),
          if (esAdmin) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                'Administración del hogar',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Card(
              child: Column(
                children: [
                  ListTile(
                    key: const Key('hogar_item_panel_admin'),
                    leading: const Icon(Icons.analytics_outlined),
                    title: const Text('Panel del hogar'),
                    subtitle: const Text('Cómo va cada miembro y margen real'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/dashboard-admin'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    key: const Key('hogar_item_correcciones'),
                    leading: Badge(
                      isLabelVisible: pendientesAdmin > 0,
                      label: Text('$pendientesAdmin'),
                      child: const Icon(Icons.fact_check_outlined),
                    ),
                    title: const Text('Correcciones'),
                    subtitle: Text(
                      pendientesAdmin > 0
                          ? '$pendientesAdmin por revisar'
                          : 'Solicitudes de cambio de la familia',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/correcciones'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
