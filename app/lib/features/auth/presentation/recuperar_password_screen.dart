import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/auth_failures.dart';
import '../../../core/theme/app_theme.dart';
import '../application/auth_controller.dart';

class RecuperarPasswordScreen extends ConsumerStatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  ConsumerState<RecuperarPasswordScreen> createState() =>
      _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState
    extends ConsumerState<RecuperarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  bool _correoEnviado = false;

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _enviarCorreo() async {
    ref.read(authControllerProvider.notifier).limpiarError();
    setState(() {
      _correoEnviado = false;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final exito = await ref
        .read(authControllerProvider.notifier)
        .enviarCorreoRecuperacion(email: _correoController.text);

    if (exito && mounted) {
      setState(() {
        _correoEnviado = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final cargando = authState.isLoading;
    final semaforo =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
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
                      '¿Olvidaste tu contraseña?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Escribe tu correo y te enviaremos un enlace para que elijas una nueva contraseña.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (_correoEnviado) ...[
                      Container(
                        key: const Key('banner_exito_recuperar'),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: semaforo.verdeFondo,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: semaforo.verde, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: semaforo.verde),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Te enviamos el correo de recuperación. Revisa tu bandeja de entrada o correo no deseado.',
                                style: TextStyle(
                                  color: semaforo.verde,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (authState.hasError) ...[
                      Container(
                        key: const Key('banner_error_recuperar'),
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
                                authState.error.toString(),
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
                    TextFormField(
                      key: const Key('input_recuperar_correo'),
                      controller: _correoController,
                      enabled: !cargando,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _enviarCorreo(),
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'nombre@correo.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: AuthValidators.validarCorreo,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('btn_submit_recuperar'),
                      onPressed: cargando ? null : _enviarCorreo,
                      child: cargando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Text('Enviar enlace a mi correo'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: cargando ? null : () => context.pop(),
                      child: const Text('Volver a entrar'),
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
