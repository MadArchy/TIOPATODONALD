/// Utilidades de dinero para pesos colombianos (COP).
///
/// Reglas de negocio (AGENTS.md y .agents/rules/flutter.md):
/// - Montos siempre como enteros (`int`), nunca `double`.
/// - Formato único: `formatCop(85000) == '$85.000'`, `formatCop(1200000) == '$1.200.000'`.
String formatCop(int monto) {
  final esNegativo = monto < 0;
  final digitos = monto.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digitos[i]);
  }

  return '${esNegativo ? '-' : ''}\$${buffer.toString()}';
}

/// Convierte un texto ingresado por el usuario ("85000", "85.000", "$85.000")
/// en un entero COP válido, o `null` si no contiene un entero válido.
int? parseCopInput(String texto) {
  final limpio = texto.replaceAll(RegExp(r'[\$\.\s]'), '').trim();
  if (limpio.isEmpty) {
    return null;
  }
  return int.tryParse(limpio);
}
