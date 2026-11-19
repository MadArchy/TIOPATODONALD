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
