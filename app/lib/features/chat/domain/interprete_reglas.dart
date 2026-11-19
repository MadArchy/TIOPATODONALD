import '../../../core/categorias.dart';
import '../../../core/periodo.dart';
import 'diccionario.dart';
import 'intencion.dart';
import 'interprete.dart';

/// Interpreta montos en lenguaje natural colombiano (`docs/05_ia.md`).
/// Ejemplos: "85 mil", "85.000", "85000", "1,2 millones", "1.2 M", "un millón".
int? parseMontoChat(String texto) {
  final n = normalizarChat(texto);

  if (RegExp(r'\bun\s+millon\b').hasMatch(n)) {
    return 1000000;
  }

  // 1,2 millones / 1.2 millones / 2 millones
  final millones = RegExp(
    r'(\d+[.,]?\d*)\s*(millones|millon|m)\b',
  ).firstMatch(n);
  if (millones != null) {
    final raw = millones.group(1)!.replaceAll(',', '.');
    final v = double.tryParse(raw);
    if (v != null) return (v * 1000000).round();
  }

  // 85 mil / 85.5 mil
  final mil = RegExp(r'(\d+[.,]?\d*)\s*mil\b').firstMatch(n);
  if (mil != null) {
    final raw = mil.group(1)!.replaceAll(',', '.');
    final v = double.tryParse(raw);
    if (v != null) return (v * 1000).round();
  }

  // $85.000 o 85000 (toma el número más “grande” plausible)
  final conPuntos = RegExp(r'\$?\s*(\d{1,3}(?:\.\d{3})+)\b').firstMatch(texto);
  if (conPuntos != null) {
    return int.tryParse(conPuntos.group(1)!.replaceAll('.', ''));
  }

  final plano = RegExp(r'\$?\s*(\d{4,})\b').firstMatch(n);
  if (plano != null) {
    return int.tryParse(plano.group(1)!);
  }

  // Último recurso: número suelto de 2–3 dígitos solo si dice "mil" cerca — ya cubierto.
  return null;
}

String _fechaId(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime _calendario(DateTime d) => DateTime(d.year, d.month, d.day);

/// Nivel 1: intérprete por reglas en el teléfono (offline).
class InterpreteReglas implements Interprete {
  const InterpreteReglas();

  @override
  Future<Intencion> interpretar(String texto, ContextoUsuario ctx) async {
    final original = texto.trim();
    if (original.isEmpty) {
      return Intencion(
        accion: AccionesIntencion.noEntendido,
        textoOriginal: original,
        confianza: 0,
      );
    }

    final n = normalizarChat(original);
    final hoy = aHoraBogota(ctx.ahora);
    final hoyCal = _calendario(hoy);

    // —— Preguntas fijas ——
    if (_esComoVoy(n) || _esCuantoMeQueda(n)) {
      return const Intencion(
        accion: AccionesIntencion.consultarEstado,
        confianza: 0.95,
      );
    }

    final catPregunta = _categoriaEnPregunta(n);
    if (catPregunta != null) {
      return Intencion(
        accion: AccionesIntencion.consultarCategoria,
        categoria: catPregunta,
        confianza: 0.9,
      );
    }

    final deudaPregunta = _deudaEnTexto(n, ctx.deudas);
    if (deudaPregunta != null &&
        (n.contains('cuanto debo') ||
            n.contains('cuanto me queda de') ||
            n.contains('saldo') ||
            n.contains('cuando pago') ||
            n.contains('cuanto de la'))) {
      return Intencion(
        accion: AccionesIntencion.consultarDeuda,
        deudaId: deudaPregunta.id,
        confianza: 0.9,
      );
    }

    // —— Pago de cuota ——
    final esCuota = n.contains('cuota') ||
        (n.contains('pague') && deudaPregunta != null && !n.contains(' en '));
    if (esCuota) {
      final deuda = deudaPregunta ?? _deudaEnTexto(n, ctx.deudas);
      final monto = parseMontoChat(original);
      if (deuda != null && monto != null && monto > 0) {
        return Intencion(
          accion: AccionesIntencion.proponerMovimiento,
          tipo: 'pagoCuota',
          monto: monto,
          deudaId: deuda.id,
          fecha: _fechaId(hoyCal),
          nota: original,
          confianza: 0.88,
        );
      }
      if (deuda != null) {
        return Intencion(
          accion: AccionesIntencion.noEntendido,
          tipo: 'pagoCuota',
          deudaId: deuda.id,
          fecha: _fechaId(hoyCal),
          textoOriginal: original,
          confianza: 0.55,
        );
      }
    }

    // —— Gasto / ingreso ——
    final monto = parseMontoChat(original);
    var tipo = _detectarTipo(n);
    final catMatch = categoriaMatchDesdeTexto(n);
    // "uber 18 mil" / "arriendo 1,2 millones" sin verbo → gasto
    if (tipo == null && monto != null && catMatch != null) {
      tipo = 'gasto';
    }
    final esAyer = n.contains('ayer');
    final fechaCal = esAyer ? hoyCal.subtract(const Duration(days: 1)) : hoyCal;
    final fecha = _fechaId(fechaCal);

    // Fuera de período vigente → noEntendido con aviso vía textoOriginal.
    final vigente = periodoDe(ctx.ahora, ctx.diaInicioPeriodo);
    final fechaDt = DateTime(fechaCal.year, fechaCal.month, fechaCal.day, 12);
    final periodoFecha = periodoDe(fechaDt, ctx.diaInicioPeriodo);
    if (periodoFecha.periodoId != vigente.periodoId && monto != null) {
      return Intencion(
        accion: AccionesIntencion.noEntendido,
        tipo: tipo,
        monto: monto,
        categoria: tipo == 'gasto' ? (catMatch ?? CategoriasGasto.otros) : null,
        fecha: fecha,
        textoOriginal: original,
        confianza: 0.4,
      );
    }

    if (monto != null && monto > 0 && tipo != null) {
      if (tipo == 'gasto') {
        final cat = catMatch ?? CategoriasGasto.otros;
        return Intencion(
          accion: AccionesIntencion.proponerMovimiento,
          tipo: 'gasto',
          monto: monto,
          categoria: cat,
          fecha: fecha,
          nota: _extraerNota(n),
          confianza: cat == CategoriasGasto.otros ? 0.75 : 0.92,
        );
      }
      if (tipo == 'ingreso') {
        return Intencion(
          accion: AccionesIntencion.proponerMovimiento,
          tipo: 'ingreso',
          monto: monto,
          categoria: 'salario',
          fecha: fecha,
          nota: _extraerNota(n),
          confianza: 0.85,
        );
      }
    }

    // Monto solo sin verbo ni categoría → noEntendido prellenado
    if (monto != null && monto > 0) {
      return Intencion(
        accion: AccionesIntencion.noEntendido,
        tipo: 'gasto',
        monto: monto,
        categoria: catMatch ?? CategoriasGasto.otros,
        fecha: fecha,
        textoOriginal: original,
        confianza: 0.5,
      );
    }

    return Intencion(
      accion: AccionesIntencion.noEntendido,
      textoOriginal: original,
      confianza: 0.2,
    );
  }

  bool _esComoVoy(String n) {
    return n.contains('como voy') ||
        n.contains('como vamos') ||
        n.contains('como estoy') ||
        n.contains('como me va') ||
        n.contains('resumen') ||
        n.contains('mi presupuesto');
  }

  bool _esCuantoMeQueda(String n) {
    return n.contains('cuanto me queda') ||
        n.contains('cuanto me queda por dia') ||
        n.contains('cuanto puedo gastar') ||
        n.contains('que me queda');
  }

  String? _categoriaEnPregunta(String n) {
    final esPregunta = n.contains('cuanto llevo') ||
        n.contains('cuanto he gastado') ||
        n.contains('cuanto gaste') ||
        n.contains('cuanto en');
    if (!esPregunta) return null;
    return categoriaMatchDesdeTexto(n);
  }

  String? _detectarTipo(String n) {
    if (n.contains('me pagaron') ||
        n.contains('recibi') ||
        n.contains('me entro') ||
        n.contains('me depositaron') ||
        n.contains('ingreso') ||
        n.contains('sueldo') ||
        n.contains('salario')) {
      return 'ingreso';
    }
    if (n.contains('gaste') ||
        n.contains('pague') ||
        n.contains('compre') ||
        n.contains('me gaste') ||
        n.contains('se me fueron') ||
        n.contains('gasto de') ||
        n.contains('en el mercado') ||
        n.contains('en mercado') ||
        n.contains('en uber') ||
        n.contains('en el')) {
      return 'gasto';
    }
    return null;
  }

  DeudaContextoChat? _deudaEnTexto(
    String n,
    List<DeudaContextoChat> deudas,
  ) {
    DeudaContextoChat? mejor;
    var mejorLen = 0;
    for (final d in deudas) {
      final nombre = normalizarChat(d.entidad);
      if (nombre.isEmpty) continue;
      if (n.contains(nombre) && nombre.length > mejorLen) {
        mejor = d;
        mejorLen = nombre.length;
      }
      // Coincidencia por primera palabra (ej. "banco" de "Banco XYZ")
      final primera = nombre.split(RegExp(r'\s+')).first;
      if (primera.length >= 4 && n.contains(primera) && primera.length > mejorLen) {
        mejor = d;
        mejorLen = primera.length;
      }
    }
    return mejor;
  }

  String? _extraerNota(String n) {
    // Heurística: última palabra de diccionario o el texto corto.
    for (final e in kDiccionarioCategorias.entries) {
      final clave = normalizarChat(e.key);
      if (n.contains(clave)) return e.key;
    }
    return null;
  }
}
