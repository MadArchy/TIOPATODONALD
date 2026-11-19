import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/conectividad.dart';
import '../application/hogar_controller.dart';

/// Pantalla que recibe el deep link `patodonald://unirse?h=..&c=..`
/// y une al usuario autenticado al hogar.
class UnirseDeepLinkScreen extends ConsumerStatefulWidget {
  const UnirseDeepLinkScreen({
    super.key,
    required this.hogarId,
    required this.codigo,
  });

  final String hogarId;
  final String codigo;

  @override
  ConsumerState<UnirseDeepLinkScreen> createState() =>
      _UnirseDeepLinkScreenState();
}

class _UnirseDeepLinkScreenState extends ConsumerState<UnirseDeepLinkScreen> {
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      _iniciado = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _unirse());
    }
  }

  Future<void> _unirse() async {
    final hayInternet = ref.read(tieneInternetProvider).value ?? true;
    if (!hayInternet) {
      return;
    }

    final exito = await ref
        .read(hogarControllerProvider.notifier)
        .unirseConCodigo(
          hogarId: widget.hogarId,
          codigo: widget.codigo,
        );

    if (exito && mounted) {
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
        title: const Text('Unirse al hogar'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!hayInternet) ...[
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 56,
                    color: semaforo.preventivo,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    kMensajeNecesitasInternet,
                    style: TextStyle(
                      color: semaforo.preventivo,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (hogarState.isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Uniéndote al hogar...'),
                ] else if (hogarState.hasError) ...[
                  Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: semaforo.rojo,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hogarState.error.toString(),
                    style: TextStyle(
                      color: semaforo.rojo,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/sin-hogar'),
                    child: const Text('Volver'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
