import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/periodo.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/preferencias_avisos.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../../hogar/application/hogar_controller.dart';
import '../../home/application/home_providers.dart';
import '../application/auth_controller.dart';

/// Pantalla de Perfil: datos, presupuesto, día de inicio y cerrar sesión.
class PerfilProvisionalScreen extends ConsumerStatefulWidget {
  const PerfilProvisionalScreen({super.key});

  @override
  ConsumerState<PerfilProvisionalScreen> createState() =>
      _PerfilProvisionalScreenState();
}

class _PerfilProvisionalScreenState
    extends ConsumerState<PerfilProvisionalScreen> {
  final _montoController = TextEditingController();
  bool _montoInicializado = false;

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _guardarPresupuesto() async {
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    final monto = parseCopInput(_montoController.text);
    if (usuario == null || hogarId == null || monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un presupuesto mayor a \$0.')),
      );
      return;
    }

    final ok = await ref.read(hogarControllerProvider.notifier).cambiarPresupuesto(
          hogarId: hogarId,
          monto: monto,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Presupuesto actualizado.')),
      );
    } else {
      final err = ref.read(hogarControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err?.toString() ?? 'No pudimos guardar el presupuesto.'),
        ),
      );
    }
  }

  Future<void> _guardarDiaPendiente(int? dia) async {
    final usuario = ref.read(usuarioActualProvider).value;
    if (usuario == null) return;

    if (dia != null && dia == usuario.diaInicioPeriodo) {
      // Mismo día: limpiar pendiente.
      dia = null;
    }

    final ok = await ref
        .read(hogarControllerProvider.notifier)
        .guardarDiaInicioPendiente(
          uid: usuario.uid,
          diaInicioPendiente: dia,
        );
    if (!mounted) return;
    if (ok) {
      final msg = dia == null
          ? 'Se canceló el cambio de día.'
          : 'Listo. El nuevo día aplica desde el próximo período.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _guardarHoraRecordatorio(TimeOfDay? hora) async {
    final usuario = ref.read(usuarioActualProvider).value;
    if (usuario == null) return;
    final valor = hora == null
        ? null
        : '${hora.hour.toString().padLeft(2, '0')}:'
            '${hora.minute.toString().padLeft(2, '0')}';
    try {
      await ref.read(authRepositoryProvider).guardarHoraRecordatorio(
            uid: usuario.uid,
            horaRecordatorio: valor,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            valor == null
                ? 'Recordatorio diario apagado.'
                : 'Recordatorio diario a las $valor.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos guardar la hora.')),
      );
    }
  }

  Future<void> _guardarPreferencia(
    PreferenciasAvisos Function(PreferenciasAvisos) actualizar,
  ) async {
    final usuario = ref.read(usuarioActualProvider).value;
    if (usuario == null) return;
    final nuevas = actualizar(usuario.preferenciasAvisos);
    try {
      await ref.read(authRepositoryProvider).guardarPreferenciasAvisos(
            uid: usuario.uid,
            preferencias: nuevas,
          );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos guardar el aviso.')),
      );
    }
  }

  TimeOfDay? _parseHora(String? hhmm) {
    if (hhmm == null || !RegExp(r'^\d{2}:\d{2}$').hasMatch(hhmm)) {
      return null;
    }
    final partes = hhmm.split(':');
    return TimeOfDay(
      hour: int.parse(partes[0]),
      minute: int.parse(partes[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioAsync = ref.watch(usuarioActualProvider);
    final authState = ref.watch(authControllerProvider);
    final hogarState = ref.watch(hogarControllerProvider);
    final presupuesto = ref.watch(presupuestoVigenteProvider).value;
    final usuario = usuarioAsync.value;
    final ahora = ref.watch(clockProvider).now();
    final cargando = hogarState.isLoading;
    final semaforo =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    if (!_montoInicializado && presupuesto != null) {
      _montoController.text = presupuesto.monto.toString();
      _montoInicializado = true;
    }

    String? textoAplicaDesde;
    if (usuario?.diaInicioPendiente != null) {
      final periodo = periodoDe(ahora, usuario!.diaInicioPeriodo);
      final fecha = fechaAplicaDiaPendiente(
        periodoActual: periodo,
        diaPendiente: usuario.diaInicioPendiente!,
      );
      textoAplicaDesde =
          'Aplica desde el ${formatearDiaMesCorto(fecha)}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            child: Icon(
                              Icons.person_rounded,
                              size: 30,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  usuario?.nombre ?? 'Miembro',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  usuario?.email ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tu período inicia el día ${usuario?.diaInicioPeriodo ?? 1}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (textoAplicaDesde != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          key: const Key('texto_aplica_desde_dia'),
                          'Cambio a día ${usuario!.diaInicioPendiente}: $textoAplicaDesde',
                          style: TextStyle(
                            color: semaforo.preventivo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (usuario?.hogarId != null &&
                  usuario!.hogarId!.trim().isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Tu presupuesto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('input_cambiar_presupuesto'),
                  controller: _montoController,
                  enabled: !cargando,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Presupuesto de este período (COP)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const Key('btn_guardar_cambio_presupuesto'),
                  onPressed: cargando ? null : _guardarPresupuesto,
                  child: cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Guardar presupuesto'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Día de inicio del período',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Si lo cambias, aplica desde el próximo período (no parte el actual).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  key: const Key('dropdown_dia_inicio_pendiente'),
                  initialValue: usuario.diaInicioPendiente ??
                      usuario.diaInicioPeriodo,
                  decoration: const InputDecoration(
                    labelText: 'Día (1 al 28)',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  items: List.generate(28, (i) {
                    final dia = i + 1;
                    return DropdownMenuItem(
                      value: dia,
                      child: Text('Día $dia'),
                    );
                  }),
                  onChanged: cargando
                      ? null
                      : (v) {
                          if (v != null) {
                            // ignore: discarded_futures
                            _guardarDiaPendiente(v);
                          }
                        },
                ),
                if (usuario.diaInicioPendiente != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('btn_cancelar_dia_pendiente'),
                    onPressed: cargando
                        ? null
                        : () => _guardarDiaPendiente(null),
                    child: const Text('Cancelar cambio de día'),
                  ),
                ],
                const SizedBox(height: 16),
                ListTile(
                  key: const Key('btn_ir_gastos_fijos'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_repeat_rounded),
                  title: const Text('Mis gastos fijos'),
                  subtitle:
                      const Text('Arriendo, servicios y otros que se repiten'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/gastos-fijos'),
                ),
                ListTile(
                  key: const Key('btn_ir_deudas'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_outlined),
                  title: const Text('Deudas del hogar'),
                  subtitle: const Text('Créditos, tarjetas y cuotas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/deudas'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Avisos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elige a qué hora te recordamos y qué avisos quieres recibir.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ListTile(
                  key: const Key('btn_hora_recordatorio'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Recordatorio diario'),
                  subtitle: Text(
                    usuario.horaRecordatorio == null
                        ? 'Apagado'
                        : 'A las ${usuario.horaRecordatorio}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: cargando
                      ? null
                      : () async {
                          final actual =
                              _parseHora(usuario.horaRecordatorio) ??
                                  const TimeOfDay(hour: 20, minute: 0);
                          final elegida = await showTimePicker(
                            context: context,
                            initialTime: actual,
                          );
                          if (elegida != null) {
                            await _guardarHoraRecordatorio(elegida);
                          }
                        },
                ),
                if (usuario.horaRecordatorio != null)
                  TextButton(
                    key: const Key('btn_apagar_recordatorio'),
                    onPressed: cargando
                        ? null
                        : () => _guardarHoraRecordatorio(null),
                    child: const Text('Apagar recordatorio diario'),
                  ),
                SwitchListTile(
                  key: const Key('switch_aviso_presupuesto'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Alertas 50 / 80 / 100%'),
                  value: usuario.preferenciasAvisos.alertasPresupuesto,
                  onChanged: cargando
                      ? null
                      : (v) => _guardarPreferencia(
                            (p) => p.copyWith(alertasPresupuesto: v),
                          ),
                ),
                SwitchListTile(
                  key: const Key('switch_aviso_recordatorio'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Recordatorio diario (push)'),
                  value: usuario.preferenciasAvisos.recordatorioDiario,
                  onChanged: cargando
                      ? null
                      : (v) => _guardarPreferencia(
                            (p) => p.copyWith(recordatorioDiario: v),
                          ),
                ),
                SwitchListTile(
                  key: const Key('switch_aviso_cuotas'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Cuotas por vencer'),
                  value: usuario.preferenciasAvisos.cuotas,
                  onChanged: cargando
                      ? null
                      : (v) => _guardarPreferencia(
                            (p) => p.copyWith(cuotas: v),
                          ),
                ),
                SwitchListTile(
                  key: const Key('switch_aviso_correcciones'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Correcciones'),
                  value: usuario.preferenciasAvisos.correcciones,
                  onChanged: cargando
                      ? null
                      : (v) => _guardarPreferencia(
                            (p) => p.copyWith(correcciones: v),
                          ),
                ),
                SwitchListTile(
                  key: const Key('switch_aviso_deudas_internas'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deudas entre ustedes'),
                  value: usuario.preferenciasAvisos.deudasInternas,
                  onChanged: cargando
                      ? null
                      : (v) => _guardarPreferencia(
                            (p) => p.copyWith(deudasInternas: v),
                          ),
                ),
              ],
              const SizedBox(height: 24),
              OutlinedButton.icon(
                key: const Key('btn_cerrar_sesion'),
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .cerrarSesion();
                      },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
