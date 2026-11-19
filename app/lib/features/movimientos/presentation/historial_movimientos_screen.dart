import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/categorias.dart';
import '../../../core/periodo.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/miembro_hogar.dart';
import '../../../data/models/movimiento.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';

/// Historial del período con filtros Míos / Del hogar y por categoría.
class HistorialMovimientosScreen extends ConsumerStatefulWidget {
  const HistorialMovimientosScreen({super.key});

  @override
  ConsumerState<HistorialMovimientosScreen> createState() =>
      _HistorialMovimientosScreenState();
}

class _HistorialMovimientosScreenState
    extends ConsumerState<HistorialMovimientosScreen> {
  /// `mios` | `hogar`
  String _filtroQuien = 'mios';
  String? _filtroCategoria;
  /// Si null, usa el período vigente.
  String? _periodoIdSeleccionado;

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final miembros = ref.watch(miembrosHogarProvider).value ?? const <MiembroHogar>[];
    final ahora = ref.watch(clockProvider).now();

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final vigente = periodoDe(ahora, usuario.diaInicioPeriodo);
    final periodoId = _periodoIdSeleccionado ?? vigente.periodoId;
    final soloLectura = periodoId != vigente.periodoId;
    final periodoMostrado = periodoDe(
      DateTime.parse(periodoId),
      usuario.diaInicioPeriodo,
    );

    final uidFiltro = _filtroQuien == 'mios' ? usuario.uid : null;
    final movimientosAsync = ref.watch(
      movimientosPeriodoProvider((
        periodoId: periodoId,
        uid: uidFiltro,
        categoria: _filtroCategoria,
      )),
    );

    final nombres = <String, String>{
      for (final m in miembros) m.uid: m.nombre,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            tooltip: 'Período anterior',
            onPressed: () {
              final anterior = periodoDe(
                periodoMostrado.inicio.subtract(const Duration(days: 1)),
                usuario.diaInicioPeriodo,
              );
              setState(() => _periodoIdSeleccionado = anterior.periodoId);
            },
            icon: const Icon(Icons.chevron_left),
          ),
          if (soloLectura)
            IconButton(
              tooltip: 'Período vigente',
              onPressed: () => setState(() => _periodoIdSeleccionado = null),
              icon: const Icon(Icons.today_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  soloLectura
                      ? 'Período $periodoId (solo lectura)'
                      : 'Período $periodoId',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'mios', label: Text('Míos')),
                    ButtonSegment(value: 'hogar', label: Text('Del hogar')),
                  ],
                  selected: {_filtroQuien},
                  onSelectionChanged: (s) =>
                      setState(() => _filtroQuien = s.first),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  key: const Key('filtro_categoria_historial'),
                  // ignore: deprecated_member_use
                  value: _filtroCategoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todas'),
                    ),
                    ...CategoriasGasto.ids.map(
                      (id) => DropdownMenuItem<String?>(
                        value: id,
                        child: Text(etiquetaCategoria(id)),
                      ),
                    ),
                    ...CategoriasIngreso.ids.map(
                      (id) => DropdownMenuItem<String?>(
                        value: id,
                        child: Text(etiquetaCategoria(id)),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _filtroCategoria = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: movimientosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('No pudimos cargar el historial.'),
              ),
              data: (lista) {
                if (lista.isEmpty) {
                  return const Center(
                    child: Text('Aún no hay movimientos en este período.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = lista[i];
                    return _TarjetaMovimiento(
                      movimiento: m,
                      nombreQuien: nombres[m.uid] ?? 'Miembro',
                      onTap: () => context.push('/movimiento/${m.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaMovimiento extends StatelessWidget {
  const _TarjetaMovimiento({
    required this.movimiento,
    required this.nombreQuien,
    required this.onTap,
  });

  final Movimiento movimiento;
  final String nombreQuien;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cat = movimiento.categoria;
    final esGasto = movimiento.tipo == 'gasto' || movimiento.tipo == 'pagoCuota';
    final fecha = movimiento.fecha;
    final fechaTxt =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(
            cat != null ? iconoCategoria(cat) : Icons.payments_rounded,
          ),
        ),
        title: Text(
          '${esGasto ? '-' : '+'}${formatCop(movimiento.monto)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esGasto
                ? Theme.of(context).colorScheme.error
                : Colors.green.shade700,
          ),
        ),
        subtitle: Text(
          '$nombreQuien · ${cat != null ? etiquetaCategoria(cat) : 'Pago de cuota'} · $fechaTxt',
        ),
        trailing: movimiento.fotoPath != null
            ? const Icon(Icons.photo_outlined)
            : null,
      ),
    );
  }
}
