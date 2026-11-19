import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../config/app_flavor.dart';
import '../config/firebase_init.dart';
import '../theme/app_theme.dart';
import '../utils/dinero.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'inicio',
        builder: (context, state) => const HolaPatoDonaldScreen(),
      ),
    ],
  );
});

/// Pantalla base del Slice 0 ("Hola, PATO DONALD").
class HolaPatoDonaldScreen extends ConsumerWidget {
  const HolaPatoDonaldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(appFlavorProvider);
    final semaforo =
        Theme.of(context).extension<SemaforoColors>() ?? SemaforoColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PATO DONALD'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hola, PATO DONALD',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Finanzas claras para nuestro hogar',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: semaforo.verdeFondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: semaforo.verde, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: semaforo.verde,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'En verde · Ejemplo: ${formatCop(85000)}',
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
                Text(
                  'Ambiente: ${flavor.etiqueta} (${flavor.nombreProyectoFirebase})'
                  '${kUseEmulators ? ' · Emuladores activos' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
