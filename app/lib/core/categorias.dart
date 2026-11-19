import 'package:material_ui/material_ui.dart';

/// Ids y metadatos de categorías (`docs/02_reglas_negocio.md` §3).
abstract final class CategoriasGasto {
  static const alimentacion = 'alimentacion';
  static const servicios = 'servicios';
  static const transporte = 'transporte';
  static const vivienda = 'vivienda';
  static const salud = 'salud';
  static const educacion = 'educacion';
  static const ocio = 'ocio';
  static const otros = 'otros';

  static const List<String> ids = <String>[
    alimentacion,
    servicios,
    transporte,
    vivienda,
    salud,
    educacion,
    ocio,
    otros,
  ];

  /// Ocio y Otros son reducibles (docs §2 / §3).
  static const Set<String> reducibles = <String>{ocio, otros};

  static bool esValida(String? id) => id != null && ids.contains(id);

  static bool esReducible(String id) => reducibles.contains(id);
}

abstract final class CategoriasIngreso {
  static const salario = 'salario';
  static const otrosIngreso = 'otros_ingreso';

  static const List<String> ids = <String>[salario, otrosIngreso];

  static bool esValida(String? id) => id != null && ids.contains(id);
}

/// Etiqueta corta en español de Colombia para mostrar en la UI.
String etiquetaCategoria(String id) {
  switch (id) {
    case CategoriasGasto.alimentacion:
      return 'Alimentación';
    case CategoriasGasto.servicios:
      return 'Servicios';
    case CategoriasGasto.transporte:
      return 'Transporte';
    case CategoriasGasto.vivienda:
      return 'Vivienda';
    case CategoriasGasto.salud:
      return 'Salud';
    case CategoriasGasto.educacion:
      return 'Educación';
    case CategoriasGasto.ocio:
      return 'Ocio / caprichos';
    case CategoriasGasto.otros:
      return 'Otros';
    case CategoriasIngreso.salario:
      return 'Salario';
    case CategoriasIngreso.otrosIngreso:
      return 'Otros';
    default:
      return id;
  }
}

/// Ícono Material asociado a la categoría.
IconData iconoCategoria(String id) {
  switch (id) {
    case CategoriasGasto.alimentacion:
      return Icons.restaurant_rounded;
    case CategoriasGasto.servicios:
      return Icons.bolt_rounded;
    case CategoriasGasto.transporte:
      return Icons.directions_bus_rounded;
    case CategoriasGasto.vivienda:
      return Icons.home_rounded;
    case CategoriasGasto.salud:
      return Icons.local_hospital_rounded;
    case CategoriasGasto.educacion:
      return Icons.school_rounded;
    case CategoriasGasto.ocio:
      return Icons.celebration_rounded;
    case CategoriasGasto.otros:
      return Icons.more_horiz_rounded;
    case CategoriasIngreso.salario:
      return Icons.payments_rounded;
    case CategoriasIngreso.otrosIngreso:
      return Icons.savings_rounded;
    default:
      return Icons.category_rounded;
  }
}

/// Valida que [categoria] corresponda al [tipo] (`gasto` / `ingreso` / `pagoCuota`).
bool categoriaValidaParaTipo(String tipo, String? categoria) {
  switch (tipo) {
    case 'gasto':
      return CategoriasGasto.esValida(categoria);
    case 'ingreso':
      return CategoriasIngreso.esValida(categoria);
    case 'pagoCuota':
      return categoria == null;
    default:
      return false;
  }
}
