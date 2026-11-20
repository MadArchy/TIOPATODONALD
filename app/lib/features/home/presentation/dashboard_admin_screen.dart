import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/indicadores.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../application/home_providers.dart';

/// Dashboard del admin: margen real del hogar + tarjeta por miembro.
class DashboardAdminScreen extends ConsumerWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogar = ref.watch(hogarActualProvider).value;
    final esAdmin = hogar != null &&
        usuario != null &&
        hogar.adminUid == usuario.uid;

    if (!esAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Panel del hogar')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Solo el administrador del hogar puede ver el panel del hogar.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final tarjetas = ref.watch(dashboardMiembrosProvider);
    final margen = ref.watch(margenRealHogarProvider);
    final colores =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del hogar'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              key: const Key('margen_real_hogar'),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: margen >= 0 ? colores.verdeFondo : colores.rojoFondo,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: margen >= 0 ? colores.verde : colores.rojo,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Margen real del hogar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: margen >= 0 ? colores.verde : colores.rojo,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatCop(margen),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: margen >= 0 ? colores.verde : colores.rojo,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ingresos − gastos − cuotas pendientes de cada uno en su período.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cada persona',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...tarjetas.map((t) {
              final ind = t.indicadores;
              final esVerde = ind?.semaforo != Semaforo.rojo;
              final color = esVerde ? colores.verde : colores.rojo;
              final pct = ind == null
                  ? 0
                  : (ind.porcentajeReducible * 100).round();

              return Card(
                key: Key('tarjeta_miembro_${t.uid}'),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: Icon(
                    esVerde
                        ? Icons.sentiment_satisfied_alt
                        : Icons.warning_amber_rounded,
                    color: color,
                    size: 36,
                  ),
                  title: Text(
                    t.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    !t.tienePresupuesto || ind == null
                        ? 'Sin presupuesto en su período'
                        : '${formatCop(ind.gastado)} / ${formatCop(ind.presupuesto)}'
                            '${pct > 0 ? ' · $pct% reducible' : ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/desglose-miembro/${t.uid}'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
