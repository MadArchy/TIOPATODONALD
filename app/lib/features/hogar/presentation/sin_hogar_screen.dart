import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/conectividad.dart';
import '../../../data/repositories/auth_repository.dart';
import '../application/hogar_controller.dart';

/// Pantalla "Crea o únete a un hogar" (`prompts/slice-02-hogar-qr.md`).
/// - Botón [Crear hogar] (pide el nombre del hogar).
/// - Botón [Escanear QR] (abre cámara `mobile_scanner` o permite ingresar enlace).
/// - Si no hay internet, muestra "Necesitas internet para esto".
class SinHogarScreen extends ConsumerStatefulWidget {
  const SinHogarScreen({super.key});

  @override
  ConsumerState<SinHogarScreen> createState() => _SinHogarScreenState();
}

class _SinHogarScreenState extends ConsumerState<SinHogarScreen> {
  final _nombreHogarController = TextEditingController();
  bool _mostrandoFormularioCrear = false;

  @override
  void dispose() {
    _nombreHogarController.dispose();
    super.dispose();
  }

  void _mostrarAvisoSinInternet() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(kMensajeNecesitasInternet),
        ),
      );
  }

  Future<void> _intentarAbrirCrearHogar(bool hayInternet) async {
    ref.read(hogarControllerProvider.notifier).limpiarError();
    if (!hayInternet) {
      _mostrarAvisoSinInternet();
      return;
    }
    setState(() {
      _mostrandoFormularioCrear = true;
    });
  }

  Future<void> _intentarEscanearQr(bool hayInternet) async {
    ref.read(hogarControllerProvider.notifier).limpiarError();
    if (!hayInternet) {
      _mostrarAvisoSinInternet();
      return;
    }
    if (!mounted) return;
    await context.push('/escanear-qr');
  }

  Future<void> _crearHogar(bool hayInternet) async {
    if (!hayInternet) {
      _mostrarAvisoSinInternet();
      return;
    }
    final hogarId = await ref
        .read(hogarControllerProvider.notifier)
        .crearHogar(nombre: _nombreHogarController.text);

    if (hogarId != null && mounted) {
      context.go('/configurar-periodo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogarState = ref.watch(hogarControllerProvider);
    final tieneInternetAsync = ref.watch(tieneInternetProvider);
    final hayInternet = tieneInternetAsync.value ?? true;
    final cargando = hogarState.isLoading;
    final semaforo =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu hogar'),
        actions: [
          IconButton(
            key: const Key('btn_ir_a_perfil_desde_sin_hogar'),
            tooltip: 'Mi perfil',
            onPressed: () => context.push('/perfil'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    usuario != null
                        ? 'Hola, ${usuario.nombre}'
                        : 'Bienvenido',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea o únete a un hogar',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Crea el hogar de tu familia si eres quien lo va a administrar, o escanea el código QR si alguien más ya lo creó.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (!hayInternet) ...[
                    Container(
                      key: const Key('banner_sin_internet_hogar'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: semaforo.preventivoFondo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: semaforo.preventivo,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: semaforo.preventivo,
                          ),
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
                      key: const Key('banner_error_sin_hogar'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: semaforo.rojoFondo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: semaforo.rojo, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: semaforo.rojo,
                          ),
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
                  if (!_mostrandoFormularioCrear) ...[
                    FilledButton.icon(
                      key: const Key('btn_abrir_crear_hogar'),
                      onPressed: cargando
                          ? null
                          : () => _intentarAbrirCrearHogar(hayInternet),
                      icon: const Icon(Icons.add_home_rounded),
                      label: const Text('Crear hogar'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      key: const Key('btn_ir_escanear_qr'),
                      onPressed: cargando
                          ? null
                          : () => _intentarEscanearQr(hayInternet),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Escanear QR'),
                    ),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Nombre de tu hogar',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              key: const Key('input_nombre_hogar'),
                              controller: _nombreHogarController,
                              enabled: !cargando,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del hogar',
                                hintText: 'Ejemplo: Familia Pato, Nuestro Hogar',
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                              onSubmitted: (_) => _crearHogar(hayInternet),
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              key: const Key('btn_confirmar_crear_hogar'),
                              onPressed: cargando
                                  ? null
                                  : () => _crearHogar(hayInternet),
                              child: cargando
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text('Crear mi hogar'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: cargando
                                  ? null
                                  : () {
                                      setState(() {
                                        _mostrandoFormularioCrear = false;
                                      });
                                    },
                              child: const Text('Cancelar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
