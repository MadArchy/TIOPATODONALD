import {
  calcularAplicacionPagoCuota,
  esEdicionMenor,
} from "../src/movimientos";

describe("esEdicionMenor", () => {
  it("true solo si cambian nota/categoria/editadoEn en gasto", () => {
    expect(
      esEdicionMenor(
        {nota: "", categoria: "ocio", monto: 1000, uid: "u1", tipo: "gasto"},
        {nota: "x", categoria: "ocio", monto: 1000, uid: "u1", tipo: "gasto"}
      )
    ).toBe(true);
    expect(
      esEdicionMenor(
        {nota: "", categoria: "ocio", monto: 1000, tipo: "gasto"},
        {nota: "", categoria: "alimentacion", monto: 1000, tipo: "gasto"}
      )
    ).toBe(true);
  });

  it("false si cambia monto u otros campos", () => {
    expect(
      esEdicionMenor(
        {nota: "", monto: 1000},
        {nota: "", monto: 2000}
      )
    ).toBe(false);
    expect(
      esEdicionMenor(
        {fotoPath: null},
        {fotoPath: "recibos/h/m.jpg"}
      )
    ).toBe(false);
  });

  it("false si cambia categoria de ingreso (va por corrección)", () => {
    expect(
      esEdicionMenor(
        {nota: "", categoria: "salario", monto: 1000, tipo: "ingreso"},
        {nota: "", categoria: "otros_ingreso", monto: 1000, tipo: "ingreso"}
      )
    ).toBe(false);
  });
});

describe("calcularAplicacionPagoCuota (idempotencia)", () => {
  it("baja saldo y marca aplicar en el primer paso", () => {
    const r = calcularAplicacionPagoCuota({
      saldoAplicado: false,
      saldoActual: 500000,
      monto: 150000,
      estadoActual: "activa",
    });
    expect(r.aplicar).toBe(true);
    expect(r.nuevoSaldo).toBe(350000);
    expect(r.nuevoEstado).toBe("activa");
  });

  it("si saldoAplicado ya es true, no vuelve a bajar", () => {
    const primero = calcularAplicacionPagoCuota({
      saldoAplicado: false,
      saldoActual: 150000,
      monto: 150000,
      estadoActual: "activa",
    });
    expect(primero.aplicar).toBe(true);
    expect(primero.nuevoSaldo).toBe(0);
    expect(primero.nuevoEstado).toBe("pagada");

    // Segunda ejecución del trigger (mismo movimiento ya marcado).
    const segundo = calcularAplicacionPagoCuota({
      saldoAplicado: true,
      saldoActual: primero.nuevoSaldo,
      monto: 150000,
      estadoActual: primero.nuevoEstado,
    });
    expect(segundo.aplicar).toBe(false);
    expect(segundo.nuevoSaldo).toBe(0);
    expect(segundo.nuevoEstado).toBe("pagada");
    expect(segundo.motivo).toBe("ya_aplicado");
  });

  it("no deja saldo negativo", () => {
    const r = calcularAplicacionPagoCuota({
      saldoAplicado: false,
      saldoActual: 50000,
      monto: 80000,
      estadoActual: "activa",
    });
    expect(r.aplicar).toBe(true);
    expect(r.nuevoSaldo).toBe(0);
    expect(r.nuevoEstado).toBe("pagada");
  });
});
