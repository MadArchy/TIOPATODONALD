import {Firestore, FieldValue, Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {periodoDe, componentesBogota} from "./periodo";

export interface CambiarPresupuestoInput {
  hogarId: string;
  monto: number;
}

export interface CambiarPresupuestoResult {
  presupuestoId: string;
  periodoId: string;
  montoAnterior: number | null;
  montoNuevo: number;
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
 * Actualiza el presupuesto del período vigente y escribe auditoría
 * `cambioPresupuesto` (solo servidor).
 */
export async function ejecutarCambiarPresupuesto(
  db: Firestore,
  uid: string | undefined,
  input: CambiarPresupuestoInput,
  now: Date = new Date()
): Promise<CambiarPresupuestoResult> {
  const authUid = exigirUid(uid);
  const hogarId = (input?.hogarId ?? "").trim();
  const monto = input?.monto;

  if (!hogarId) {
    throw new HttpsError("invalid-argument", "Falta el identificador del hogar.");
  }
  if (typeof monto !== "number" || !Number.isInteger(monto) || monto <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "Escribe un presupuesto entero mayor a $0."
    );
  }

  const usuarioRef = db.collection("usuarios").doc(authUid);
  const miembroRef = db
    .collection("hogares")
    .doc(hogarId)
    .collection("miembros")
    .doc(authUid);

  const usuarioSnap = await usuarioRef.get();
  if (!usuarioSnap.exists) {
    throw new HttpsError("not-found", "No encontramos tu perfil.");
  }
  const usuarioData = usuarioSnap.data()!;
  if (usuarioData.hogarId !== hogarId) {
    throw new HttpsError(
      "permission-denied",
      "No perteneces a este hogar."
    );
  }

  const miembroSnap = await miembroRef.get();
  if (!miembroSnap.exists || miembroSnap.data()?.estado !== "activo") {
    throw new HttpsError(
      "permission-denied",
      "Ya no eres miembro activo de este hogar."
    );
  }

  const diaInicio =
    typeof usuarioData.diaInicioPeriodo === "number"
      ? usuarioData.diaInicioPeriodo
      : 1;
  const periodo = periodoDe(now, diaInicio);
  const presupuestoId = `${authUid}_${periodo.periodoId}`;
  const presupuestoRef = db
    .collection("hogares")
    .doc(hogarId)
    .collection("presupuestos")
    .doc(presupuestoId);
  const auditoriaRef = db
    .collection("hogares")
    .doc(hogarId)
    .collection("auditoria")
    .doc();

  let montoAnterior: number | null = null;

  await db.runTransaction(async (tx) => {
    const prepSnap = await tx.get(presupuestoRef);
    if (prepSnap.exists) {
      const prev = prepSnap.data()?.monto;
      montoAnterior = typeof prev === "number" ? prev : null;
    }

    if (prepSnap.exists) {
      tx.update(presupuestoRef, {
        monto,
        actualizadoEn: FieldValue.serverTimestamp(),
      });
    } else {
      tx.set(presupuestoRef, {
        uid: authUid,
        periodoId: periodo.periodoId,
        monto,
        alertasEnviadas: [],
        actualizadoEn: FieldValue.serverTimestamp(),
      });
    }

    tx.set(auditoriaRef, {
      movimientoId: null,
      accion: "cambioPresupuesto",
      antes: {monto: montoAnterior},
      despues: {monto, periodoId: periodo.periodoId},
      porUid: authUid,
      aprobadoPor: null,
      fecha: FieldValue.serverTimestamp(),
    });
  });

  return {
    presupuestoId,
    periodoId: periodo.periodoId,
    montoAnterior,
    montoNuevo: monto,
  };
}

/**
 * Marca umbrales de alerta en el presupuesto (cliente o Function).
 * Expuesto como helper puro para tests; la app escribe alertasEnviadas directo.
 */
export function umbralesAlcanzados(
  gastado: number,
  presupuesto: number,
  yaEnviadas: number[]
): number[] {
  if (presupuesto <= 0) return [];
  const ratio = (gastado / presupuesto) * 100;
  const set = new Set(yaEnviadas);
  const nuevas: number[] = [];
  for (const u of [50, 80, 100]) {
    if (set.has(u)) continue;
    if (ratio >= u) nuevas.push(u);
  }
  return nuevas;
}

/** Fecha legible para logs: componentes Bogotá. */
export function etiquetaAhoraBogota(now: Date = new Date()): string {
  const c = componentesBogota(now);
  return `${c.year}-${String(c.month).padStart(2, "0")}-${String(c.day).padStart(2, "0")}`;
}

export {Timestamp};
