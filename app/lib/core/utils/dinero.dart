import 'package:flutter/services.dart';

/// Utilidades de dinero para pesos colombianos (COP).
///
/// Reglas de negocio (AGENTS.md y .agents/rules/flutter.md):
/// - Montos siempre como enteros (`int`), nunca `double`.
/// - Formato único: `formatCop(85000) == '$85.000'`, `formatCop(1200000) == '$1.200.000'`.

/// Formatea un monto entero COP con separador de miles (`.`) sin signo `$`.
/// Ejemplo: `85000` → `'85.000'`, `1200000` → `'1.200.000'`.
String formatCopSinSimbolo(int monto) {
  final esNegativo = monto < 0;
  final digitos = monto.abs().toString();
  final formateado = _agregarPuntosMiles(digitos);
  return '${esNegativo ? '-' : ''}$formateado';
}

String _agregarPuntosMiles(String digitos) {
  final buffer = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digitos[i]);
  }
  return buffer.toString();
}

String formatCop(int monto) {
  final esNegativo = monto < 0;
  final formateado = formatCopSinSimbolo(monto.abs());
  return '${esNegativo ? '-' : ''}\$$formateado';
}

/// Convierte un texto ingresado por el usuario ("85000", "85.000", "85,000", "$85.000")
/// en un entero COP válido, o `null` si no contiene un entero válido.
int? parseCopInput(String texto) {
  final limpio = texto.replaceAll(RegExp(r'[\$\.,\s]'), '').trim();
  if (limpio.isEmpty) {
    return null;
  }
  return int.tryParse(limpio);
}

/// Formatea montos en COP en vivo mientras el usuario escribe, insertando
/// puntos de miles (`.`) para distinguir decenas, centenas, miles y millones:
/// `50` → `50`, `500` → `500`, `5000` → `5.000`, `1250000` → `1.250.000`.
class CopInputFormatter extends TextInputFormatter {
  const CopInputFormatter({this.maxDigitos = 12});

  final int maxDigitos;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final textoNuevo = newValue.text;
    final cursorNuevo = newValue.selection.end.clamp(0, textoNuevo.length);

    // Contar cuántos dígitos hay antes del cursor en el texto nuevo.
    var digitosAntesCursor = 0;
    for (var i = 0; i < cursorNuevo; i++) {
      final code = textoNuevo.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        digitosAntesCursor++;
      }
    }

    var soloDigitos = textoNuevo.replaceAll(RegExp(r'[^0-9]'), '');
    if (soloDigitos.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Quitar ceros a la izquierda innecesarios (ej. "0500" → "500"),
    // dejando un solo "0" si todos son ceros.
    var cerosQuitados = 0;
    while (soloDigitos.length > 1 && soloDigitos.startsWith('0')) {
      soloDigitos = soloDigitos.substring(1);
      cerosQuitados++;
    }
    digitosAntesCursor =
        (digitosAntesCursor - cerosQuitados).clamp(0, soloDigitos.length);

    // Limitar longitud máxima de dígitos para evitar overflow.
    if (soloDigitos.length > maxDigitos) {
      soloDigitos = soloDigitos.substring(0, maxDigitos);
      digitosAntesCursor = digitosAntesCursor.clamp(0, soloDigitos.length);
    }

    final formateado = _agregarPuntosMiles(soloDigitos);

    // Calcular la posición exacta del cursor en el texto formateado.
    var offset = 0;
    var vistos = 0;
    while (offset < formateado.length && vistos < digitosAntesCursor) {
      final code = formateado.codeUnitAt(offset);
      if (code >= 48 && code <= 57) {
        vistos++;
      }
      offset++;
    }

    return TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
