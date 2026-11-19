/// Datos extraídos de un código QR o deep link de invitación (`patodonald://unirse?h={hogarId}&c={codigo}`).
class InvitacionQrPayload {
  const InvitacionQrPayload({
    required this.hogarId,
    required this.codigo,
  });

  final String hogarId;
  final String codigo;

  String toQrUrl() =>
      'patodonald://unirse?h=${Uri.encodeQueryComponent(hogarId)}&c=${Uri.encodeQueryComponent(codigo)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvitacionQrPayload &&
        other.hogarId == hogarId &&
        other.codigo == codigo;
  }

  @override
  int get hashCode => Object.hash(hogarId, codigo);
}

/// Parsea una URL o cadena escaneada desde el QR (`patodonald://unirse?h=..&c=..`).
/// Devuelve `null` si el formato no corresponde a una invitación válida.
InvitacionQrPayload? parseInvitacionQr(String raw) {
  final texto = raw.trim();
  if (texto.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(texto);
  if (uri == null) {
    return null;
  }

  final esDeepLinkValido =
      (uri.scheme == 'patodonald' && uri.host == 'unirse') ||
      uri.path == '/unirse' ||
      uri.path == 'unirse';

  if (!esDeepLinkValido) {
    return null;
  }

  final hogarId = (uri.queryParameters['h'] ?? '').trim();
  final codigo = (uri.queryParameters['c'] ?? '').trim();

  if (hogarId.isEmpty || codigo.isEmpty) {
    return null;
  }

  return InvitacionQrPayload(hogarId: hogarId, codigo: codigo);
}
