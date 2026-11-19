import {Firestore} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";

export interface AsistenteInput {
  hogarId: string;
  texto?: string;
}

export interface AsistenteResult {
  mensaje: string;
  disponible: boolean;
}

/**
 * Puerta de IA (`docs/05_ia.md`): en el MVP responde "próximamente".
 * Nivel 2 (futuro) usará Genkit según `hogares/{h}.ia`.
 */
export async function ejecutarAsistente(
  db: Firestore,
  uid: string | undefined,
  input: AsistenteInput
): Promise<AsistenteResult> {
  if (!uid) {
    throw new HttpsError(
      "unauthenticated",
      "Debes iniciar sesión para usar el asistente."
    );
  }
  const hogarId = (input?.hogarId ?? "").trim();
  if (!hogarId) {
    throw new HttpsError("invalid-argument", "Falta el hogar.");
  }

  const miembroSnap = await db
    .collection("hogares")
    .doc(hogarId)
    .collection("miembros")
    .doc(uid)
    .get();
  if (!miembroSnap.exists || miembroSnap.data()?.estado !== "activo") {
    throw new HttpsError(
      "permission-denied",
      "Ya no eres miembro activo de este hogar."
    );
  }

  return {
    mensaje: "El asistente con IA estará disponible próximamente.",
    disponible: false,
  };
}
