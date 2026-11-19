import * as fs from "fs";
import * as path from "path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {doc, getDoc, setDoc, serverTimestamp, updateDoc} from "firebase/firestore";

describe("Slice 8 — Chat security rules", () => {
  let testEnv: RulesTestEnvironment;
  const hogarId = "hogar-chat-1";
  const uid = "uid-chat";
  const otro = "uid-otro";

  beforeAll(async () => {
    const rulesPath = path.resolve(__dirname, "../../../firestore.rules");
    testEnv = await initializeTestEnvironment({
      projectId: "pato-donald-dev-chat",
      firestore: {rules: fs.readFileSync(rulesPath, "utf8")},
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, `hogares/${hogarId}`), {nombre: "H", adminUid: uid});
      await setDoc(doc(db, `hogares/${hogarId}/miembros/${uid}`), {
        nombre: "U",
        rol: "admin",
        estado: "activo",
      });
      await setDoc(doc(db, `hogares/${hogarId}/miembros/${otro}`), {
        nombre: "O",
        rol: "miembro",
        estado: "activo",
      });
    });
  });

  it("dueño puede crear y leer sus mensajes", async () => {
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertSucceeds(
      setDoc(doc(db, `hogares/${hogarId}/chats/${uid}/mensajes/m1`), {
        rol: "usuario",
        texto: "gasté 10 mil",
        intencion: null,
        estado: "confirmado",
        fecha: serverTimestamp(),
      })
    );
    await assertSucceeds(
      getDoc(doc(db, `hogares/${hogarId}/chats/${uid}/mensajes/m1`))
    );
  });

  it("otro miembro no lee el chat ajeno", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/chats/${uid}/mensajes/m1`),
        {
          rol: "usuario",
          texto: "hola",
          estado: "confirmado",
          fecha: serverTimestamp(),
        }
      );
    });
    const db = testEnv.authenticatedContext(otro).firestore();
    await assertFails(
      getDoc(doc(db, `hogares/${hogarId}/chats/${uid}/mensajes/m1`))
    );
  });

  it("solo se puede actualizar estado", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(
        doc(ctx.firestore(), `hogares/${hogarId}/chats/${uid}/mensajes/m2`),
        {
          rol: "app",
          texto: "propuesta",
          estado: "propuesto",
          fecha: serverTimestamp(),
        }
      );
    });
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertSucceeds(
      updateDoc(doc(db, `hogares/${hogarId}/chats/${uid}/mensajes/m2`), {
        estado: "confirmado",
      })
    );
    await assertFails(
      updateDoc(doc(db, `hogares/${hogarId}/chats/${uid}/mensajes/m2`), {
        texto: "hack",
      })
    );
  });
});
