# 08 — Operación

## Ambientes
- `pato-donald-dev`: desarrollo, conectado a emuladores locales la mayor parte del tiempo.
- `pato-donald-prod`: el que usa la familia. Solo se despliega desde la rama `main` después de `/cerrar-slice`.

## Acceso
- Firebase Console y Google Play Console: el desarrollador (entrevista §4.4).

## Reasignar el admin (solo si el admin perdió su correo)
1. Confirmar por fuera de la app (en persona) quién será el nuevo admin.
2. En Firestore de producción: cambiar `hogares/{h}.adminUid` al uid nuevo.
3. En `hogares/{h}/miembros/{uidNuevo}` poner `rol: admin`; en el anterior `rol: miembro`.
4. Agregar manualmente en `auditoria` una entrada `accion: reasignacionAdmin` con fecha y motivo.

## Respaldo
- Activar exportación programada de Firestore a Cloud Storage (semanal) en producción.

## Distribución del piloto
- Google Play, pista de **prueba interna** (hasta 100 testers por correo) o instalación directa del APK.

## Pasos de despliegue a producción (Slice 9)

### 1. Credenciales Firebase (`dev` y `prod`)
```bash
cd app
flutterfire configure --project=pato-donald-dev --out=lib/firebase_options_dev.dart --platforms=android --android-package-name=co.patodonald.app.dev --android-out=android/app/src/dev/google-services.json
flutterfire configure --project=pato-donald-prod --out=lib/firebase_options_prod.dart --platforms=android --android-package-name=co.patodonald.app --android-out=android/app/src/prod/google-services.json
```
*(El plugin `com.google.gms.google-services` se activa automáticamente en `app/android/app/build.gradle.kts` en cuanto existan los `google-services.json`.)*

### 2. Firma de release (una sola vez)
```bash
keytool -genkey -v -keystore app/android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias patodonald
```
Copiar `app/android/key.properties.example` a `app/android/key.properties` (ignorado por git) y completar las contraseñas.

### 3. Desplegar backend a `pato-donald-prod` (requiere plan Blaze)
```bash
cd functions && npm run lint && npm run build && npm test && cd ..
firebase deploy --project pato-donald-prod --only firestore:rules,firestore:indexes,storage,functions
```

### 4. Activar respaldo semanal de Firestore
En Google Cloud Console (o `gcloud`):
```bash
gcloud firestore backups schedules create --database="(default)" --recurrence=weekly --day-of-week=SUN --retention=4w --project=pato-donald-prod
```

### 5. Generar AAB para Google Play (prueba interna)
```bash
cd app
flutter build appbundle --flavor prod --release -t lib/main_prod.dart
```
Subir `app/build/app/outputs/bundle/prodRelease/app-prod-release.aab` a la pista de **prueba interna** en Google Play Console y agregar los correos de la familia.
