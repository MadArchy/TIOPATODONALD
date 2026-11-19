import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/conectividad.dart';
import '../../../data/models/invitacion_hogar.dart';
import '../../../data/models/miembro_hogar.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/hogar_repository.dart';
import '../application/hogar_controller.dart';

/// Pantalla de Miembros y QR del hogar (`prompts/slice-02-hogar-qr.md` #3):
/// - Lista de miembros activos del hogar.
/// - Si es admin:
///   - Botón "Invitar" que muestra el QR (`qr_flutter`) con cuenta regresiva de 4 h.
///   - Botón "Generar nuevo".
///   - Botón "Sacar" por miembro (con diálogo de confirmación).
/// - Si no hay internet, muestra "Necesitas internet para esto".
class MiembrosQrScreen extends ConsumerStatefulWidget {
  const MiembrosQrScreen({super.key});

  @override
  ConsumerState<MiembrosQrScreen> createState() => _MiembrosQrScreenState();
}

class _MiembrosQrScreenState extends ConsumerState<MiembrosQrScreen> {
  Timer? _timerCuentaRegresiva;
  InvitacionHogar? _invitacionReciente;

  @override
  void initState() {
    super.initState();
    _timerCuentaRegresiva = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timerCuentaRegresiva?.cancel();
    super.dispose();
  }

  void _mostrarSinInternet() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(kMensajeNecesitasInternet)),
      );
  }

  String _formatearCuentaRegresiva(Duration restante) {
    final totalSegundos = restante.inSeconds;
    if (totalSegundos <= 0) {
      return '00:00:00 (Vencido)';
    }
    final horas = (totalSegundos ~/ 3600).toString().padLeft(2, '0');
    final minutos = ((totalSegundos % 3600) ~/ 60).toString().padLeft(2, '0');
    final segundos = (totalSegundos % 60).toString().padLeft(2, '0');
    return '$horas:$minutos:$segundos';
  }

  Future<void> _generarQr({
    required String hogarId,
    required bool hayInternet,
  }) async {
    ref.read(hogarControllerProvider.notifier).limpiarError();
    if (!hayInternet) {
      _mostrarSinInternet();
      return;
    }

    final nueva = await ref
        .read(hogarControllerProvider.notifier)
        .generarInvitacion(hogarId: hogarId);
    if (nueva != null && mounted) {
      setState(() {
        _invitacionReciente = nueva;
      });
    }
  }

  Future<void> _confirmarSacarMiembro({
    required String hogarId,
    required MiembroHogar miembro,
    required bool hayInternet,
  }) async {
    ref.read(hogarControllerProvider.notifier).limpiarError();
    if (!hayInternet) {
      _mostrarSinInternet();
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Sacar a ${miembro.nombre}?'),
        content: Text(
          '${miembro.nombre} perderá acceso al hogar de inmediato. Sus movimientos anteriores se conservarán en el historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('btn_confirmar_dialogo_sacar'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, sacar del hogar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await ref.read(hogarControllerProvider.notifier).sacarMiembro(
            hogarId: hogarId,
            miembroUid: miembro.uid,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogar = ref.watch(hogarActualProvider).value;
    final miembros = ref.watch(miembrosHogarProvider).value ?? const [];
    final invitacionStream = ref.watch(invitacionActivaProvider).value;
    final invitacion = _invitacionReciente ?? invitacionStream;
    final hayInternet = ref.watch(tieneInternetProvider).value ?? true;
    final hogarState = ref.watch(hogarControllerProvider);
    final cargando = hogarState.isLoading;
    final ahora = ref.watch(clockProvider).now();
    final semaforo =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    final hogarId = usuario?.hogarId ?? hogar?.id ?? '';
    final esAdmin =
        usuario != null && hogar != null && hogar.adminUid == usuario.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(hogar?.nombre ?? 'Miembros del hogar'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (!hayInternet) ...[
              Container(
                key: const Key('banner_sin_internet_miembros'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: semaforo.preventivoFondo,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: semaforo.preventivo, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, color: semaforo.preventivo),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        kMensajeNecesitasInternet,
                        style: TextStyle(
                          color: semaforo.preventivo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (hogarState.hasError) ...[
              Container(
                key: const Key('banner_error_miembros_qr'),
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
            if (esAdmin) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Invitar a un familiar con código QR',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'El código QR dura 4 horas. Si generas uno nuevo, el anterior deja de funcionar.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      if (invitacion == null) ...[
                        FilledButton.icon(
                          key: const Key('btn_invitar_qr'),
                          onPressed: cargando || hogarId.isEmpty
                              ? null
                              : () => _generarQr(
                                    hogarId: hogarId,
                                    hayInternet: hayInternet,
                                  ),
                          icon: const Icon(Icons.qr_code_2_rounded),
                          label: const Text('Invitar'),
                        ),
                      ] else ...[
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QrImageView(
                              key: const Key('qr_image_view'),
                              data: invitacion.qrUrl,
                              size: 210,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tiempo restante: ${_formatearCuentaRegresiva(invitacion.tiempoRestante(ahora))}',
                          key: const Key('texto_cuenta_regresiva_qr'),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          invitacion.qrUrl,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          key: const Key('btn_generar_nuevo_qr'),
                          onPressed: cargando || hogarId.isEmpty
                              ? null
                              : () => _generarQr(
                                    hogarId: hogarId,
                                    hayInternet: hayInternet,
                                  ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Generar nuevo'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Miembros activos (${miembros.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            for (final miembro in miembros)
              Card(
                key: Key('item_miembro_${miembro.uid}'),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      miembro.rol == 'admin'
                          ? Icons.admin_panel_settings_rounded
                          : Icons.person_rounded,
                    ),
                  ),
                  title: Text(
                    miembro.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    miembro.rol == 'admin' ? 'Administrador' : 'Miembro',
                  ),
                  trailing: (esAdmin && miembro.uid != usuario.uid)
                      ? TextButton.icon(
                          key: Key('btn_sacar_${miembro.uid}'),
                          onPressed: cargando
                              ? null
                              : () => _confirmarSacarMiembro(
                                    hogarId: hogarId,
                                    miembro: miembro,
                                    hayInternet: hayInternet,
                                  ),
                          icon: Icon(
                            Icons.person_remove_outlined,
                            color: semaforo.rojo,
                          ),
                          label: Text(
                            'Sacar',
                            style: TextStyle(color: semaforo.rojo),
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
