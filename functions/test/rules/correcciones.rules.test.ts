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
  setDoc,
  serverTimestamp,
  updateDoc,
  deleteDoc,
} from "firebase/firestore";

describe("Slice 7 — Correcciones security rules", () => {
  let testEnv: RulesTestEnvironment;
  const hogarId = "hogar-corr-1";
  const adminUid = "uid-admin";
  const miembroUid = "uid-miembro";

  async function seed(): Promise<void> {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, `usuarios/${adminUid}`), {
        nombre: "Admin",
        email: "a@pato.co",
        hogarId,
        diaInicioPeriodo: 1,
      });
      await setDoc(doc(db, `usuarios/${miembroUid}`), {
        nombre: "Miembro",
        email: "m@pato.co",
        hogarId,
        diaInicioPeriodo: 1,
      });
      await setDoc(doc(db, `hogares/${hogarId}`), {
        nombre: "Familia",
        adminUid,
      });
      await setDoc(doc(db, `hogares/${hogarId}/miembros/${adminUid}`), {
        nombre: "Admin",
        rol: "admin",
        estado: "activo",
      });
      await setDoc(doc(db, `hogares/${hogarId}/miembros/${miembroUid}`), {
        nombre: "Miembro",
        rol: "miembro",
        estado: "activo",
      });
    });
  }

  beforeAll(async () => {
    const rulesPath = path.resolve(__dirname, "../../../firestore.rules");
    testEnv = await initializeTestEnvironment({
      projectId: "pato-donald-dev-corr",
      firestore: {rules: fs.readFileSync(rulesPath, "utf8")},
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    await seed();
  });

  it("miembro activo puede crear corrección pendiente con motivo", async () => {
    const db = testEnv.authenticatedContext(miembroUid).firestore();
    await assertSucceeds(
      setDoc(doc(db, `hogares/${hogarId}/correcciones/c1`), {
        movimientoId: "mov1",
        solicitanteUid: miembroUid,
        motivo: "Monto mal digitado",
        cambios: {monto: 50000},
        estado: "pendiente",
        resueltaPor: null,
        resueltaEn: null,
        motivoRechazo: null,
        creadoEn: serverTimestamp(),
      })
    );
  });

  it("create sin motivo o estado distinto de pendiente falla", async () => {
    const db = testEnv.authenticatedContext(miembroUid).firestore();
    await assertFails(
      setDoc(doc(db, `hogares/${hogarId}/correcciones/c2`), {
        movimientoId: "mov1",
        solicitanteUid: miembroUid,
        motivo: "",
        cambios: {monto: 50000},
        estado: "pendiente",
        creadoEn: serverTimestamp(),
      })
    );
    await assertFails(
      setDoc(doc(db, `hogares/${hogarId}/correcciones/c3`), {
        movimientoId: "mov1",
        solicitanteUid: miembroUid,
        motivo: "Ok",
        cambios: {monto: 50000},
        estado: "aprobada",
        creadoEn: serverTimestamp(),
      })
    );
  });

  it("update/delete de correcciones desde cliente falla", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `hogares/${hogarId}/correcciones/c4`), {
        movimientoId: "mov1",
        solicitanteUid: miembroUid,
        motivo: "X",
        cambios: {monto: 1},
        estado: "pendiente",
        creadoEn: serverTimestamp(),
      });
    });
    const adminDb = testEnv.authenticatedContext(adminUid).firestore();
    await assertFails(
      updateDoc(doc(adminDb, `hogares/${hogarId}/correcciones/c4`), {
        estado: "aprobada",
      })
    );
    await assertFails(
      deleteDoc(doc(adminDb, `hogares/${hogarId}/correcciones/c4`))
    );
  });

  it("miembro puede leer correcciones; ajeno no", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `hogares/${hogarId}/correcciones/c5`), {
        movimientoId: "mov1",
        solicitanteUid: miembroUid,
        motivo: "X",
        cambios: {monto: 1},
        estado: "pendiente",
        creadoEn: serverTimestamp(),
      });
    });
    const miembroDb = testEnv.authenticatedContext(miembroUid).firestore();
    await assertSucceeds(
      getDoc(doc(miembroDb, `hogares/${hogarId}/correcciones/c5`))
    );
    const ajenoDb = testEnv.authenticatedContext("uid-ajeno").firestore();
    await assertFails(
      getDoc(doc(ajenoDb, `hogares/${hogarId}/correcciones/c5`))
    );
  });
});
