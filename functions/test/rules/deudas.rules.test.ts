import * as fs from "fs";
import * as path from "path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from "firebase/firestore";

describe("Slice 5 — Deudas security rules", () => {
  let testEnv: RulesTestEnvironment;
  const hogarId = "hogar-deudas-1";
  const adminUid = "uid-admin";
  const miembroUid = "uid-miembro";

  async function seed(): Promise<void> {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, `usuarios/${adminUid}`), {
        nombre: "Admin",
        email: "admin@pato.co",
        hogarId,
        diaInicioPeriodo: 1,
      });
      await setDoc(doc(db, `usuarios/${miembroUid}`), {
        nombre: "Miembro",
        email: "miembro@pato.co",
        hogarId,
        diaInicioPeriodo: 1,
      });
      await setDoc(doc(db, `hogares/${hogarId}`), {
        nombre: "Familia Pato",
        adminUid,
      });
      await setDoc(doc(db, `hogares/${hogarId}/miembros/${adminUid}`), {
        nombre: "Admin",
        rol: "admin",
        estado: "activo",
        unidoEn: Timestamp.now(),
      });
      await setDoc(doc(db, `hogares/${hogarId}/miembros/${miembroUid}`), {
        nombre: "Miembro",
        rol: "miembro",
        estado: "activo",
        unidoEn: Timestamp.now(),
      });
    });
  }

  function deudaBase(
    overrides: Record<string, unknown> = {}
  ): Record<string, unknown> {
    return {
      entidad: "Bancolombia",
      saldoInicial: 1000000,
      saldoActual: 1000000,
      cuotaMensual: 150000,
      diaPago: 15,
      numeroCuotas: 12,
      estado: "activa",
      creadaEn: serverTimestamp(),
      ...overrides,
    };
  }

  beforeAll(async () => {
    const rulesPath = path.resolve(__dirname, "../../../firestore.rules");
    testEnv = await initializeTestEnvironment({
      projectId: "pato-donald-dev-deudas",
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

  it("admin create ok con saldoActual == saldoInicial", async () => {
    const db = testEnv.authenticatedContext(adminUid).firestore();
    await assertSucceeds(
      setDoc(doc(db, `hogares/${hogarId}/deudas/d1`), deudaBase())
    );
  });

  it("miembro no admin no puede create deudas", async () => {
    const db = testEnv.authenticatedContext(miembroUid).firestore();
    await assertFails(
      setDoc(doc(db, `hogares/${hogarId}/deudas/d2`), deudaBase())
    );
  });

  it("miembro no admin no puede update deudas", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudas/d3`),
        deudaBase({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(miembroUid).firestore();
    await assertFails(
      updateDoc(doc(db, `hogares/${hogarId}/deudas/d3`), {
        cuotaMensual: 200000,
      })
    );
  });

  it("admin update que intenta cambiar saldoActual falla", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudas/d4`),
        deudaBase({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(adminUid).firestore();
    await assertFails(
      updateDoc(doc(db, `hogares/${hogarId}/deudas/d4`), {
        saldoActual: 500000,
      })
    );
  });

  it("admin update ok sin tocar saldoActual", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudas/d5`),
        deudaBase({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(adminUid).firestore();
    await assertSucceeds(
      updateDoc(doc(db, `hogares/${hogarId}/deudas/d5`), {
        entidad: "Davivienda",
        cuotaMensual: 160000,
        diaPago: 20,
      })
    );
  });

  it("delete de deudas siempre falla", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudas/d6`),
        deudaBase({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(adminUid).firestore();
    await assertFails(deleteDoc(doc(db, `hogares/${hogarId}/deudas/d6`)));
  });

  it("miembro puede leer deudas", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/deudas/d7`),
        deudaBase({creadaEn: Timestamp.now()})
      );
    });
    const db = testEnv.authenticatedContext(miembroUid).firestore();
    await assertSucceeds(getDoc(doc(db, `hogares/${hogarId}/deudas/d7`)));
  });
});
