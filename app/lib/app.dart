import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/config/app_flavor.dart';
import 'core/config/firebase_init.dart';
import 'core/notifications/fcm_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Arranca la aplicación en el [flavor] indicado.
Future<void> bootstrapApp(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await inicializarFirebase(flavor);
  } catch (e, st) {
    debugPrint('Aviso al inicializar Firebase ($flavor): $e\n$st');
  }

  runApp(
    ProviderScope(
      overrides: [
        appFlavorProvider.overrideWithValue(flavor),
      ],
      child: const PatoDonaldApp(),
    ),
  );
}

class PatoDonaldApp extends ConsumerWidget {
  const PatoDonaldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(fcmBootstrapProvider);
    final router = ref.watch(appRouterProvider);
    final flavor = ref.watch(appFlavorProvider);

    return MaterialApp.router(
      title: 'PATO DONALD',
      debugShowCheckedModeBanner: flavor == AppFlavor.dev,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
