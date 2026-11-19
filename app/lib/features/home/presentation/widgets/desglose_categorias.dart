import 'package:material_ui/material_ui.dart';

import '../../../../core/categorias.dart';
import '../../../../core/indicadores.dart';
import '../../../../core/utils/dinero.dart';

/// Barras horizontales por categoría + % reducible.
class DesgloseCategorias extends StatelessWidget {
  const DesgloseCategorias({
    super.key,
    required this.indicadores,
  });

  final IndicadoresPeriodo indicadores;

  @override
  Widget build(BuildContext context) {
    final entries = indicadores.porCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final pctReducible = (indicadores.porcentajeReducible * 100).round();

    return Column(
      key: const Key('desglose_categorias'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '¿En qué se va la plata?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          pctReducible > 0
              ? '$pctReducible% es reducible (ocio y otros)'
              : 'Aún no hay gastos reducibles',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Text(
            'Todavía no has registrado gastos en este período.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          ...entries.map((e) {
            final label = e.key == 'pagoCuota'
                ? 'Pago de cuota'
                : etiquetaCategoria(e.key);
            final icono = e.key == 'pagoCuota'
                ? Icons.account_balance_rounded
                : iconoCategoria(e.key);
            final frac = e.value / maxVal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(icono, size: 22),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: frac.clamp(0.0, 1.0),
                        minHeight: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatCop(e.value),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
