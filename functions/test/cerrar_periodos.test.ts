import {periodoAnteriorDe, periodoDe, diasTranscurridos} from "../src/periodo";

describe("cerrarPeriodos — detección día 1", () => {
  it("el 15 nov con D=15 es día 1 del nuevo período", () => {
    const now = new Date("2026-11-15T05:30:00.000Z"); // 00:30 Bogotá
    const p = periodoDe(now, 15);
    expect(p.periodoId).toBe("2026-11-15");
    expect(diasTranscurridos(p, now)).toBe(1);
    expect(periodoAnteriorDe(p).periodoId).toBe("2026-10-15");
  });

  it("el 25 nov no es día de cierre", () => {
    const now = new Date("2026-11-25T05:30:00.000Z");
    const p = periodoDe(now, 15);
    expect(diasTranscurridos(p, now)).toBe(11);
  });
});
