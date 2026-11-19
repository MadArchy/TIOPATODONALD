import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/conectividad.dart';
import '../application/hogar_controller.dart';

/// Pantalla para escanear el código QR del hogar con la cámara (`mobile_scanner`)
/// o pegar el enlace `patodonald://unirse?h=..&c=..`.
class EscanearQrScreen extends ConsumerStatefulWidget {
  const EscanearQrScreen({
    super.key,
    this.habilitarCamara = true,
  });

  /// Permite desactivar el widget nativo de cámara en widget tests.
  final bool habilitarCamara;

  @override
  ConsumerState<EscanearQrScreen> createState() => _EscanearQrScreenState();
}

class _EscanearQrScreenState extends ConsumerState<EscanearQrScreen> {
  final _codigoManualController = TextEditingController();
  bool _procesandoLectura = false;

  @override
  void dispose() {
    _codigoManualController.dispose();
    super.dispose();
  }

  Future<void> _procesarQrRaw(String raw) async {
    if (_procesandoLectura) return;
    final hayInternet = ref.read(tieneInternetProvider).value ?? true;
    if (!hayInternet) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(kMensajeNecesitasInternet)),
        );
      return;
    }

    setState(() {
      _procesandoLectura = true;
    });

    final exito = await ref
        .read(hogarControllerProvider.notifier)
        .unirseDesdeQrRaw(raw);

    if (!mounted) return;
    setState(() {
      _procesandoLectura = false;
    });

    if (exito) {
      context.go('/configurar-periodo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hogarState = ref.watch(hogarControllerProvider);
    final hayInternet = ref.watch(tieneInternetProvider).value ?? true;
    final semaforo =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR del hogar'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Apunta la cámara al código QR que muestra el administrador en su teléfono.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!hayInternet) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: semaforo.preventivoFondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: semaforo.preventivo, width: 1.5),
                  ),
                  child: Text(
                    kMensajeNecesitasInternet,
                    style: TextStyle(
                      color: semaforo.preventivo,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (hogarState.hasError) ...[
                Container(
                  key: const Key('banner_error_escanear_qr'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: semaforo.rojoFondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: semaforo.rojo, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: semaforo.rojo),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          hogarState.error.toString(),
                          style: TextStyle(
                            color: semaforo.rojo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                height: 280,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.habilitarCamara
                      ? MobileScanner(
                          onDetect: (capture) {
                            for (final barcode in capture.barcodes) {
                              final raw = barcode.rawValue;
                              if (raw != null && raw.isNotEmpty) {
                                _procesarQrRaw(raw);
                                break;
                              }
                            }
                          },
                        )
                      : Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Text('Vista previa de cámara QR'),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¿No puedes usar la cámara? Pega aquí el enlace de invitación:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('input_qr_manual'),
                controller: _codigoManualController,
                enabled: !hogarState.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Enlace del QR',
                  hintText: 'patodonald://unirse?h=...&c=...',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('btn_unirse_con_enlace'),
                onPressed: hogarState.isLoading
                    ? null
                    : () => _procesarQrRaw(_codigoManualController.text),
                icon: const Icon(Icons.group_add_rounded),
                label: const Text('Unirme al hogar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
