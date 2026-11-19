import 'package:material_ui/material_ui.dart';

import '../../../../core/indicadores.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dinero.dart';

/// Barra gastado/presupuesto con marcas en 50 / 80 / 100 %.
class BarraPresupuesto extends StatelessWidget {
  const BarraPresupuesto({
    super.key,
    required this.indicadores,
  });

  final IndicadoresPeriodo indicadores;

  @override
  Widget build(BuildContext context) {
    final colores =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;
    final presupuesto = indicadores.presupuesto;
    final gastado = indicadores.gastado;
    final ratio = presupuesto <= 0
        ? (gastado > 0 ? 1.0 : 0.0)
        : (gastado / presupuesto).clamp(0.0, 1.5);
    final progresoVisual = ratio.clamp(0.0, 1.0);
    final color = indicadores.semaforo == Semaforo.verde
        ? colores.verde
        : colores.rojo;

    return Column(
      key: const Key('barra_presupuesto'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gastado ${formatCop(gastado)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'de ${formatCop(presupuesto)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: 28,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 16,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progresoVisual,
                    child: Container(
                      height: 16,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ...[0.5, 0.8, 1.0].map((marca) {
                    final left = (w * marca) - 1;
                    return Positioned(
                      left: left.clamp(0, w - 2),
                      top: 0,
                      child: Container(
                        width: 2,
                        height: 28,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.45),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SizedBox(width: 8),
            Text('50%', style: TextStyle(fontSize: 11)),
            Text('80%', style: TextStyle(fontSize: 11)),
            Text('100%', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
