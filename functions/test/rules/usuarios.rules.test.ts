import * as fs from "fs";
import * as path from "path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {deleteDoc, doc, getDoc, setDoc, updateDoc} from "firebase/firestore";

describe("Firestore Security Rules — Slice 1: usuarios/{uid}", () => {
  let testEnv: RulesTestEnvironment;

  beforeAll(async () => {
    const rulesPath = path.resolve(__dirname, "../../../firestore.rules");
    testEnv = await initializeTestEnvironment({
      projectId: "pato-donald-dev",
      firestore: {
        rules: fs.readFileSync(rulesPath, "utf8"),
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  afterAll(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  const datosUsuarioBase = {
    nombre: "Tío Rico",
    email: "rico@patodonald.co",
    hogarId: null,
    diaInicioPeriodo: 1,
    diaInicioPendiente: null,
    horaRecordatorio: null,
    fcmTokens: [],
    preferenciasAvisos: {
      alertasPresupuesto: true,
      recordatorioDiario: true,
      cuotas: true,
      correcciones: true,
      deudasInternas: true,
    },
    creadoEn: new Date(),
  };

  it("permite al usuario autenticado crear y leer su propio documento con hogarId == null", async () => {
    const db = testEnv.authenticatedContext("uid-1").firestore();
    const ref = doc(db, "usuarios/uid-1");

    await assertSucceeds(setDoc(ref, datosUsuarioBase));
    const snap = await assertSucceeds(getDoc(ref));
    expect(snap.exists()).toBe(true);
    expect(snap.data()?.nombre).toBe("Tío Rico");
    expect(snap.data()?.hogarId).toBeNull();
  });

  it("impide que un usuario lea o escriba el documento usuarios de otro", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "usuarios/uid-1"), datosUsuarioBase);
    });

    const dbOtro = testEnv.authenticatedContext("uid-2").firestore();
    const refUid1 = doc(dbOtro, "usuarios/uid-1");

    // No puede leer el de otro
    await assertFails(getDoc(refUid1));

    // No puede crear a nombre de otro
    await assertFails(
      setDoc(doc(dbOtro, "usuarios/uid-3"), datosUsuarioBase)
    );

    // No puede actualizar el de otro
    await assertFails(updateDoc(refUid1, {nombre: "Intruso"}));
  });

  it("impide que un usuario cree o actualice su propio hogarId", async () => {
    const db = testEnv.authenticatedContext("uid-1").firestore();
    const ref = doc(db, "usuarios/uid-1");

    // No puede crearse con hogarId distinto de null
    await assertFails(
      setDoc(ref, {
        ...datosUsuarioBase,
        hogarId: "hogar-secreto",
      })
    );

    // Lo crea válidamente con hogarId: null
    await assertSucceeds(setDoc(ref, datosUsuarioBase));

    // No puede actualizar su propio hogarId desde el cliente
    await assertFails(updateDoc(ref, {hogarId: "hogar-secreto"}));

    // Sí puede actualizar su propio nombre o diaInicioPeriodo válido (1-28)
    await assertSucceeds(
      updateDoc(ref, {nombre: "Donald Fauntleroy", diaInicioPeriodo: 15})
    );
  });

  it("impide diaInicioPeriodo fuera de [1, 28] y prohíbe borrar el documento", async () => {
    const db = testEnv.authenticatedContext("uid-1").firestore();
    const ref = doc(db, "usuarios/uid-1");

    await assertFails(
      setDoc(ref, {
        ...datosUsuarioBase,
        diaInicioPeriodo: 30,
      })
    );

    await assertSucceeds(setDoc(ref, datosUsuarioBase));
    await assertFails(deleteDoc(ref));
  });

  it("permite al dueño actualizar fcmTokens, horaRecordatorio y preferenciasAvisos", async () => {
    const db = testEnv.authenticatedContext("uid-1").firestore();
    const ref = doc(db, "usuarios/uid-1");
    await assertSucceeds(setDoc(ref, datosUsuarioBase));

    await assertSucceeds(
      updateDoc(ref, {
        fcmTokens: ["token-abc"],
        horaRecordatorio: "08:00",
        preferenciasAvisos: {
          ...datosUsuarioBase.preferenciasAvisos,
          recordatorioDiario: false,
        },
      })
    );
  });

  it("tras periodoConfigurado: true permite pedir diaInicioPendiente desde Perfil pero bloquea cambiar diaInicioPeriodo directo", async () => {
    const db = testEnv.authenticatedContext("uid-1").firestore();
    const ref = doc(db, "usuarios/uid-1");
    await assertSucceeds(setDoc(ref, datosUsuarioBase));

    // Configuración inicial permitida una sola vez
    await assertSucceeds(
      updateDoc(ref, {diaInicioPeriodo: 15, periodoConfigurado: true})
    );

    // Desde Perfil: pedir cambio vía diaInicioPendiente SÍ está permitido
    await assertSucceeds(updateDoc(ref, {diaInicioPendiente: 5}));
    await assertSucceeds(updateDoc(ref, {diaInicioPendiente: null}));

    // Cambiar diaInicioPeriodo directo tras configurar queda bloqueado
    await assertFails(updateDoc(ref, {diaInicioPeriodo: 5}));
    await assertFails(updateDoc(ref, {periodoConfigurado: false}));
  });
});
