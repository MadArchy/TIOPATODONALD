import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reloj inyectable para evitar llamar `DateTime.now()` directamente en la UI
/// o en la lógica de negocio (.agents/rules/flutter.md).
abstract class Clock {
  const Clock();

  DateTime now();
}

/// Implementación real que usa el reloj del sistema.
class SystemClock extends Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Implementación fija para pruebas unitarias y de widgets.
class FixedClock extends Clock {
  const FixedClock(this._fixedNow);

  final DateTime _fixedNow;

  @override
  DateTime now() => _fixedNow;
}

/// Provider global del reloj; puede sobreescribirse en tests con `FixedClock`.
final clockProvider = Provider<Clock>((ref) => const SystemClock());
