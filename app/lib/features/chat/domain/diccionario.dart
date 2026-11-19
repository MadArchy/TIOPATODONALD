import '../../../core/categorias.dart';

/// Diccionario palabra → categoría de gasto (`docs/05_ia.md` §Nivel 1).
const Map<String, String> kDiccionarioCategorias = <String, String>{
  // alimentación
  'mercado': CategoriasGasto.alimentacion,
  'almuerzo': CategoriasGasto.alimentacion,
  'desayuno': CategoriasGasto.alimentacion,
  'comida': CategoriasGasto.alimentacion,
  'cena': CategoriasGasto.alimentacion,
  'restaurante': CategoriasGasto.alimentacion,
  'tienda': CategoriasGasto.alimentacion,
  'supermercado': CategoriasGasto.alimentacion,
  'cafe': CategoriasGasto.alimentacion,
  'café': CategoriasGasto.alimentacion,
  'pan': CategoriasGasto.alimentacion,
  'arepa': CategoriasGasto.alimentacion,
  // transporte
  'uber': CategoriasGasto.transporte,
  'taxi': CategoriasGasto.transporte,
  'gasolina': CategoriasGasto.transporte,
  'bus': CategoriasGasto.transporte,
  'transmilenio': CategoriasGasto.transporte,
  'metro': CategoriasGasto.transporte,
  'peaje': CategoriasGasto.transporte,
  'parking': CategoriasGasto.transporte,
  'parqueadero': CategoriasGasto.transporte,
  // servicios
  'luz': CategoriasGasto.servicios,
  'agua': CategoriasGasto.servicios,
  'internet': CategoriasGasto.servicios,
  'celular': CategoriasGasto.servicios,
  'gas': CategoriasGasto.servicios,
  'telefono': CategoriasGasto.servicios,
  'teléfono': CategoriasGasto.servicios,
  // vivienda
  'arriendo': CategoriasGasto.vivienda,
  'administracion': CategoriasGasto.vivienda,
  'administración': CategoriasGasto.vivienda,
  'hipoteca': CategoriasGasto.vivienda,
  // salud
  'drogueria': CategoriasGasto.salud,
  'droguería': CategoriasGasto.salud,
  'farmacia': CategoriasGasto.salud,
  'medico': CategoriasGasto.salud,
  'médico': CategoriasGasto.salud,
  'cita': CategoriasGasto.salud,
  'medicina': CategoriasGasto.salud,
  // educación
  'colegio': CategoriasGasto.educacion,
  'curso': CategoriasGasto.educacion,
  'universidad': CategoriasGasto.educacion,
  'matricula': CategoriasGasto.educacion,
  'libros': CategoriasGasto.educacion,
  // ocio
  'cine': CategoriasGasto.ocio,
  'salida': CategoriasGasto.ocio,
  'ropa': CategoriasGasto.ocio,
  'netflix': CategoriasGasto.ocio,
  'juego': CategoriasGasto.ocio,
  'fiesta': CategoriasGasto.ocio,
  // ids / nombres de categoría (preguntas "cuánto en X")
  'alimentacion': CategoriasGasto.alimentacion,
  'transporte': CategoriasGasto.transporte,
  'servicios': CategoriasGasto.servicios,
  'vivienda': CategoriasGasto.vivienda,
  'salud': CategoriasGasto.salud,
  'educacion': CategoriasGasto.educacion,
  'ocio': CategoriasGasto.ocio,
  'caprichos': CategoriasGasto.ocio,
};

/// Normaliza texto para matching (minúsculas, sin tildes fuertes).
String normalizarChat(String texto) {
  var t = texto.toLowerCase().trim();
  const mapa = <String, String>{
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  mapa.forEach((k, v) => t = t.replaceAll(k, v));
  return t;
}

/// Primera categoría cuyo término aparece en [textoNormalizado], o `otros`.
String categoriaDesdeTexto(String textoNormalizado) {
  return categoriaMatchDesdeTexto(textoNormalizado) ?? CategoriasGasto.otros;
}

/// Categoría si hubo match de diccionario; `null` si no.
String? categoriaMatchDesdeTexto(String textoNormalizado) {
  // Preferir términos más largos (ej. "supermercado" antes que "mercado").
  final ordenados = kDiccionarioCategorias.entries.toList()
    ..sort((a, b) => b.key.length.compareTo(a.key.length));
  for (final e in ordenados) {
    final clave = normalizarChat(e.key);
    if (clave.isNotEmpty && textoNormalizado.contains(clave)) {
      return e.value;
    }
  }
  return null;
}
