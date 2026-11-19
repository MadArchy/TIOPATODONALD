import {
  coincideHoraRecordatorio,
  cuotaVenceManana,
  enFranjaAvisosHogar,
  horaBogotaHHMM,
  normalizarPreferencias,
  payloadAlertaPresupuesto,
  preferenciaActiva,
  seleccionarTokens,
} from "../src/avisos";

describe("avisos — preferencias", () => {
  it("defaults a true si falta el mapa", () => {
    const p = normalizarPreferencias(undefined);
    expect(p.alertasPresupuesto).toBe(true);
    expect(p.recordatorioDiario).toBe(true);
    expect(preferenciaActiva(p, "cuotas")).toBe(true);
  });

  it("respeta false explícito", () => {
    const p = normalizarPreferencias({
      alertasPresupuesto: false,
      correcciones: false,
    });
    expect(p.alertasPresupuesto).toBe(false);
    expect(p.correcciones).toBe(false);
    expect(p.cuotas).toBe(true);
  });
});

describe("avisos — hora recordatorio", () => {
  it("coincide en la hora exacta Bogotá", () => {
    // 2026-11-19 14:00 UTC = 09:00 Bogotá
    const ahora = new Date(Date.UTC(2026, 10, 19, 14, 0, 0));
    expect(horaBogotaHHMM(ahora)).toBe("09:00");
    expect(
      coincideHoraRecordatorio({
        horaRecordatorio: "09:00",
        ahora,
      })
    ).toBe(true);
  });

  it("coincide dentro de ventana de 15 min", () => {
    const ahora = new Date(Date.UTC(2026, 10, 19, 14, 10, 0)); // 09:10 Bogotá
    expect(
      coincideHoraRecordatorio({
        horaRecordatorio: "09:00",
        ahora,
        ventanaMinutos: 15,
      })
    ).toBe(true);
    expect(
      coincideHoraRecordatorio({
        horaRecordatorio: "08:00",
        ahora,
        ventanaMinutos: 15,
      })
    ).toBe(false);
  });

  it("rechaza hora inválida", () => {
    const ahora = new Date();
    expect(
      coincideHoraRecordatorio({horaRecordatorio: null, ahora})
    ).toBe(false);
    expect(
      coincideHoraRecordatorio({horaRecordatorio: "9:00", ahora})
    ).toBe(false);
  });
});

describe("avisos — cuota mañana", () => {
  it("detecta diaPago = día de mañana", () => {
    // 2026-11-19 Bogotá → mañana 20
    const ahora = new Date(Date.UTC(2026, 10, 19, 17, 0, 0));
    expect(cuotaVenceManana({diaPago: 20, ahora})).toBe(true);
    expect(cuotaVenceManana({diaPago: 19, ahora})).toBe(false);
  });

  it("respeta último día en meses cortos (feb)", () => {
    // 2026-02-27 Bogotá → mañana 28
    const ahora = new Date(Date.UTC(2026, 1, 27, 17, 0, 0));
    expect(cuotaVenceManana({diaPago: 28, ahora})).toBe(true);
    expect(cuotaVenceManana({diaPago: 31, ahora})).toBe(true); // efectivo 28
  });
});

describe("avisos — seleccionarTokens", () => {
  it("omite preferencia apagada y sin tokens", () => {
    const dest = seleccionarTokens({
      tipo: "correcciones",
      usuarios: [
        {
          uid: "a",
          fcmTokens: ["t1"],
          preferenciasAvisos: {correcciones: false},
        },
        {uid: "b", fcmTokens: [], preferenciasAvisos: {}},
        {uid: "c", fcmTokens: ["t2", "t3"], preferenciasAvisos: {}},
      ],
    });
    expect(dest).toEqual([{uid: "c", tokens: ["t2", "t3"]}]);
  });
});

describe("avisos — payloads", () => {
  it("alerta presupuesto incluye umbral", () => {
    const p = payloadAlertaPresupuesto(80);
    expect(p.titulo).toContain("presupuesto");
    expect(p.cuerpo).toContain("80%");
    expect(p.data?.umbral).toBe("80");
  });
});

describe("avisos — franja diaria de cuotas y correcciones", () => {
  it("solo activa en la franja 08:00–08:14 Bogotá (evita spam cada 15 min)", () => {
    // 13:00 UTC = 08:00 Bogotá
    expect(enFranjaAvisosHogar(new Date(Date.UTC(2026, 10, 19, 13, 0, 0)))).toBe(true);
    // 13:14 UTC = 08:14 Bogotá
    expect(enFranjaAvisosHogar(new Date(Date.UTC(2026, 10, 19, 13, 14, 0)))).toBe(true);
    // 13:15 UTC = 08:15 Bogotá → fuera de la ventana
    expect(enFranjaAvisosHogar(new Date(Date.UTC(2026, 10, 19, 13, 15, 0)))).toBe(false);
    // 19:00 UTC = 14:00 Bogotá → fuera de la ventana
    expect(enFranjaAvisosHogar(new Date(Date.UTC(2026, 10, 19, 19, 0, 0)))).toBe(false);
  });
});
