import {
  diasTranscurridos,
  periodoAnteriorDe,
  periodoDe,
} from "../src/periodo";

describe("periodo (functions)", () => {
  it("ejemplo oficial D=15, 2026-11-25", () => {
    // 2026-11-25 14:30 Bogotá = 19:30 UTC
    const hoy = new Date("2026-11-25T19:30:00.000Z");
    const p = periodoDe(hoy, 15);
    expect(p.periodoId).toBe("2026-11-15");
    expect(p.diasTotales).toBe(30);
    expect(diasTranscurridos(p, hoy)).toBe(11);
  });

  it("periodoAnteriorDe desde 2026-11-15", () => {
    const actual = periodoDe(new Date("2026-11-15T17:00:00.000Z"), 15);
    const ant = periodoAnteriorDe(actual);
    expect(ant.periodoId).toBe("2026-10-15");
  });
});
