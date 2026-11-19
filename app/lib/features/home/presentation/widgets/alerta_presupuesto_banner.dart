import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';

/// Banner in-app de alertas 50 / 80 / 100 % (push llega en slice 9).
class AlertaPresupuestoBanner extends StatelessWidget {
  const AlertaPresupuestoBanner({
    super.key,
    required this.umbrales,
    this.onDismiss,
  });

  final List<int> umbrales;
  final VoidCallback? onDismiss;

  String get _mensaje {
    if (umbrales.contains(100)) {
      return 'Llegaste al 100% de tu presupuesto.';
    }
    if (umbrales.contains(80)) {
      return 'Ya usaste el 80% de tu presupuesto.';
    }
    if (umbrales.contains(50)) {
      return 'Vas por la mitad de tu presupuesto.';
    }
    return 'Revisa tu presupuesto.';
  }

  @override
  Widget build(BuildContext context) {
    if (umbrales.isEmpty) return const SizedBox.shrink();
    final colores =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;
    final esRojo = umbrales.contains(100);
    final fondo = esRojo ? colores.rojoFondo : colores.preventivoFondo;
    final color = esRojo ? colores.rojo : colores.preventivo;

    return Container(
      key: const Key('banner_alerta_presupuesto'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _mensaje,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              key: const Key('btn_cerrar_alerta_presupuesto'),
              tooltip: 'Entendido',
              onPressed: onDismiss,
              icon: Icon(Icons.close, color: color),
            ),
        ],
      ),
    );
  }
}
