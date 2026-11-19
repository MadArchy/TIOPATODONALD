import {Firestore} from "firebase-admin/firestore";
import {ejecutarAsistente} from "../src/asistente";

describe("asistente (puerta de IA)", () => {
  it("responde próximamente para miembro activo", async () => {
    const db = {
      collection: () => ({
        doc: () => ({
          collection: () => ({
            doc: () => ({
              get: async () => ({
                exists: true,
                data: () => ({estado: "activo"}),
              }),
            }),
          }),
        }),
      }),
    } as unknown as Firestore;

    const r = await ejecutarAsistente(db, "uid-1", {hogarId: "h1"});
    expect(r.disponible).toBe(false);
    expect(r.mensaje.toLowerCase()).toContain("próximamente");
  });
});
