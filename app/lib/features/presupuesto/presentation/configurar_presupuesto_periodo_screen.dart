import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/periodo.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../hogar/application/hogar_controller.dart';

/// Paso siguiente tras crear o unirse a un hogar (`prompts/slice-02-hogar-qr.md` #7):
/// Pantalla "Tu presupuesto y tu período" (monto en COP + día de inicio 1–28).
/// Guarda en `usuarios.diaInicioPeriodo` y `presupuestos/{uid}_{periodoId}`.
class ConfigurarPresupuestoPeriodoScreen extends ConsumerStatefulWidget {
  const ConfigurarPresupuestoPeriodoScreen({super.key});

  @override
  ConsumerState<ConfigurarPresupuestoPeriodoScreen> createState() =>
      _ConfigurarPresupuestoPeriodoScreenState();
}

class _ConfigurarPresupuestoPeriodoScreenState
    extends ConsumerState<ConfigurarPresupuestoPeriodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  int _diaSeleccionado = 1;
  bool _inicializado = false;

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    ref.read(hogarControllerProvider.notifier).limpiarError();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    final monto = parseCopInput(_montoController.text);

    if (usuario == null || hogarId == null || monto == null) {
      return;
    }

    final exito = await ref
        .read(hogarControllerProvider.notifier)
        .guardarPresupuestoYPeriodoInicial(
          uid: usuario.uid,
          hogarId: hogarId,
          montoPresupuesto: monto,
          diaInicioPeriodo: _diaSeleccionado,
        );

    if (exito && mounted) {
      context.go('/inicio');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider).value;
    if (!_inicializado && usuario != null) {
      _diaSeleccionado = usuario.diaInicioPeriodo;
      _inicializado = true;
    }

    final ahora = ref.watch(clockProvider).now();
    final periodoPreview = periodoDe(ahora, _diaSeleccionado);
    final hogarState = ref.watch(hogarControllerProvider);
    final cargando = hogarState.isLoading;
    final semaforo =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu presupuesto y tu período'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Configura tu meta personal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cada persona en el hogar tiene su propio presupuesto y su propio día de corte.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (hogarState.hasError) ...[
                      Container(
                        key: const Key('banner_error_configurar_periodo'),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: semaforo.rojoFondo,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: semaforo.rojo, width: 1.5),
                        ),
                        child: Text(
                          hogarState.error.toString(),
                          style: TextStyle(
                            color: semaforo.rojo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      key: const Key('input_presupuesto_monto'),
                      controller: _montoController,
                      enabled: !cargando,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tu presupuesto de gasto (COP)',
                        hintText: 'Ejemplo: 2.500.000',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (valor) {
                        final monto = parseCopInput(valor ?? '');
                        if (monto == null || monto <= 0) {
                          return 'Escribe un monto entero mayor a \$0.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<int>(
                      key: const Key('dropdown_dia_inicio_periodo'),
                      initialValue: _diaSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Día en que inicia tu período (1 al 28)',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      items: List.generate(
                        28,
                        (index) {
                          final dia = index + 1;
                          return DropdownMenuItem<int>(
                            value: dia,
                            child: Text('Día $dia de cada mes'),
                          );
                        },
                      ),
                      onChanged: cargando
                          ? null
                          : (nuevoDia) {
                              if (nuevoDia != null) {
                                setState(() {
                                  _diaSeleccionado = nuevoDia;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: semaforo.verdeFondo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: semaforo.verde),
                      ),
                      child: Text(
                        'Tu período actual inicia el ${periodoPreview.periodoId} (${periodoPreview.diasTotales} días).',
                        style: TextStyle(
                          color: semaforo.verde,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('btn_guardar_presupuesto_periodo'),
                      onPressed: cargando ? null : _guardar,
                      child: cargando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Text('Guardar y continuar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
