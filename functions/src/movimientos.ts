import {Firestore, FieldValue} from "firebase-admin/firestore";
import {Change, FirestoreEvent} from "firebase-functions/v2/firestore";
import {DocumentSnapshot} from "firebase-admin/firestore";

const CAMPOS_EDICION_MENOR = new Set(["nota", "categoria", "editadoEn"]);

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
