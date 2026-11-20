// Archivo base para el flavor PROD (pato-donald-prod).
// Reemplázalo con las credenciales reales ejecutando:
// flutterfire configure --project=pato-donald-prod --out=lib/firebase_options_prod.dart --platforms=android --android-package-name=co.patodonald.app --android-out=android/app/src/prod/google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptionsProd {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsProd solo soporta Android y Web.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDceGqnWapAirbgZtLus-Y6tK5Tz3ggVAo',
    appId: '1:497215713486:android:ad0040400ee1f5e1e3609f',
    messagingSenderId: '497215713486',
    projectId: 'pato-donald-prod',
    storageBucket: 'pato-donald-prod.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAM__RRGONAzxlMFZ0v047fcyUBIjkIx98',
    appId: '1:497215713486:web:5614fba382e33167e3609f',
    messagingSenderId: '497215713486',
    projectId: 'pato-donald-prod',
    storageBucket: 'pato-donald-prod.firebasestorage.app',
    authDomain: 'pato-donald-prod.firebaseapp.com',
  );
}
