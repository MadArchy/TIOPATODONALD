import functionsTest from "firebase-functions-test";
import {construirRespuestaPing, ping, REGION} from "../src/index";

const testEnv = functionsTest();

describe("Cloud Function: ping (Slice 0)", () => {
  afterAll(() => {
    testEnv.cleanup();
  });

  it("construirRespuestaPing devuelve ok=true, mensaje='pong' y región us-central1", () => {
    const fechaFija = new Date("2026-11-18T20:00:00.000Z");
    const res = construirRespuestaPing(fechaFija);

    expect(res).toEqual({
      ok: true,
      mensaje: "pong",
      region: "us-central1",
      timestamp: "2026-11-18T20:00:00.000Z",
    });
  });

  it("callable ping responde con pong y timestamp ISO válido", async () => {
    const wrappedPing = testEnv.wrap(ping);
    const res = await wrappedPing({
      data: {},
      rawRequest: {} as never,
      acceptsStreaming: false,
    });

    expect(res.ok).toBe(true);
    expect(res.mensaje).toBe("pong");
    expect(res.region).toBe(REGION);
    expect(typeof res.timestamp).toBe("string");
    expect(new Date(res.timestamp).toString()).not.toBe("Invalid Date");
  });
});
