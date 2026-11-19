import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor {
  dev,
  prod;

  String get nombreProyectoFirebase => switch (this) {
        AppFlavor.dev => 'pato-donald-dev',
        AppFlavor.prod => 'pato-donald-prod',
      };

  String get etiqueta => switch (this) {
        AppFlavor.dev => 'DEV',
        AppFlavor.prod => 'PROD',
      };
}

/// Provider con el flavor activo de la aplicación (por defecto dev).
final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavor.dev);
