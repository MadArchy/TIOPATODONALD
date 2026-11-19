import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options_dev.dart';
import '../../firebase_options_prod.dart';
import 'app_flavor.dart';

/// Región única de Cloud Functions (coincide con functions/src/index.ts).
const String kFirebaseRegion = 'us-central1';

/// Flag compilada por --dart-define=USE_EMULATORS=true
const bool kUseEmulators = bool.fromEnvironment(
  'USE_EMULATORS',
  defaultValue: false,
);

/// Host de los emuladores.
/// - Chrome / web / teléfono con `adb reverse`: `127.0.0.1`
/// - Emulador Android (AVD): `10.0.2.2`
const String _kEmulatorHostDefine = String.fromEnvironment(
  'EMULATOR_HOST',
  defaultValue: '',
);

String get kEmulatorHost {
  if (_kEmulatorHostDefine.isNotEmpty) {
    return _kEmulatorHostDefine;
  }
  if (kIsWeb) {
    return '127.0.0.1';
  }
  return '10.0.2.2';
}

/// Inicializa Firebase para el [flavor] indicado, activa la persistencia offline
/// de Firestore y, si estamos en `dev` con `USE_EMULATORS=true`, apunta Auth,
/// Firestore, Storage y Functions a los emuladores locales.
Future<void> inicializarFirebase(AppFlavor flavor) async {
  final options = switch (flavor) {
    AppFlavor.dev => DefaultFirebaseOptionsDev.currentPlatform,
    AppFlavor.prod => DefaultFirebaseOptionsProd.currentPlatform,
  };

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: options);
  }

  final firestore = FirebaseFirestore.instance;

  if (flavor == AppFlavor.dev && kUseEmulators) {
    debugPrint(
      'Conectando PATO DONALD (DEV) a emuladores en $kEmulatorHost...',
    );
    await FirebaseAuth.instance.useAuthEmulator(kEmulatorHost, 9099);
    firestore.useFirestoreEmulator(kEmulatorHost, 8080);
    await FirebaseStorage.instance.useStorageEmulator(kEmulatorHost, 9199);
    FirebaseFunctions.instanceFor(region: kFirebaseRegion)
        .useFunctionsEmulator(kEmulatorHost, 5001);
  }

  // Persistencia offline (AGENTS.md y docs/02_reglas_negocio.md §10).
  // En web el preview local no fuerza cache ilimitado (API distinta).
  if (!kIsWeb) {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
