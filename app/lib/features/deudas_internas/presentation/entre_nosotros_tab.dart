import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/deudas_internas.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/deuda_interna.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/deudas_internas_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../application/avisos_internos_provider.dart';
import 'crear_deuda_interna_sheet.dart';

/// Sección "Entre nosotros": Me deben / Debo + avisos pendientes.
class EntreNosotrosTab extends ConsumerStatefulWidget {
  const EntreNosotrosTab({super.key});

  @override
  ConsumerState<EntreNosotrosTab> createState() => _EntreNosotrosTabState();
}

class _EntreNosotrosTabState extends ConsumerState<EntreNosotrosTab>
    with SingleTickerProviderStateMixin {
  late final TabController _subTabs;

  @override
  void initState() {
    super.initState();
    _subTabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabs.dispose();
    super.dispose();
  }

  Future<void> _abrirCrear() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CrearDeudaInternaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(deudasInternasHogarProvider);
    final uid = ref.watch(usuarioActualProvider).value?.uid;
    final miembros = ref.watch(miembrosHogarProvider).value ?? const [];
    final nombres = {for (final m in miembros) m.uid: m.nombre};
    final avisos = ref.watch(avisosInternosProvider);

    return Column(
      children: [
        if (avisos.isNotEmpty)
          Material(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Pendientes de tu acción (${avisos.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                for (final a in avisos)
                  ListTile(
                    key: Key('aviso_interno_${a.deudaId}_${a.pagoId ?? 'x'}'),
                    dense: true,
                    leading: Icon(
                      a.tipo == TipoAvisoInterno.pendienteAceptacion
                          ? Icons.handshake_outlined
                          : Icons.payments_outlined,
                    ),
                    title: Text(a.titulo),
                    subtitle: Text(a.detalle),
                    onTap: () => context.push('/deudas-internas/${a.deudaId}'),
                  ),
              ],
            ),
          ),
        TabBar(
          controller: _subTabs,
          tabs: const [
            Tab(text: 'Me deben'),
            Tab(text: 'Debo'),
          ],
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(
              child: Text('No pudimos cargar las deudas entre ustedes.'),
            ),
            data: (lista) {
              final meDeben = lista
                  .where((d) => d.acreedorUid == uid)
                  .where((d) => d.estado != 'rechazada')
                  .toList();
              final debo = lista
                  .where((d) => d.deudorUid == uid)
                  .where((d) => d.estado != 'rechazada')
                  .toList();

              return TabBarView(
                controller: _subTabs,
                children: [
                  _ListaDeudasInternas(
                    deudas: meDeben,
                    uid: uid,
                    nombres: nombres,
                    vacio:
                        'Nadie te debe algo por ahora. Toca el botón para '
                        'registrar un cobro.',
                  ),
                  _ListaDeudasInternas(
                    deudas: debo,
                    uid: uid,
                    nombres: nombres,
                    vacio: 'No le debes a nadie por ahora.',
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton.icon(
            key: const Key('btn_nuevo_cobro_interno'),
            onPressed: _abrirCrear,
            icon: const Icon(Icons.add),
            label: const Text('Cobrar a alguien'),
          ),
        ),
      ],
    );
  }
}

class _ListaDeudasInternas extends StatelessWidget {
  const _ListaDeudasInternas({
    required this.deudas,
    required this.uid,
    required this.nombres,
    required this.vacio,
  });

  final List<DeudaInterna> deudas;
  final String? uid;
  final Map<String, String> nombres;
  final String vacio;

  @override
  Widget build(BuildContext context) {
    if (deudas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(vacio, textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: deudas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final d = deudas[i];
        final contraparteUid =
            d.acreedorUid == uid ? d.deudorUid : d.acreedorUid;
        final nombre = nombres[contraparteUid] ?? 'Alguien';
        final soyAcreedor = d.acreedorUid == uid;
        return Card(
          key: Key('tarjeta_deuda_interna_${d.id}'),
          child: ListTile(
            title: Text(
              soyAcreedor ? '$nombre te debe' : 'Le debes a $nombre',
            ),
            subtitle: Text(
              '${d.concepto}\n'
              '${etiquetaEstadoDeudaInterna(d.estado)} · '
              'Saldo ${formatCop(d.saldo)}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/deudas-internas/${d.id}'),
          ),
        );
      },
    );
  }
}
