// Lógica pura de deudas entre miembros (`docs/02_reglas_negocio.md` §8).

/// Resultado de confirmar un pago interno (espejo de la Function).
class ResultadoConfirmacionPagoInterno {
  const ResultadoConfirmacionPagoInterno({
    required this.aplicar,
    required this.nuevoSaldo,
    required this.nuevoEstado,
    this.motivo,
  });

  final bool aplicar;
  final int nuevoSaldo;
  final String nuevoEstado;
  final String? motivo;
}

/// Baja [saldoActual] por [montoPago]; en 0 → `pagada`. Idempotente si ya confirmado.
ResultadoConfirmacionPagoInterno calcularConfirmacionPagoInterno({
  required bool yaConfirmado,
  required int saldoActual,
  required int montoPago,
  required String estadoActual,
}) {
  if (yaConfirmado) {
    return ResultadoConfirmacionPagoInterno(
      aplicar: false,
      nuevoSaldo: saldoActual,
      nuevoEstado: estadoActual,
      motivo: 'ya_confirmado',
    );
  }
  final monto = montoPago < 0 ? 0 : montoPago;
  final nuevoSaldo = (saldoActual - monto).clamp(0, saldoActual);
  final nuevoEstado = nuevoSaldo == 0 ? 'pagada' : estadoActual;
  return ResultadoConfirmacionPagoInterno(
    aplicar: true,
    nuevoSaldo: nuevoSaldo,
    nuevoEstado: nuevoEstado,
  );
}

/// Etiqueta corta en español de Colombia para el estado.
String etiquetaEstadoDeudaInterna(String estado) {
  switch (estado) {
    case 'pendiente':
      return 'Pendiente';
    case 'aceptada':
      return 'Aceptada';
    case 'rechazada':
      return 'Rechazada';
    case 'pagada':
      return 'Pagada';
    default:
      return estado;
  }
}

/// Aviso in-app derivado (sin colección nueva).
enum TipoAvisoInterno {
  /// Deudor debe aceptar o rechazar.
  pendienteAceptacion,

  /// Acreedor debe confirmar un pago.
  pagoPorConfirmar,
}

class AvisoDeudaInterna {
  const AvisoDeudaInterna({
    required this.tipo,
    required this.deudaId,
    required this.titulo,
    required this.detalle,
    this.pagoId,
  });

  final TipoAvisoInterno tipo;
  final String deudaId;
  final String titulo;
  final String detalle;
  final String? pagoId;
}

/// Construye avisos accionables para [uid] a partir de deudas y pagos pendientes.
List<AvisoDeudaInterna> construirAvisosInternos({
  required String uid,
  required Iterable<({
    String id,
    String acreedorUid,
    String deudorUid,
    String concepto,
    int saldo,
    String estado,
    String nombreContraparte,
  })> deudas,
  required Iterable<({
    String deudaId,
    String pagoId,
    String acreedorUid,
    int monto,
    bool confirmado,
    String nombreDeudor,
  })> pagos,
}) {
  final avisos = <AvisoDeudaInterna>[];

  for (final d in deudas) {
    if (d.estado == 'pendiente' && d.deudorUid == uid) {
      avisos.add(
        AvisoDeudaInterna(
          tipo: TipoAvisoInterno.pendienteAceptacion,
          deudaId: d.id,
          titulo: '${d.nombreContraparte} te cobró',
          detalle: d.concepto,
        ),
      );
    }
  }

  for (final p in pagos) {
    if (!p.confirmado && p.acreedorUid == uid) {
      avisos.add(
        AvisoDeudaInterna(
          tipo: TipoAvisoInterno.pagoPorConfirmar,
          deudaId: p.deudaId,
          pagoId: p.pagoId,
          titulo: '${p.nombreDeudor} registró un pago',
          detalle: 'Confirma el pago para bajar el saldo.',
        ),
      );
    }
  }

  return avisos;
}

/// Simula el flujo completo de confirmaciones (útil en tests).
/// Retorna saldo y estado tras aplicar montos en orden (todos confirmados).
({int saldo, String estado}) simularFlujoPagosConfirmados({
  required int montoInicial,
  required List<int> montosConfirmados,
}) {
  var saldo = montoInicial;
  var estado = 'aceptada';
  for (final monto in montosConfirmados) {
    final r = calcularConfirmacionPagoInterno(
      yaConfirmado: false,
      saldoActual: saldo,
      montoPago: monto,
      estadoActual: estado,
    );
    saldo = r.nuevoSaldo;
    estado = r.nuevoEstado;
  }
  return (saldo: saldo, estado: estado);
}
