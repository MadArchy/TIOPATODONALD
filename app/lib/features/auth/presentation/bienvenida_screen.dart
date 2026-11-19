import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Pantalla de Bienvenida (sin sesión).
/// Lleva al usuario a Crear cuenta o a Entrar con su cuenta existente.
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
                    Icons.account_balance_wallet_rounded,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'PATO DONALD',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las cuentas claras de nuestra familia en un solo lugar.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  FilledButton.icon(
                    key: const Key('btn_ir_a_registro'),
                    onPressed: () => context.push('/registro'),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Crear mi cuenta'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const Key('btn_ir_a_login'),
                    onPressed: () => context.push('/login'),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Ya tengo cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
