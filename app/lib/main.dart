import 'app.dart';
import 'core/config/app_flavor.dart';

/// Punto de entrada por defecto (usa flavor DEV).
Future<void> main() async {
  await bootstrapApp(AppFlavor.dev);
}
