import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/auth_failures.dart';
import '../../../core/theme/app_theme.dart';
import '../application/auth_controller.dart';

class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    ref.read(authControllerProvider.notifier).limpiarError();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await ref.read(authControllerProvider.notifier).registrar(
          nombre: _nombreController.text,
          email: _correoController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final cargando = authState.isLoading;
    final semaforo =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear mi cuenta'),
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
                      'Tus datos para empezar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Con tu cuenta podrás anotar tus gastos y ver tu presupuesto.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (authState.hasError) ...[
                      Container(
                        key: const Key('banner_error_registro'),
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
                      key: const Key('input_registro_nombre'),
                      controller: _nombreController,
                      enabled: !cargando,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Tu nombre',
                        hintText: 'Ejemplo: Mamá, Carlos, Ana',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: AuthValidators.validarNombre,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('input_registro_correo'),
                      controller: _correoController,
                      enabled: !cargando,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'nombre@correo.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: AuthValidators.validarCorreo,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('input_registro_password'),
                      controller: _passwordController,
                      enabled: !cargando,
                      obscureText: _ocultarPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _enviar(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña (mínimo 8 caracteres)',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _ocultarPassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: () {
                            setState(() {
                              _ocultarPassword = !_ocultarPassword;
                            });
                          },
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: AuthValidators.validarPassword,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('btn_submit_registro'),
                      onPressed: cargando ? null : _enviar,
                      child: cargando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Text('Crear cuenta'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: cargando ? null : () => context.go('/login'),
                      child: const Text('¿Ya tienes cuenta? Entrar'),
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
