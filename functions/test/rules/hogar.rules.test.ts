import * as fs from "fs";
import * as path from "path";
import {getApps, initializeApp} from "firebase-admin/app";
import {Firestore, getFirestore} from "firebase-admin/firestore";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {deleteDoc, doc, getDoc, setDoc, updateDoc} from "firebase/firestore";
import {
  DURACION_INVITACION_MS,
  ejecutarCrearHogar,
  ejecutarGenerarInvitacion,
  ejecutarSacarMiembro,
  ejecutarUnirseConCodigo,
} from "../../src/hogar";

describe("Slice 2 — Hogar, QR, Security Rules y Cloud Functions", () => {
  let testEnv: RulesTestEnvironment;
  let adminDb: Firestore;

  beforeAll(async () => {
    const rulesPath = path.resolve(__dirname, "../../../firestore.rules");
    testEnv = await initializeTestEnvironment({
      projectId: "pato-donald-dev",
      firestore: {
        rules: fs.readFileSync(rulesPath, "utf8"),
      },
    });

    if (getApps().length === 0) {
      initializeApp({projectId: "pato-donald-dev"});
    }
    adminDb = getFirestore();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  afterAll(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  describe("Cloud Functions: crearHogar, generarInvitacion, unirseConCodigo, sacarMiembro", () => {
    it("flujo feliz: admin crea hogar, genera QR y otro miembro se une", async () => {
      const t0 = new Date("2026-11-18T14:00:00.000Z");

      // Usuarios iniciales sin hogar
      await adminDb.collection("usuarios").doc("admin-1").set({
        nombre: "Donald",
        email: "donald@pato.co",
        hogarId: null,
        diaInicioPeriodo: 1,
      });
      await adminDb.collection("usuarios").doc("miembro-2").set({
        nombre: "Daisy",
        email: "daisy@pato.co",
        hogarId: null,
        diaInicioPeriodo: 1,
      });

      // 1. Admin crea el hogar
      const hogarCreado = await ejecutarCrearHogar(
        adminDb,
        "admin-1",
        {nombre: "Familia Pato"},
        t0
      );
      expect(hogarCreado.nombre).toBe("Familia Pato");
      expect(hogarCreado.adminUid).toBe("admin-1");

      const adminUserSnap = await adminDb.collection("usuarios").doc("admin-1").get();
      expect(adminUserSnap.data()?.hogarId).toBe(hogarCreado.hogarId);

      // 2. Admin genera invitación QR
      const inv = await ejecutarGenerarInvitacion(
        adminDb,
        "admin-1",
        {hogarId: hogarCreado.hogarId},
        t0
      );
      expect(inv.codigo.length).toBeGreaterThanOrEqual(16);
      expect(inv.qrUrl).toContain("patodonald://unirse?h=");

      // 3. Segundo usuario se une 1 hora después (< 4 horas)
      const t1 = new Date(t0.getTime() + 60 * 60 * 1000);
      const unido = await ejecutarUnirseConCodigo(
        adminDb,
        "miembro-2",
        {hogarId: hogarCreado.hogarId, codigo: inv.codigo},
        t1
      );
      expect(unido.hogarId).toBe(hogarCreado.hogarId);
      expect(unido.nombreHogar).toBe("Familia Pato");

      const miembro2UserSnap = await adminDb.collection("usuarios").doc("miembro-2").get();
      expect(miembro2UserSnap.data()?.hogarId).toBe(hogarCreado.hogarId);

      const miembroDoc = await adminDb
        .collection("hogares")
        .doc(hogarCreado.hogarId)
        .collection("miembros")
        .doc("miembro-2")
        .get();
      expect(miembroDoc.data()?.rol).toBe("miembro");
      expect(miembroDoc.data()?.estado).toBe("activo");
    });

    it("rechaza QR vencido (+4 h) o reemplazado por uno nuevo", async () => {
      const t0 = new Date("2026-11-18T14:00:00.000Z");
      const hogar = await ejecutarCrearHogar(
        adminDb,
        "admin-1",
        {nombre: "Casa Pato"},
        t0
      );

      const inv1 = await ejecutarGenerarInvitacion(
        adminDb,
        "admin-1",
        {hogarId: hogar.hogarId},
        t0
      );

      // Caso A: QR vencido a las 4 horas + 1 segundo (reloj simulado)
      const tVencido = new Date(t0.getTime() + DURACION_INVITACION_MS + 1000);
      await expect(
        ejecutarUnirseConCodigo(
          adminDb,
          "miembro-vencido",
          {hogarId: hogar.hogarId, codigo: inv1.codigo},
          tVencido
        )
      ).rejects.toThrow(/venció o fue reemplazado/);

      // Caso B: Admin genera uno nuevo -> el anterior queda inactivo
      const inv2 = await ejecutarGenerarInvitacion(
        adminDb,
        "admin-1",
        {hogarId: hogar.hogarId},
        t0
      );

      await expect(
        ejecutarUnirseConCodigo(
          adminDb,
          "miembro-viejo-qr",
          {hogarId: hogar.hogarId, codigo: inv1.codigo},
          t0
        )
      ).rejects.toThrow(/venció o fue reemplazado/);

      // El nuevo sí funciona
      const ok = await ejecutarUnirseConCodigo(
        adminDb,
        "miembro-nuevo-qr",
        {hogarId: hogar.hogarId, codigo: inv2.codigo},
        t0
      );
      expect(ok.hogarId).toBe(hogar.hogarId);
    });

    it("rechaza con 'Ya perteneces a un hogar' si usuario con hogar intenta crear o unirse a otro", async () => {
      const t0 = new Date("2026-11-18T14:00:00.000Z");
      const hogarA = await ejecutarCrearHogar(
        adminDb,
        "admin-a",
        {nombre: "Hogar A"},
        t0
      );
      const hogarB = await ejecutarCrearHogar(
        adminDb,
        "admin-b",
        {nombre: "Hogar B"},
        t0
      );
      const invB = await ejecutarGenerarInvitacion(
        adminDb,
        "admin-b",
        {hogarId: hogarB.hogarId},
        t0
      );

      expect(hogarA.hogarId).toBeTruthy();

      // Admin A ya tiene hogar, no puede crear otro
      await expect(
        ejecutarCrearHogar(adminDb, "admin-a", {nombre: "Hogar Extra"}, t0)
      ).rejects.toThrow("Ya perteneces a un hogar.");

      // Admin A ya tiene hogar, no puede unirse al Hogar B con QR
      await expect(
        ejecutarUnirseConCodigo(
          adminDb,
          "admin-a",
          {hogarId: hogarB.hogarId, codigo: invB.codigo},
          t0
        )
      ).rejects.toThrow("Ya perteneces a un hogar.");
    });

    it("impide que un miembro no-admin invite o saque miembros, y que el admin se saque a sí mismo", async () => {
      const t0 = new Date("2026-11-18T14:00:00.000Z");
      const hogar = await ejecutarCrearHogar(
        adminDb,
        "admin-1",
        {nombre: "Hogar Pato"},
        t0
      );
      const inv = await ejecutarGenerarInvitacion(
        adminDb,
        "admin-1",
        {hogarId: hogar.hogarId},
        t0
      );
      await ejecutarUnirseConCodigo(
        adminDb,
        "miembro-2",
        {hogarId: hogar.hogarId, codigo: inv.codigo},
        t0
      );

      // Miembro normal no puede generar invitación
      await expect(
        ejecutarGenerarInvitacion(
          adminDb,
          "miembro-2",
          {hogarId: hogar.hogarId},
          t0
        )
      ).rejects.toThrow(/Solo el administrador/);

      // Miembro normal no puede sacar a nadie
      await expect(
        ejecutarSacarMiembro(
          adminDb,
          "miembro-2",
          {hogarId: hogar.hogarId, miembroUid: "admin-1"},
          t0
        )
      ).rejects.toThrow(/Solo el administrador/);

      // Admin no puede sacarse a sí mismo
      await expect(
        ejecutarSacarMiembro(
          adminDb,
          "admin-1",
          {hogarId: hogar.hogarId, miembroUid: "admin-1"},
          t0
        )
      ).rejects.toThrow(/no puede sacarse a sí mismo/);
    });
  });

  describe("Security Rules: acceso de miembros activos y revocación inmediata al sacar", () => {
    it("miembro activo puede leer hogar y miembros, guardar su presupuesto; al ser sacado pierde acceso de inmediato", async () => {
      const t0 = new Date("2026-11-18T14:00:00.000Z");
      const hogar = await ejecutarCrearHogar(
        adminDb,
        "admin-1",
        {nombre: "Hogar Pato"},
        t0
      );
      const inv = await ejecutarGenerarInvitacion(
        adminDb,
        "admin-1",
        {hogarId: hogar.hogarId},
        t0
      );
      await ejecutarUnirseConCodigo(
        adminDb,
        "miembro-2",
        {hogarId: hogar.hogarId, codigo: inv.codigo},
        t0
      );

      const dbAdmin = testEnv.authenticatedContext("admin-1").firestore();
      const dbMiembro = testEnv.authenticatedContext("miembro-2").firestore();
      const dbExterno = testEnv.authenticatedContext("externo-9").firestore();

      // 1. Miembro activo puede leer hogar y lista de miembros
      await assertSucceeds(getDoc(doc(dbMiembro, `hogares/${hogar.hogarId}`)));
      await assertSucceeds(
        getDoc(doc(dbMiembro, `hogares/${hogar.hogarId}/miembros/admin-1`))
      );

      // 2. Usuario externo no puede leer el hogar
      await assertFails(getDoc(doc(dbExterno, `hogares/${hogar.hogarId}`)));

      // 3. Invitaciones: solo el admin las puede leer, un miembro normal no
      await assertSucceeds(
        getDoc(
          doc(dbAdmin, `hogares/${hogar.hogarId}/invitaciones/${inv.invitacionId}`)
        )
      );
      await assertFails(
        getDoc(
          doc(dbMiembro, `hogares/${hogar.hogarId}/invitaciones/${inv.invitacionId}`)
        )
      );

      // 4. Ningún cliente puede escribir directamente en hogares, miembros o invitaciones
      await assertFails(
        updateDoc(doc(dbAdmin, `hogares/${hogar.hogarId}`), {nombre: "Hack"})
      );
      await assertFails(
        setDoc(doc(dbAdmin, `hogares/${hogar.hogarId}/miembros/otro`), {
          nombre: "Hack",
          rol: "miembro",
          estado: "activo",
        })
      );

      // 5. Presupuestos: miembro activo puede crear su propio presupuesto (monto int > 0)
      await assertSucceeds(
        setDoc(
          doc(
            dbMiembro,
            `hogares/${hogar.hogarId}/presupuestos/miembro-2_2026-11-01`
          ),
          {
            uid: "miembro-2",
            periodoId: "2026-11-01",
            monto: 2500000,
            alertasEnviadas: [],
            actualizadoEn: t0,
          }
        )
      );

      // No puede crear el presupuesto de otro usuario ni con monto <= 0
      await assertFails(
        setDoc(
          doc(
            dbMiembro,
            `hogares/${hogar.hogarId}/presupuestos/admin-1_2026-11-01`
          ),
          {
            uid: "admin-1",
            periodoId: "2026-11-01",
            monto: 2500000,
            alertasEnviadas: [],
            actualizadoEn: t0,
          }
        )
      );
      await assertFails(
        setDoc(
          doc(
            dbMiembro,
            `hogares/${hogar.hogarId}/presupuestos/miembro-2_2026-12-01`
          ),
          {
            uid: "miembro-2",
            periodoId: "2026-12-01",
            monto: 0,
            alertasEnviadas: [],
            actualizadoEn: t0,
          }
        )
      );
      await assertFails(
        updateDoc(
          doc(
            dbMiembro,
            `hogares/${hogar.hogarId}/presupuestos/miembro-2_2026-11-01`
          ),
          {monto: 3000000}
        )
      );
      await assertFails(
        deleteDoc(
          doc(
            dbMiembro,
            `hogares/${hogar.hogarId}/presupuestos/miembro-2_2026-11-01`
          )
        )
      );

      // 6. Admin saca a miembro-2 -> miembro-2 queda 'retirado' y pierde acceso DE INMEDIATO
      await ejecutarSacarMiembro(
        adminDb,
        "admin-1",
        {hogarId: hogar.hogarId, miembroUid: "miembro-2"},
        t0
      );

      const usuarioSacado = await adminDb.collection("usuarios").doc("miembro-2").get();
      expect(usuarioSacado.data()?.hogarId).toBeNull();

      // Ya no puede leer hogar, miembros ni presupuestos, ni actualizar su presupuesto anterior
      await assertFails(getDoc(doc(dbMiembro, `hogares/${hogar.hogarId}`)));
      await assertFails(
        getDoc(doc(dbMiembro, `hogares/${hogar.hogarId}/miembros/admin-1`))
      );
      await assertFails(
        getDoc(
          doc(
            dbMiembro,
            `hogares/${hogar.hogarId}/presupuestos/miembro-2_2026-11-01`
          )
        )
      );
      await assertFails(
        updateDoc(
          doc(
            dbMiembro,
            `hogares/${hogar.hogarId}/presupuestos/miembro-2_2026-11-01`
          ),
          {monto: 3000000}
        )
      );
    });
  });
});
