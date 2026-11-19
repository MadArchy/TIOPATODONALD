import {calcularConfirmacionPagoInterno} from "../src/deudas_internas";

describe("calcularConfirmacionPagoInterno", () => {
  it("flujo María confirma dos pagos de Juan → saldo 0 y pagada", () => {
    const montoInicial = 100000;
    let saldo = montoInicial;
    let estado = "aceptada";

    const p1 = calcularConfirmacionPagoInterno({
      yaConfirmado: false,
      saldoActual: saldo,
      montoPago: 40000,
      estadoActual: estado,
    });
    expect(p1.aplicar).toBe(true);
    expect(p1.nuevoSaldo).toBe(60000);
    expect(p1.nuevoEstado).toBe("aceptada");
    saldo = p1.nuevoSaldo;
    estado = p1.nuevoEstado;

    const p2 = calcularConfirmacionPagoInterno({
      yaConfirmado: false,
      saldoActual: saldo,
      montoPago: 60000,
      estadoActual: estado,
    });
    expect(p2.aplicar).toBe(true);
    expect(p2.nuevoSaldo).toBe(0);
    expect(p2.nuevoEstado).toBe("pagada");
  });

  it("idempotente si ya estaba confirmado", () => {
    const r = calcularConfirmacionPagoInterno({
      yaConfirmado: true,
      saldoActual: 50000,
      montoPago: 50000,
      estadoActual: "aceptada",
    });
    expect(r.aplicar).toBe(false);
    expect(r.nuevoSaldo).toBe(50000);
    expect(r.motivo).toBe("ya_confirmado");
  });

  it("no deja saldo negativo", () => {
    const r = calcularConfirmacionPagoInterno({
      yaConfirmado: false,
      saldoActual: 10000,
      montoPago: 30000,
      estadoActual: "aceptada",
    });
    expect(r.aplicar).toBe(true);
    expect(r.nuevoSaldo).toBe(0);
    expect(r.nuevoEstado).toBe("pagada");
  });
});
