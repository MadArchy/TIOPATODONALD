import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mensaje estándar cuando el usuario intenta una operación de servidor sin red
/// (`docs/02_reglas_negocio.md` §10 y `prompts/slice-02-hogar-qr.md`).
const String kMensajeNecesitasInternet = 'Necesitas internet para esto';

/// Servicio inyectable para verificar conectividad a internet.
abstract class ConectividadService {
  Future<bool> tieneInternet();
  Stream<bool> observarConectividad();
}

class ConnectivityPlusService implements ConectividadService {
  ConnectivityPlusService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _hayRed(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<bool> tieneInternet() async {
    final res = await _connectivity.checkConnectivity();
    return _hayRed(res);
  }

  @override
  Stream<bool> observarConectividad() async* {
    final inicial = await tieneInternet();
    yield inicial;
    yield* _connectivity.onConnectivityChanged.map(_hayRed);
  }
}

final conectividadServiceProvider = Provider<ConectividadService>((ref) {
  return ConnectivityPlusService();
});

final tieneInternetProvider = StreamProvider<bool>((ref) {
  return ref.watch(conectividadServiceProvider).observarConectividad();
});
