import {Firestore, FieldValue} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";

export interface ConfirmarPagoInternoInput {
  hogarId: string;
  deudaInternaId: string;
  pagoId: string;
}

export interface ConfirmarPagoInternoResult {
  saldo: number;
  estado: string;
  yaConfirmado: boolean;
}

export interface ResultadoConfirmacionPagoInterno {
  aplicar: boolean;
  nuevoSaldo: number;
  nuevoEstado: string;
  motivo?: string;
}

/**
 * Lógica pura: baja saldo por monto del pago; en 0 → pagada.
 * Idempotente si el pago ya estaba confirmado.
 */
export function calcularConfirmacionPagoInterno(params: {
  yaConfirmado: boolean;
  saldoActual: number;
  montoPago: number;
  estadoActual: string;
}): ResultadoConfirmacionPagoInterno {
  if (params.yaConfirmado) {
    return {
      aplicar: false,
      nuevoSaldo: params.saldoActual,
      nuevoEstado: params.estadoActual,
      motivo: "ya_confirmado",
    };
  }
  const monto = Math.max(0, Math.trunc(params.montoPago));
  const nuevoSaldo = Math.max(0, Math.trunc(params.saldoActual) - monto);
  const nuevoEstado =
    nuevoSaldo === 0 ? "pagada" : params.estadoActual || "aceptada";
  return {
    aplicar: true,
    nuevoSaldo,
    nuevoEstado,
  };
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
 * Acreedor confirma un pago interno: marca confirmado, baja saldo, cierra en 0.
 */
export async function ejecutarConfirmarPagoInterno(
  db: Firestore,
  uid: string | undefined,
  input: ConfirmarPagoInternoInput
): Promise<ConfirmarPagoInternoResult> {
  const authUid = exigirUid(uid);
  const hogarId = (input?.hogarId ?? "").trim();
  const deudaInternaId = (input?.deudaInternaId ?? "").trim();
  const pagoId = (input?.pagoId ?? "").trim();

  if (!hogarId || !deudaInternaId || !pagoId) {
    throw new HttpsError(
      "invalid-argument",
      "Faltan datos para confirmar el pago."
    );
  }

  const miembroRef = db
    .collection("hogares")
    .doc(hogarId)
    .collection("miembros")
    .doc(authUid);
  const deudaRef = db
    .collection("hogares")
    .doc(hogarId)
    .collection("deudasInternas")
    .doc(deudaInternaId);
  const pagoRef = deudaRef.collection("pagos").doc(pagoId);

  return db.runTransaction(async (tx) => {
    const miembroSnap = await tx.get(miembroRef);
    if (!miembroSnap.exists || miembroSnap.data()?.estado !== "activo") {
      throw new HttpsError(
        "permission-denied",
        "Ya no eres miembro activo de este hogar."
      );
    }

    const deudaSnap = await tx.get(deudaRef);
    if (!deudaSnap.exists) {
      throw new HttpsError("not-found", "No encontramos esa deuda.");
    }
    const deuda = deudaSnap.data()!;
    if (deuda.acreedorUid !== authUid) {
      throw new HttpsError(
        "permission-denied",
        "Solo quien cobró puede confirmar el pago."
      );
    }
    if (deuda.estado !== "aceptada" && deuda.estado !== "pagada") {
      throw new HttpsError(
        "failed-precondition",
        "La deuda debe estar aceptada para confirmar pagos."
      );
    }

    const pagoSnap = await tx.get(pagoRef);
    if (!pagoSnap.exists) {
      throw new HttpsError("not-found", "No encontramos ese pago.");
    }
    const pago = pagoSnap.data()!;
    const yaConfirmado = pago.confirmado === true;
    const monto = typeof pago.monto === "number" ? pago.monto : 0;
    const saldoActual =
      typeof deuda.saldo === "number" ? deuda.saldo : 0;
    const estadoActual =
      typeof deuda.estado === "string" ? deuda.estado : "aceptada";

    const calc = calcularConfirmacionPagoInterno({
      yaConfirmado,
      saldoActual,
      montoPago: monto,
      estadoActual,
    });

    if (!calc.aplicar) {
      return {
        saldo: calc.nuevoSaldo,
        estado: calc.nuevoEstado,
        yaConfirmado: true,
      };
    }

    tx.update(pagoRef, {
      confirmado: true,
      confirmadoEn: FieldValue.serverTimestamp(),
    });
    tx.update(deudaRef, {
      saldo: calc.nuevoSaldo,
      estado: calc.nuevoEstado,
    });

    return {
      saldo: calc.nuevoSaldo,
      estado: calc.nuevoEstado,
      yaConfirmado: false,
    };
  });
}
