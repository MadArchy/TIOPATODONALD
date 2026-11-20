import 'package:material_ui/material_ui.dart';

import '../../../../core/categorias.dart';
import '../../../../core/periodo.dart';
import '../../../../core/utils/dinero.dart';
import '../../../../data/models/movimiento.dart';

/// Fila legible de movimiento para Inicio e Historial (Slice 8.5 — C3).
/// Muestra ícono y nombre de categoría (o deuda), nota, fecha humana
/// (`hoy` / `ayer` / `lun 17`), quién (en "Del hogar") e ícono si tiene foto.
/// Nunca muestra `periodoId`.
class FilaMovimiento extends StatelessWidget {
  const FilaMovimiento({
    super.key,
    required this.movimiento,
    required this.ahora,
    required this.onTap,
    this.nombreQuien,
    this.nombreDeuda,
  });

  final Movimiento movimiento;
  final DateTime ahora;
  final VoidCallback onTap;

  /// Si no es null, se muestra el nombre del autor (p. ej. en "Del hogar").
  final String? nombreQuien;

  /// Nombre de la deuda cuando `movimiento.tipo == 'pagoCuota'`.
  final String? nombreDeuda;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = movimiento.categoria;
    final esGasto =
        movimiento.tipo == 'gasto' || movimiento.tipo == 'pagoCuota';
    final anulado = movimiento.estado == 'anulado';

    final titulo = cat != null
        ? etiquetaCategoria(cat)
        : (nombreDeuda != null && nombreDeuda!.isNotEmpty
            ? 'Cuota · $nombreDeuda'
            : 'Pago de cuota');

    final fechaTxt = formatearFechaHumana(movimiento.fecha, ahora);
    final partesSub = <String>[];
    if (nombreQuien != null && nombreQuien!.isNotEmpty) {
      partesSub.add(nombreQuien!);
    }
    if (movimiento.nota.trim().isNotEmpty) {
      partesSub.add(movimiento.nota.trim());
    }
    partesSub.add(fechaTxt);
    if (anulado) {
      partesSub.add('Anulado');
    }

    final montoColor = anulado
        ? theme.colorScheme.outline
        : (esGasto ? theme.colorScheme.error : Colors.green.shade700);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(
            cat != null ? iconoCategoria(cat) : Icons.payments_rounded,
          ),
        ),
        title: Text(
          titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: anulado ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          partesSub.join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (movimiento.fotoPath != null) ...[
              Icon(
                Icons.photo_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              '${esGasto ? '-' : '+'}${formatCop(movimiento.monto)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: montoColor,
                decoration: anulado ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
