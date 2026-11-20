// Archivo base para el flavor DEV (pato-donald-dev).
// Reemplázalo con las credenciales reales ejecutando:
// flutterfire configure --project=pato-donald-dev --out=lib/firebase_options_dev.dart --platforms=android --android-package-name=co.patodonald.app.dev --android-out=android/app/src/dev/google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptionsDev {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Vista local en Chrome (preview). El MVP sigue siendo Android.
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsDev solo soporta Android en el MVP.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDMVep1GzGLNKCL4humMU1D9Imbbld7s-c',
    appId: '1:543147200322:android:0c18bd99a5d40ce66682db',
    messagingSenderId: '543147200322',
    projectId: 'pato-donald-dev',
    storageBucket: 'pato-donald-dev.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-api-key-pato-donald-dev',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'pato-donald-dev',
    storageBucket: 'pato-donald-dev.firebasestorage.app',
    authDomain: 'pato-donald-dev.firebaseapp.com',
  );
}
