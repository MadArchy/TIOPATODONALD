import {umbralesAlcanzados} from "../src/presupuesto";
import {
  gastado,
  porcentajeReducible,
  semaforo,
} from "../src/indicadores";

describe("umbralesAlcanzados", () => {
  it("dispara 50/80/100 una vez", () => {
    expect(umbralesAlcanzados(2000000, 4000000, [])).toEqual([50]);
    expect(umbralesAlcanzados(3200000, 4000000, [50])).toEqual([80]);
    expect(umbralesAlcanzados(4000000, 4000000, [50, 80])).toEqual([100]);
    expect(umbralesAlcanzados(5000000, 4000000, [50, 80, 100])).toEqual([]);
  });
});

describe("indicadores functions", () => {
  it("gastado y semaforo", () => {
    const movs = [
      {tipo: "gasto", monto: 1800000, estado: "activo", categoria: "ocio"},
      {tipo: "ingreso", monto: 100, estado: "activo", categoria: "salario"},
      {tipo: "gasto", monto: 50, estado: "anulado", categoria: "otros"},
    ];
    expect(gastado(movs)).toBe(1800000);
    expect(semaforo(1800000, 4000000)).toBe("verde");
    expect(porcentajeReducible(movs, 1800000)).toBeCloseTo(1);
  });
});
