import {
  accionAuditoriaCorreccion,
  calcularAjustesSaldoPorCorreccion,
  dentroDePlazoCorreccion,
} from "../src/correcciones";

describe("dentroDePlazoCorreccion", () => {
  it("dentro del período → true; 6 días tras cierre → false", () => {
    expect(
      dentroDePlazoCorreccion({
        periodoIdMovimiento: "2026-11-15",
        diaInicioDueno: 15,
        ahora: new Date(Date.UTC(2026, 10, 25, 15, 0, 0)),
      })
    ).toBe(true);

    // Fin período = 14 dic 23:59:59.999 UTC-calendar; +5d = 19 dic.
    expect(
      dentroDePlazoCorreccion({
        periodoIdMovimiento: "2026-11-15",
        diaInicioDueno: 15,
        ahora: new Date(Date.UTC(2026, 11, 19, 23, 59, 0)),
      })
    ).toBe(true);

    expect(
      dentroDePlazoCorreccion({
        periodoIdMovimiento: "2026-11-15",
        diaInicioDueno: 15,
        ahora: new Date(Date.UTC(2026, 11, 20, 0, 0, 1)),
      })
    ).toBe(false);
  });
});

describe("calcularAjustesSaldoPorCorreccion", () => {
  it("gasto → pagoCuota baja el saldo", () => {
    const r = calcularAjustesSaldoPorCorreccion({
      tipoAntes: "gasto",
      tipoDespues: "pagoCuota",
      estadoDespues: "activo",
      montoAntes: 200000,
      montoDespues: 200000,
      deudaIdAntes: null,
      deudaIdDespues: "d1",
      saldoAplicadoAntes: false,
    });
    expect(r.nuevoSaldoAplicado).toBe(true);
    expect(r.deltas).toEqual([{deudaId: "d1", delta: -200000}]);
  });

  it("pagoCuota → gasto devuelve el saldo", () => {
    const r = calcularAjustesSaldoPorCorreccion({
      tipoAntes: "pagoCuota",
      tipoDespues: "gasto",
      estadoDespues: "activo",
      montoAntes: 150000,
      montoDespues: 150000,
      deudaIdAntes: "d1",
      deudaIdDespues: null,
      saldoAplicadoAntes: true,
    });
    expect(r.nuevoSaldoAplicado).toBe(false);
    expect(r.deltas).toEqual([{deudaId: "d1", delta: 150000}]);
  });

  it("ida y vuelta: reclasificar y deshacer restaura saldo neto 0", () => {
    const ida = calcularAjustesSaldoPorCorreccion({
      tipoAntes: "gasto",
      tipoDespues: "pagoCuota",
      estadoDespues: "activo",
      montoAntes: 100000,
      montoDespues: 100000,
      deudaIdAntes: null,
      deudaIdDespues: "d1",
      saldoAplicadoAntes: false,
    });
    const vuelta = calcularAjustesSaldoPorCorreccion({
      tipoAntes: "pagoCuota",
      tipoDespues: "gasto",
      estadoDespues: "activo",
      montoAntes: 100000,
      montoDespues: 100000,
      deudaIdAntes: "d1",
      deudaIdDespues: null,
      saldoAplicadoAntes: true,
    });
    expect(ida.deltas[0].delta + vuelta.deltas[0].delta).toBe(0);
  });
});

describe("accionAuditoriaCorreccion", () => {
  it("elige accion correcta", () => {
    expect(
      accionAuditoriaCorreccion({adminCorrigeLoSuyo: true, anula: false})
    ).toBe("correccionAdminPropia");
    expect(
      accionAuditoriaCorreccion({adminCorrigeLoSuyo: false, anula: true})
    ).toBe("anulacion");
    expect(
      accionAuditoriaCorreccion({adminCorrigeLoSuyo: false, anula: false})
    ).toBe("correccion");
  });
});
