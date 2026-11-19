import {esEdicionMenor} from "../src/movimientos";

describe("esEdicionMenor", () => {
  it("true solo si cambian nota/categoria/editadoEn", () => {
    expect(
      esEdicionMenor(
        {nota: "", categoria: "ocio", monto: 1000, uid: "u1"},
        {nota: "x", categoria: "ocio", monto: 1000, uid: "u1"}
      )
    ).toBe(true);
    expect(
      esEdicionMenor(
        {nota: "", categoria: "ocio", monto: 1000},
        {nota: "", categoria: "alimentacion", monto: 1000}
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
});
