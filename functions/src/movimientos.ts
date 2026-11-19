import {
  Firestore,
  FieldValue,
  DocumentSnapshot,
} from "firebase-admin/firestore";
import {Change, FirestoreEvent} from "firebase-functions/v2/firestore";

const CAMPOS_EDICION_MENOR = new Set(["nota", "categoria", "editadoEn"]);

/** Resultado puro de aplicar un pago de cuota al saldo (idempotente). */
export interface ResultadoAplicarPagoCuota {
  aplicar: boolean;
  nuevoSaldo: number;
  nuevoEstado: string;
  motivo?: string;
}

/**
 * Lógica pura: si ya está saldoAplicado, no vuelve a bajar.
 * Baja saldoActual por monto (mínimo 0); en 0 → estado pagada.
 */
export function calcularAplicacionPagoCuota(params: {
  saldoAplicado: boolean;
  saldoActual: number;
  monto: number;
  estadoActual: string;
}): ResultadoAplicarPagoCuota {
  if (params.saldoAplicado) {
    return {
      aplicar: false,
      nuevoSaldo: params.saldoActual,
      nuevoEstado: params.estadoActual,
      motivo: "ya_aplicado",
    };
  }
  const monto = Math.max(0, Math.trunc(params.monto));
  const nuevoSaldo = Math.max(0, Math.trunc(params.saldoActual) - monto);
  const nuevoEstado =
    nuevoSaldo === 0 ? "pagada" : params.estadoActual || "activa";
  return {
    aplicar: true,
    nuevoSaldo,
    nuevoEstado,
  };
}

/**
 * Detecta si el update es una edición menor (nota / categoría gasto→gasto / editadoEn).
 */
export function esEdicionMenor(
  before: Record<string, unknown>,
  after: Record<string, unknown>
): boolean {
  const keys = new Set([
    ...Object.keys(before),
    ...Object.keys(after),
  ]);
  const cambiados: string[] = [];
  for (const key of keys) {
    const b = before[key];
    const a = after[key];
    // Comparación superficial (Timestamps / valores primitivos).
    const mismo =
      b === a ||
      (b != null &&
        a != null &&
        typeof (b as {isEqual?: (o: unknown) => boolean}).isEqual === "function" &&
        (b as {isEqual: (o: unknown) => boolean}).isEqual(a)) ||
      JSON.stringify(b) === JSON.stringify(a);
    if (!mismo) {
      cambiados.push(key);
    }
  }
  if (cambiados.length === 0) return false;
  return cambiados.every((k) => CAMPOS_EDICION_MENOR.has(k));
}

/**
 * Escribe auditoría `edicionMenor` cuando el cliente edita nota/categoría.
 * Idempotente respecto a otros updates (fotoPath, saldoAplicado, etc.).
 */
export async function ejecutarAlEditarMovimiento(
  db: Firestore,
  hogarId: string,
  movimientoId: string,
  beforeData: Record<string, unknown> | undefined,
  afterData: Record<string, unknown> | undefined
): Promise<{escrito: boolean}> {
  if (!beforeData || !afterData) {
    return {escrito: false};
  }
  if (!esEdicionMenor(beforeData, afterData)) {
    return {escrito: false};
  }

  const porUid = String(afterData.uid ?? beforeData.uid ?? "");
  await db
    .collection("hogares")
    .doc(hogarId)
    .collection("auditoria")
    .add({
      movimientoId,
      accion: "edicionMenor",
      antes: {
        nota: beforeData.nota ?? "",
        categoria: beforeData.categoria ?? null,
      },
      despues: {
        nota: afterData.nota ?? "",
        categoria: afterData.categoria ?? null,
      },
      porUid,
      aprobadoPor: null,
      fecha: FieldValue.serverTimestamp(),
    });

  return {escrito: true};
}

/** Adaptador tipado para el trigger onDocumentUpdated. */
export async function manejarAlEditarMovimiento(
  db: Firestore,
  event: FirestoreEvent<
    Change<DocumentSnapshot> | undefined,
    {hogarId: string; movimientoId: string}
  >
): Promise<void> {
  const change = event.data;
  if (!change) return;
  await ejecutarAlEditarMovimiento(
    db,
    event.params.hogarId,
    event.params.movimientoId,
    change.before.data() as Record<string, unknown> | undefined,
    change.after.data() as Record<string, unknown> | undefined
  );
}

/**
 * Trigger onCreate: si pagoCuota, baja saldoActual en transacción e idempotente
 * con saldoAplicado. Si llega a 0 → estado pagada.
 */
export async function ejecutarAlCrearMovimiento(
  db: Firestore,
  hogarId: string,
  movimientoId: string,
  data: Record<string, unknown> | undefined
): Promise<{aplicado: boolean}> {
  if (!data || data.tipo !== "pagoCuota") {
    return {aplicado: false};
  }
  const deudaId = data.deudaId;
  if (typeof deudaId !== "string" || deudaId.length === 0) {
    return {aplicado: false};
  }
  const monto = typeof data.monto === "number" ? data.monto : 0;

  const movRef = db
    .collection("hogares")
    .doc(hogarId)
    .collection("movimientos")
    .doc(movimientoId);
  const deudaRef = db
    .collection("hogares")
    .doc(hogarId)
    .collection("deudas")
    .doc(deudaId);

  const resultado = await db.runTransaction(async (tx) => {
    const movSnap = await tx.get(movRef);
    if (!movSnap.exists) {
      return {aplicado: false};
    }
    const mov = movSnap.data() as Record<string, unknown>;
    if (mov.tipo !== "pagoCuota") {
      return {aplicado: false};
    }
    const deudaSnap = await tx.get(deudaRef);
    if (!deudaSnap.exists) {
      return {aplicado: false};
    }
    const deuda = deudaSnap.data() as Record<string, unknown>;
    const calculo = calcularAplicacionPagoCuota({
      saldoAplicado: mov.saldoAplicado === true,
      saldoActual: typeof deuda.saldoActual === "number" ? deuda.saldoActual : 0,
      monto: typeof mov.monto === "number" ? mov.monto : monto,
      estadoActual:
        typeof deuda.estado === "string" ? deuda.estado : "activa",
    });
    if (!calculo.aplicar) {
      return {aplicado: false};
    }

    tx.update(deudaRef, {
      saldoActual: calculo.nuevoSaldo,
      estado: calculo.nuevoEstado,
    });
    tx.update(movRef, {saldoAplicado: true});
    return {aplicado: true};
  });

  return resultado;
}

/** Adaptador tipado para el trigger onDocumentCreated. */
export async function manejarAlCrearMovimiento(
  db: Firestore,
  event: FirestoreEvent<
    DocumentSnapshot | undefined,
    {hogarId: string; movimientoId: string}
  >
): Promise<void> {
  const snap = event.data;
  if (!snap) return;
  await ejecutarAlCrearMovimiento(
    db,
    event.params.hogarId,
    event.params.movimientoId,
    snap.data() as Record<string, unknown> | undefined
  );
}
