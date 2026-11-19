import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/dinero.dart';
import '../application/home_providers.dart';
import 'widgets/barra_presupuesto.dart';
import 'widgets/desglose_categorias.dart';
import 'widgets/semaforo_card.dart';

/// Desglose de un miembro (desde el dashboard admin).
class DesgloseMiembroScreen extends ConsumerWidget {
  const DesgloseMiembroScreen({super.key, required this.miembroUid});

  final String miembroUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarjetas = ref.watch(dashboardMiembrosProvider);
    TarjetaMiembroDashboard? tarjeta;
    for (final t in tarjetas) {
      if (t.uid == miembroUid) {
        tarjeta = t;
        break;
      }
    }

    if (tarjeta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('No encontramos a este miembro.')),
      );
    }

    final ind = tarjeta.indicadores;

    return Scaffold(
      appBar: AppBar(
        title: Text(tarjeta.nombre),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ind == null
              ? Text(
                  tarjeta.tienePresupuesto
                      ? 'No hay datos todavía.'
                      : 'Esta persona aún no fijó presupuesto para su período actual.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (tarjeta.periodoId != null)
                      Text(
                        'Su período: ${tarjeta.periodoId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 12),
                    SemaforoCard(indicadores: ind),
                    const SizedBox(height: 16),
                    Text(
                      ind.disponible <= 0
                          ? 'Ya usó todo su presupuesto'
                          : 'Le quedan ${formatCop(ind.disponiblePorDia)} por día',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    BarraPresupuesto(indicadores: ind),
                    if (ind.avisoPreventivo && ind.proyeccion != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'A este ritmo termina en ${formatCop(ind.proyeccion!)}',
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text('Ingresos: ${formatCop(ind.ingresos)}'),
                    const SizedBox(height: 20),
                    DesgloseCategorias(indicadores: ind),
                  ],
                ),
        ),
      ),
    );
  }
}
