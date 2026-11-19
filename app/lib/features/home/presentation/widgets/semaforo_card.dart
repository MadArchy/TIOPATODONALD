import 'package:material_ui/material_ui.dart';

import '../../../../core/indicadores.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dinero.dart';

/// Semáforo grande con texto e ícono (nunca solo color).
class SemaforoCard extends StatelessWidget {
  const SemaforoCard({
    super.key,
    required this.indicadores,
  });

  final IndicadoresPeriodo indicadores;

  @override
  Widget build(BuildContext context) {
    final colores =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;
    final esVerde = indicadores.semaforo == Semaforo.verde;
    final fondo = esVerde ? colores.verdeFondo : colores.rojoFondo;
    final color = esVerde ? colores.verde : colores.rojo;
    final icono = esVerde ? Icons.sentiment_satisfied_alt : Icons.warning_amber_rounded;
    final titulo = esVerde
        ? 'Vas bien'
        : 'Te pasaste por ${formatCop(-indicadores.disponible)}';

    return Container(
      key: const Key('semaforo_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icono, size: 56, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
