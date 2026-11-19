import * as fs from "fs";
import * as path from "path";
import {
  assertFails,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {doc, getDoc, setDoc} from "firebase/firestore";

describe("Firestore Security Rules — Slice 0 (niega todo)", () => {
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

  afterAll(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  it("niega lectura y escritura a usuarios no autenticados", async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(unauthedDb, "usuarios/u1")));
    await assertFails(
      setDoc(doc(unauthedDb, "usuarios/u1"), {nombre: "Donald"})
    );
  });

  it("niega lectura y escritura a colecciones aún cerradas incluso a usuarios autenticados", async () => {
    const authedDb = testEnv.authenticatedContext("u1").firestore();
    await assertFails(getDoc(doc(authedDb, "hogares/h1")));
    await assertFails(
      setDoc(doc(authedDb, "hogares/h1/movimientos/m1"), {monto: 10000})
    );
  });
});
