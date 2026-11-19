import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/utils/conectividad.dart';

/// Entrada pendiente de subida a Storage (`recibos/{hogarId}/{movimientoId}.jpg`).
class FotoPendiente {
  const FotoPendiente({
    required this.hogarId,
    required this.movimientoId,
    required this.rutaLocal,
  });

  final String hogarId;
  final String movimientoId;
  final String rutaLocal;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'hogarId': hogarId,
        'movimientoId': movimientoId,
        'rutaLocal': rutaLocal,
      };

  factory FotoPendiente.fromJson(Map<String, dynamic> json) {
    return FotoPendiente(
      hogarId: json['hogarId'] as String,
      movimientoId: json['movimientoId'] as String,
      rutaLocal: json['rutaLocal'] as String,
    );
  }

  String get storagePath => 'recibos/$hogarId/$movimientoId.jpg';
}

/// Cola en disco para fotos de recibo cuando no hay red.
class ColaFotosService {
  ColaFotosService({
    required this.conectividad,
    FirebaseStorage? storage,
    Future<Directory> Function()? obtenerDirectorio,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _obtenerDirectorio =
            obtenerDirectorio ?? getApplicationDocumentsDirectory;

  final ConectividadService conectividad;
  final FirebaseStorage _storage;
  final Future<Directory> Function() _obtenerDirectorio;

  bool _procesando = false;

  Future<File> _archivoCola() async {
    final dir = await _obtenerDirectorio();
    return File(p.join(dir.path, 'cola_fotos_recibos.json'));
  }

  Future<Directory> _dirFotosPendientes() async {
    final dir = await _obtenerDirectorio();
    final fotos = Directory(p.join(dir.path, 'fotos_pendientes'));
    if (!await fotos.exists()) {
      await fotos.create(recursive: true);
    }
    return fotos;
  }

  Future<List<FotoPendiente>> listarPendientes() async {
    final archivo = await _archivoCola();
    if (!await archivo.exists()) return const <FotoPendiente>[];
    try {
      final raw = await archivo.readAsString();
      if (raw.trim().isEmpty) return const <FotoPendiente>[];
      final lista = jsonDecode(raw) as List<dynamic>;
      return lista
          .map((e) => FotoPendiente.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const <FotoPendiente>[];
    }
  }

  Future<void> _guardarCola(List<FotoPendiente> pendientes) async {
    final archivo = await _archivoCola();
    await archivo.writeAsString(
      jsonEncode(pendientes.map((e) => e.toJson()).toList()),
    );
  }

  /// Copia el archivo comprimido a disco local y lo encola.
  Future<FotoPendiente> encolar({
    required String hogarId,
    required String movimientoId,
    required File archivoComprimido,
  }) async {
    final dir = await _dirFotosPendientes();
    final destino = File(p.join(dir.path, '$movimientoId.jpg'));
    await archivoComprimido.copy(destino.path);

    final pendiente = FotoPendiente(
      hogarId: hogarId,
      movimientoId: movimientoId,
      rutaLocal: destino.path,
    );
    final cola = await listarPendientes();
    cola.removeWhere((e) => e.movimientoId == movimientoId);
    cola.add(pendiente);
    await _guardarCola(cola);
    return pendiente;
  }

  /// Sube un recibo ya comprimido. Si no hay red, lo encola.
  /// Devuelve la ruta Storage si subió; `null` si quedó en cola.
  Future<String?> subirOEncolar({
    required String hogarId,
    required String movimientoId,
    required File archivoComprimido,
  }) async {
    final hayRed = await conectividad.tieneInternet();
    if (!hayRed) {
      await encolar(
        hogarId: hogarId,
        movimientoId: movimientoId,
        archivoComprimido: archivoComprimido,
      );
      return null;
    }

    try {
      return await _subirArchivo(
        hogarId: hogarId,
        movimientoId: movimientoId,
        archivo: archivoComprimido,
      );
    } catch (_) {
      await encolar(
        hogarId: hogarId,
        movimientoId: movimientoId,
        archivoComprimido: archivoComprimido,
      );
      return null;
    }
  }

  Future<String> _subirArchivo({
    required String hogarId,
    required String movimientoId,
    required File archivo,
  }) async {
    final path = 'recibos/$hogarId/$movimientoId.jpg';
    final ref = _storage.ref(path);
    await ref.putFile(
      archivo,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return path;
  }

  /// Intenta subir todo lo pendiente. Devuelve las rutas Storage subidas
  /// (para que el repositorio actualice `fotoPath` en Firestore).
  Future<List<FotoPendiente>> procesarPendientes() async {
    if (_procesando) return const <FotoPendiente>[];
    final hayRed = await conectividad.tieneInternet();
    if (!hayRed) return const <FotoPendiente>[];

    _procesando = true;
    final subidas = <FotoPendiente>[];
    try {
      final cola = await listarPendientes();
      final restantes = <FotoPendiente>[];
      for (final item in cola) {
        final archivo = File(item.rutaLocal);
        if (!await archivo.exists()) {
          continue;
        }
        try {
          await _subirArchivo(
            hogarId: item.hogarId,
            movimientoId: item.movimientoId,
            archivo: archivo,
          );
          subidas.add(item);
          try {
            await archivo.delete();
          } catch (_) {}
        } catch (_) {
          restantes.add(item);
        }
      }
      await _guardarCola(restantes);
    } finally {
      _procesando = false;
    }
    return subidas;
  }
}

final colaFotosServiceProvider = Provider<ColaFotosService>((ref) {
  final conectividad = ref.watch(conectividadServiceProvider);
  final service = ColaFotosService(conectividad: conectividad);

  // Reintentar al reconectar.
  ref.listen<AsyncValue<bool>>(tieneInternetProvider, (prev, next) {
    final online = next.value ?? false;
    final estabaOffline = prev?.value == false;
    if (online && (estabaOffline || prev == null)) {
      // ignore: discarded_futures
      service.procesarPendientes();
    }
  });

  return service;
});
