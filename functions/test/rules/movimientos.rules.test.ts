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
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from "firebase/firestore";
import {ejecutarAlEditarMovimiento, esEdicionMenor} from "../../src/movimientos";
import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

describe("Slice 3 — Movimientos security rules y alEditarMovimiento", () => {
  let testEnv: RulesTestEnvironment;
  const hogarId = "hogar-mov-1";
  const uid = "uid-donald";
  const uidOtro = "uid-daisy";

  async function seedMiembro(
    miembroUid: string,
    diaInicioPeriodo = 1
  ): Promise<void> {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, `usuarios/${miembroUid}`), {
        nombre: miembroUid,
        email: `${miembroUid}@pato.co`,
        hogarId,
        diaInicioPeriodo,
      });
      await setDoc(doc(db, `hogares/${hogarId}`), {
        nombre: "Familia Pato",
        adminUid: uid,
      });
      await setDoc(doc(db, `hogares/${hogarId}/miembros/${miembroUid}`), {
        nombre: miembroUid,
        rol: miembroUid === uid ? "admin" : "miembro",
        estado: "activo",
        unidoEn: Timestamp.now(),
      });
    });
  }

  function movimientoBase(
    overrides: Record<string, unknown> = {}
  ): Record<string, unknown> {
    // fecha ≈ ahora del emulador; creadoEn debe ser serverTimestamp (== request.time).
    const ahora = Timestamp.now();
    return {
      tipo: "gasto",
      monto: 15000,
      categoria: "alimentacion",
      deudaId: null,
      gastoFijoId: null,
      fecha: ahora,
      periodoId: "2026-11-01",
      uid,
      nota: "",
      fotoPath: null,
      origen: "formulario",
      estado: "activo",
      creadoEn: serverTimestamp(),
      editadoEn: null,
      saldoAplicado: false,
      ...overrides,
    };
  }

  beforeAll(async () => {
    const rulesPath = path.resolve(__dirname, "../../../firestore.rules");
    testEnv = await initializeTestEnvironment({
      projectId: "pato-donald-dev-mov",
      firestore: {
        rules: fs.readFileSync(rulesPath, "utf8"),
      },
    });
    if (getApps().length === 0) {
      initializeApp({projectId: "pato-donald-dev-mov"});
    }
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    await seedMiembro(uid, 1);
    await seedMiembro(uidOtro, 1);
  });

  afterAll(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  it("create ok: miembro activo crea su propio gasto del período", async () => {
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertSucceeds(
      setDoc(
        doc(db, `hogares/${hogarId}/movimientos/m-ok`),
        movimientoBase()
      )
    );
  });

  it("create fail: uid distinto al autenticado", async () => {
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertFails(
      setDoc(
        doc(db, `hogares/${hogarId}/movimientos/m-otro-uid`),
        movimientoBase({uid: uidOtro})
      )
    );
  });

  it("create fail: periodoId con día distinto a diaInicioPeriodo", async () => {
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertFails(
      setDoc(
        doc(db, `hogares/${hogarId}/movimientos/m-periodo`),
        movimientoBase({periodoId: "2026-11-15"})
      )
    );
  });

  it("delete fail: no se pueden borrar movimientos", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/movimientos/m-del`),
        movimientoBase()
      );
    });
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertFails(
      deleteDoc(doc(db, `hogares/${hogarId}/movimientos/m-del`))
    );
  });

  it("update ok: edición menor de nota dentro de 24 h", async () => {
    const creadoEn = Timestamp.now();
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/movimientos/m-edit`),
        movimientoBase({creadoEn, fecha: creadoEn})
      );
    });
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertSucceeds(
      updateDoc(doc(db, `hogares/${hogarId}/movimientos/m-edit`), {
        nota: "Mercado del domingo",
        editadoEn: serverTimestamp(),
      })
    );
  });

  it("update fail: edición a las 25 h desde creadoEn", async () => {
    const hace25h = Timestamp.fromMillis(Date.now() - 25 * 60 * 60 * 1000);
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/movimientos/m-25h`),
        movimientoBase({creadoEn: hace25h, fecha: hace25h})
      );
    });
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertFails(
      updateDoc(doc(db, `hogares/${hogarId}/movimientos/m-25h`), {
        nota: "Demasiado tarde",
        editadoEn: serverTimestamp(),
      })
    );
  });

  it("gastosFijos: create/update/delete propio uid", async () => {
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertSucceeds(
      setDoc(doc(db, `hogares/${hogarId}/gastosFijos/gf1`), {
        uid,
        nombre: "Arriendo",
        monto: 1200000,
        categoria: "vivienda",
        diaEsperado: 5,
        activo: true,
      })
    );
    await assertSucceeds(
      updateDoc(doc(db, `hogares/${hogarId}/gastosFijos/gf1`), {
        monto: 1250000,
      })
    );
    await assertSucceeds(
      deleteDoc(doc(db, `hogares/${hogarId}/gastosFijos/gf1`))
    );
  });

  it("gastosFijos: no puede borrar el de otro", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `hogares/${hogarId}/gastosFijos/gf2`), {
        uid: uidOtro,
        nombre: "Netflix",
        monto: 40000,
        categoria: "ocio",
        diaEsperado: 10,
        activo: true,
      });
    });
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertFails(
      deleteDoc(doc(db, `hogares/${hogarId}/gastosFijos/gf2`))
    );
  });

  describe("alEditarMovimiento / esEdicionMenor", () => {
    it("detecta edición menor y escribe auditoría", async () => {
      expect(
        esEdicionMenor(
          {nota: "", categoria: "alimentacion", monto: 100},
          {nota: "hola", categoria: "alimentacion", monto: 100}
        )
      ).toBe(true);

      expect(
        esEdicionMenor(
          {nota: "", monto: 100},
          {nota: "", monto: 200}
        )
      ).toBe(false);

      const adminDb = getFirestore();
      const res = await ejecutarAlEditarMovimiento(
        adminDb,
        hogarId,
        "m-aud",
        {nota: "", categoria: "ocio", uid},
        {nota: "capricho", categoria: "ocio", uid}
      );
      expect(res.escrito).toBe(true);

      const snaps = await adminDb
        .collection("hogares")
        .doc(hogarId)
        .collection("auditoria")
        .get();
      expect(snaps.size).toBeGreaterThanOrEqual(1);
      const docAud = snaps.docs[snaps.docs.length - 1].data();
      expect(docAud.accion).toBe("edicionMenor");
      expect(docAud.movimientoId).toBe("m-aud");
    });
  });
});
