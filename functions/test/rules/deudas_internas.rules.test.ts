import * as fs from "fs";
import * as path from "path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from "firebase/firestore";

describe("Slice 6 — Deudas internas security rules", () => {
  let testEnv: RulesTestEnvironment;
  const hogarId = "hogar-internas-1";
  const mariaUid = "uid-maria";
  const juanUid = "uid-juan";
  const terceroUid = "uid-tercero";

  async function seed(): Promise<void> {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      for (const [uid, nombre] of [
        [mariaUid, "María"],
        [juanUid, "Juan"],
        [terceroUid, "Pedro"],
      ] as const) {
        await setDoc(doc(db, `usuarios/${uid}`), {
          nombre,
          email: `${uid}@pato.co`,
          hogarId,
          diaInicioPeriodo: 1,
        });
        await setDoc(doc(db, `hogares/${hogarId}/miembros/${uid}`), {
          nombre,
          rol: uid === mariaUid ? "admin" : "miembro",
          estado: "activo",
          unidoEn: Timestamp.now(),
        });
      }
      await setDoc(doc(db, `hogares/${hogarId}`), {
        nombre: "Familia Pato",
        adminUid: mariaUid,
      });
    });
  }

  function deudaPendiente(
    overrides: Record<string, unknown> = {}
  ): Record<string, unknown> {
    return {
      acreedorUid: mariaUid,
      deudorUid: juanUid,
      montoInicial: 100000,
      saldo: 100000,
      concepto: "Almuerzo",
      estado: "pendiente",
      creadaEn: serverTimestamp(),
      ...overrides,
    };
  }

  beforeAll(async () => {
    const rulesPath = path.resolve(__dirname, "../../../firestore.rules");
    testEnv = await initializeTestEnvironment({
      projectId: "pato-donald-dev-deudas-internas",
      firestore: {
        rules: fs.readFileSync(rulesPath, "utf8"),
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    await seed();
  });

  afterAll(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  it("acreedor crea deuda pendiente ok", async () => {
    const db = testEnv.authenticatedContext(mariaUid).firestore();
    await assertSucceeds(
      setDoc(
        doc(db, `hogares/${hogarId}/deudasInternas/di1`),
        deudaPendiente()
      )
    );
  });

  it("deudor no puede crear cobro a nombre del acreedor", async () => {
    const db = testEnv.authenticatedContext(juanUid).firestore();
    await assertFails(
      setDoc(
        doc(db, `hogares/${hogarId}/deudasInternas/di2`),
        deudaPendiente()
      )
    );
  });

  it("deudor acepta pendiente → aceptada", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudasInternas/di3`),
        deudaPendiente({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(juanUid).firestore();
    await assertSucceeds(
      updateDoc(doc(db, `hogares/${hogarId}/deudasInternas/di3`), {
        estado: "aceptada",
      })
    );
  });

  it("deudor rechaza pendiente → rechazada", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudasInternas/di4`),
        deudaPendiente({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(juanUid).firestore();
    await assertSucceeds(
      updateDoc(doc(db, `hogares/${hogarId}/deudasInternas/di4`), {
        estado: "rechazada",
      })
    );
  });

  it("tercer miembro no puede aceptar", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudasInternas/di5`),
        deudaPendiente({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(terceroUid).firestore();
    await assertFails(
      updateDoc(doc(db, `hogares/${hogarId}/deudasInternas/di5`), {
        estado: "aceptada",
      })
    );
  });

  it("tercer miembro no puede leer la deuda", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudasInternas/di6`),
        deudaPendiente({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(terceroUid).firestore();
    await assertFails(
      getDoc(doc(db, `hogares/${hogarId}/deudasInternas/di6`))
    );
  });

  it("admin (María acreedora) sí puede leer", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudasInternas/di7`),
        deudaPendiente({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(mariaUid).firestore();
    await assertSucceeds(
      getDoc(doc(db, `hogares/${hogarId}/deudasInternas/di7`))
    );
  });

  it("deudor registra pago con confirmado false", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudasInternas/di8`),
        deudaPendiente({
          estado: "aceptada",
          creadaEn: Timestamp.now(),
        })
      );
    });
    const db = testEnv.authenticatedContext(juanUid).firestore();
    await assertSucceeds(
      setDoc(doc(db, `hogares/${hogarId}/deudasInternas/di8/pagos/p1`), {
        monto: 40000,
        fecha: Timestamp.now(),
        registradoPor: juanUid,
        confirmado: false,
        confirmadoEn: null,
      })
    );
  });

  it("cliente no puede update pagos (solo Function)", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(
        doc(db, `hogares/${hogarId}/deudasInternas/di9`),
        deudaPendiente({estado: "aceptada", creadaEn: Timestamp.now()})
      );
      await setDoc(doc(db, `hogares/${hogarId}/deudasInternas/di9/pagos/p2`), {
        monto: 40000,
        fecha: Timestamp.now(),
        registradoPor: juanUid,
        confirmado: false,
        confirmadoEn: null,
      });
    });
    const db = testEnv.authenticatedContext(mariaUid).firestore();
    await assertFails(
      updateDoc(doc(db, `hogares/${hogarId}/deudasInternas/di9/pagos/p2`), {
        confirmado: true,
      })
    );
  });

  it("tercer miembro no puede registrar pago", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudasInternas/di10`),
        deudaPendiente({estado: "aceptada", creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(terceroUid).firestore();
    await assertFails(
      setDoc(doc(db, `hogares/${hogarId}/deudasInternas/di10/pagos/p3`), {
        monto: 10000,
        fecha: Timestamp.now(),
        registradoPor: terceroUid,
        confirmado: false,
        confirmadoEn: null,
      })
    );
  });

  it("acreedor no puede bajar saldo por update cliente", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudasInternas/di11`),
        deudaPendiente({estado: "aceptada", creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(mariaUid).firestore();
    await assertFails(
      updateDoc(doc(db, `hogares/${hogarId}/deudasInternas/di11`), {
        saldo: 0,
        estado: "pagada",
      })
    );
  });
});
