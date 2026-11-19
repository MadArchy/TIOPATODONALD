import 'package:app/core/deudas_internas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calcularConfirmacionPagoInterno', () {
    test('flujo María confirma 2 pagos → saldo 0 y pagada', () {
      final r = simularFlujoPagosConfirmados(
        montoInicial: 100000,
        montosConfirmados: [40000, 60000],
      );
      expect(r.saldo, 0);
      expect(r.estado, 'pagada');
    });

    test('idempotente si ya confirmado', () {
      final r = calcularConfirmacionPagoInterno(
        yaConfirmado: true,
        saldoActual: 50000,
        montoPago: 50000,
        estadoActual: 'aceptada',
      );
      expect(r.aplicar, isFalse);
      expect(r.nuevoSaldo, 50000);
      expect(r.motivo, 'ya_confirmado');
    });

    test('no deja saldo negativo', () {
      final r = calcularConfirmacionPagoInterno(
        yaConfirmado: false,
        saldoActual: 10000,
        montoPago: 30000,
        estadoActual: 'aceptada',
      );
      expect(r.aplicar, isTrue);
      expect(r.nuevoSaldo, 0);
      expect(r.nuevoEstado, 'pagada');
    });
  });

  group('construirAvisosInternos', () {
    test('deudor ve pendiente; acreedor ve pago por confirmar', () {
      final avisosJuan = construirAvisosInternos(
        uid: 'juan',
        deudas: [
          (
            id: 'd1',
            acreedorUid: 'maria',
            deudorUid: 'juan',
            concepto: 'Almuerzo',
            saldo: 100000,
            estado: 'pendiente',
            nombreContraparte: 'María',
          ),
        ],
        pagos: const [],
      );
      expect(avisosJuan, hasLength(1));
      expect(avisosJuan.first.tipo, TipoAvisoInterno.pendienteAceptacion);

      final avisosMaria = construirAvisosInternos(
        uid: 'maria',
        deudas: [
          (
            id: 'd1',
            acreedorUid: 'maria',
            deudorUid: 'juan',
            concepto: 'Almuerzo',
            saldo: 60000,
            estado: 'aceptada',
            nombreContraparte: 'Juan',
          ),
        ],
        pagos: [
          (
            deudaId: 'd1',
            pagoId: 'p1',
            acreedorUid: 'maria',
            monto: 40000,
            confirmado: false,
            nombreDeudor: 'Juan',
          ),
        ],
      );
      expect(avisosMaria, hasLength(1));
      expect(avisosMaria.first.tipo, TipoAvisoInterno.pagoPorConfirmar);
    });

    test('tercer miembro no recibe avisos de esa deuda', () {
      final avisos = construirAvisosInternos(
        uid: 'pedro',
        deudas: [
          (
            id: 'd1',
            acreedorUid: 'maria',
            deudorUid: 'juan',
            concepto: 'Almuerzo',
            saldo: 100000,
            estado: 'pendiente',
            nombreContraparte: 'María',
          ),
        ],
        pagos: [
          (
            deudaId: 'd1',
            pagoId: 'p1',
            acreedorUid: 'maria',
            monto: 40000,
            confirmado: false,
            nombreDeudor: 'Juan',
          ),
        ],
      );
      expect(avisos, isEmpty);
    });
  });

  group('etiquetaEstadoDeudaInterna', () {
    test('etiquetas en español', () {
      expect(etiquetaEstadoDeudaInterna('pendiente'), 'Pendiente');
      expect(etiquetaEstadoDeudaInterna('aceptada'), 'Aceptada');
      expect(etiquetaEstadoDeudaInterna('rechazada'), 'Rechazada');
      expect(etiquetaEstadoDeudaInterna('pagada'), 'Pagada');
    });
  });
}
