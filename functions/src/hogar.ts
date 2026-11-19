import * as crypto from "crypto";
import {Firestore, Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";

export const DURACION_INVITACION_MS = 4 * 60 * 60 * 1000; // 4 horas

export interface CrearHogarInput {
  nombre: string;
}

export interface CrearHogarResult {
  hogarId: string;
  nombre: string;
  adminUid: string;
}

export interface GenerarInvitacionInput {
  hogarId: string;
}

export interface GenerarInvitacionResult {
  invitacionId: string;
  hogarId: string;
  codigo: string;
  qrUrl: string;
  expiraEnIso: string;
}

export interface UnirseConCodigoInput {
  hogarId: string;
  codigo: string;
}

export interface UnirseConCodigoResult {
  hogarId: string;
  nombreHogar: string;
}

export interface SacarMiembroInput {
  hogarId: string;
  miembroUid: string;
}

export interface SacarMiembroResult {
  hogarId: string;
  miembroUid: string;
  estado: "retirado";
}

function exigirUid(uid?: string): string {
  if (!uid || uid.trim().length === 0) {
    throw new HttpsError(
      "unauthenticated",
      "Debes iniciar sesión para realizar esta acción."
    );
  }
  return uid;
}

/**
 * Crea un hogar nuevo, registra al creador como miembro admin activo
 * y asigna `usuarios/{uid}.hogarId` en una transacción.
 */
export async function ejecutarCrearHogar(
  db: Firestore,
  uid: string | undefined,
  input: CrearHogarInput,
  now: Date = new Date()
): Promise<CrearHogarResult> {
  const authUid = exigirUid(uid);
  const nombre = (input?.nombre ?? "").trim();

  if (nombre.length < 2) {
    throw new HttpsError(
      "invalid-argument",
      "Escribe un nombre para el hogar (mínimo 2 letras)."
    );
  }

  const usuarioRef = db.collection("usuarios").doc(authUid);
  const hogarRef = db.collection("hogares").doc();
  const miembroRef = hogarRef.collection("miembros").doc(authUid);
  const tsAhora = Timestamp.fromDate(now);

  await db.runTransaction(async (tx) => {
    const usuarioSnap = await tx.get(usuarioRef);
    const datosUsuario = usuarioSnap.data();

    if (datosUsuario?.hogarId) {
      throw new HttpsError(
        "failed-precondition",
        "Ya perteneces a un hogar."
      );
    }

    const nombreUsuario =
      typeof datosUsuario?.nombre === "string" &&
      datosUsuario.nombre.trim().length > 0
        ? datosUsuario.nombre.trim()
        : "Administrador";

    tx.set(hogarRef, {
      nombre,
      adminUid: authUid,
      ia: {
        activa: false,
        proveedor: "",
        modelo: "",
        limiteMensual: 0,
      },
      creadoEn: tsAhora,
    });

    tx.set(miembroRef, {
      nombre: nombreUsuario,
      rol: "admin",
      estado: "activo",
      unidoEn: tsAhora,
      retiradoEn: null,
    });

    if (usuarioSnap.exists) {
      tx.update(usuarioRef, {hogarId: hogarRef.id});
    } else {
      tx.set(usuarioRef, {
        nombre: nombreUsuario,
        email: "",
        hogarId: hogarRef.id,
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
        creadoEn: tsAhora,
      });
    }
  });

  return {
    hogarId: hogarRef.id,
    nombre,
    adminUid: authUid,
  };
}

/**
 * Genera una invitación por QR válida por 4 horas y desactiva cualquier
 * invitación activa anterior del hogar. Solo el admin puede llamarla.
 */
export async function ejecutarGenerarInvitacion(
  db: Firestore,
  uid: string | undefined,
  input: GenerarInvitacionInput,
  now: Date = new Date()
): Promise<GenerarInvitacionResult> {
  const authUid = exigirUid(uid);
  const hogarId = (input?.hogarId ?? "").trim();

  if (!hogarId) {
    throw new HttpsError("invalid-argument", "Falta el identificador del hogar.");
  }

  const hogarRef = db.collection("hogares").doc(hogarId);
  const invitacionesCol = hogarRef.collection("invitaciones");
  const nuevaInvRef = invitacionesCol.doc();

  // Código aleatorio criptográfico >= 16 caracteres (24 hex chars)
  const codigo = crypto.randomBytes(12).toString("hex");
  const expiraDate = new Date(now.getTime() + DURACION_INVITACION_MS);
  const tsAhora = Timestamp.fromDate(now);
  const tsExpira = Timestamp.fromDate(expiraDate);

  await db.runTransaction(async (tx) => {
    const hogarSnap = await tx.get(hogarRef);
    if (!hogarSnap.exists) {
      throw new HttpsError("not-found", "El hogar no existe.");
    }

    const hogarData = hogarSnap.data()!;
    if (hogarData.adminUid !== authUid) {
      throw new HttpsError(
        "permission-denied",
        "Solo el administrador del hogar puede generar códigos QR."
      );
    }

    const activasQuery = invitacionesCol.where("activa", "==", true);
    const activasSnap = await tx.get(activasQuery);

    for (const docSnap of activasSnap.docs) {
      tx.update(docSnap.ref, {activa: false});
    }

    tx.set(nuevaInvRef, {
      codigo,
      creadaPor: authUid,
      creadaEn: tsAhora,
      expiraEn: tsExpira,
      activa: true,
    });
  });

  const qrUrl = `patodonald://unirse?h=${encodeURIComponent(
    hogarId
  )}&c=${encodeURIComponent(codigo)}`;

  return {
    invitacionId: nuevaInvRef.id,
    hogarId,
    codigo,
    qrUrl,
    expiraEnIso: expiraDate.toISOString(),
  };
}

/**
 * Une al usuario autenticado a un hogar validando que no pertenezca ya a un hogar
 * y que el código QR esté activo y no haya vencido (+4 h).
 */
export async function ejecutarUnirseConCodigo(
  db: Firestore,
  uid: string | undefined,
  input: UnirseConCodigoInput,
  now: Date = new Date()
): Promise<UnirseConCodigoResult> {
  const authUid = exigirUid(uid);
  const hogarId = (input?.hogarId ?? "").trim();
  const codigo = (input?.codigo ?? "").trim();

  if (!hogarId || !codigo) {
    throw new HttpsError(
      "invalid-argument",
      "El código QR no es válido. Intenta escanearlo de nuevo."
    );
  }

  const usuarioRef = db.collection("usuarios").doc(authUid);
  const hogarRef = db.collection("hogares").doc(hogarId);
  const miembroRef = hogarRef.collection("miembros").doc(authUid);
  const invQuery = hogarRef
    .collection("invitaciones")
    .where("codigo", "==", codigo)
    .limit(1);

  const tsAhora = Timestamp.fromDate(now);
  let nombreHogar = "";

  await db.runTransaction(async (tx) => {
    const usuarioSnap = await tx.get(usuarioRef);
    const datosUsuario = usuarioSnap.data();

    if (datosUsuario?.hogarId) {
      throw new HttpsError(
        "failed-precondition",
        "Ya perteneces a un hogar."
      );
    }

    const hogarSnap = await tx.get(hogarRef);
    if (!hogarSnap.exists) {
      throw new HttpsError("not-found", "El hogar de la invitación no existe.");
    }
    nombreHogar = String(hogarSnap.data()?.nombre ?? "Hogar");

    const invSnap = await tx.get(invQuery);
    if (invSnap.empty) {
      throw new HttpsError(
        "not-found",
        "El código QR no es válido. Pídele al administrador uno nuevo."
      );
    }

    const invDoc = invSnap.docs[0];
    const invData = invDoc.data();
    const expiraEn: Timestamp | undefined = invData.expiraEn;
    const vencida =
      !expiraEn || expiraEn.toMillis() < now.getTime();

    if (invData.activa !== true || vencida) {
      throw new HttpsError(
        "failed-precondition",
        "El código QR venció o fue reemplazado. Pídele al administrador uno nuevo."
      );
    }

    const nombreUsuario =
      typeof datosUsuario?.nombre === "string" &&
      datosUsuario.nombre.trim().length > 0
        ? datosUsuario.nombre.trim()
        : "Miembro";

    tx.set(miembroRef, {
      nombre: nombreUsuario,
      rol: "miembro",
      estado: "activo",
      unidoEn: tsAhora,
      retiradoEn: null,
    });

    if (usuarioSnap.exists) {
      tx.update(usuarioRef, {hogarId});
    } else {
      tx.set(usuarioRef, {
        nombre: nombreUsuario,
        email: "",
        hogarId,
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
        creadoEn: tsAhora,
      });
    }
  });

  return {
    hogarId,
    nombreHogar,
  };
}

/**
 * Retira a un miembro del hogar (`estado: 'retirado'`, `usuarios.hogarId = null`).
 * Solo el admin puede llamarla y no puede sacarse a sí mismo.
 */
export async function ejecutarSacarMiembro(
  db: Firestore,
  uid: string | undefined,
  input: SacarMiembroInput,
  now: Date = new Date()
): Promise<SacarMiembroResult> {
  const authUid = exigirUid(uid);
  const hogarId = (input?.hogarId ?? "").trim();
  const miembroUid = (input?.miembroUid ?? "").trim();

  if (!hogarId || !miembroUid) {
    throw new HttpsError(
      "invalid-argument",
      "Faltan los datos del miembro o del hogar."
    );
  }

  const hogarRef = db.collection("hogares").doc(hogarId);
  const miembroRef = hogarRef.collection("miembros").doc(miembroUid);
  const usuarioMiembroRef = db.collection("usuarios").doc(miembroUid);
  const tsAhora = Timestamp.fromDate(now);

  await db.runTransaction(async (tx) => {
    const hogarSnap = await tx.get(hogarRef);
    if (!hogarSnap.exists) {
      throw new HttpsError("not-found", "El hogar no existe.");
    }

    const hogarData = hogarSnap.data()!;
    if (hogarData.adminUid !== authUid) {
      throw new HttpsError(
        "permission-denied",
        "Solo el administrador puede sacar miembros del hogar."
      );
    }

    if (miembroUid === authUid || miembroUid === hogarData.adminUid) {
      throw new HttpsError(
        "failed-precondition",
        "El administrador no puede sacarse a sí mismo del hogar."
      );
    }

    const miembroSnap = await tx.get(miembroRef);
    if (!miembroSnap.exists) {
      throw new HttpsError("not-found", "El miembro no pertenece a este hogar.");
    }

    const usuarioSnap = await tx.get(usuarioMiembroRef);

    tx.update(miembroRef, {
      estado: "retirado",
      retiradoEn: tsAhora,
    });

    if (usuarioSnap.exists && usuarioSnap.data()?.hogarId === hogarId) {
      tx.update(usuarioMiembroRef, {hogarId: null});
    }
  });

  return {
    hogarId,
    miembroUid,
    estado: "retirado",
  };
}
