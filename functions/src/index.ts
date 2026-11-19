import * as admin from "firebase-admin";
import {onCall, onRequest} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Región única para todas las Cloud Functions (AGENTS.md / .agents/rules/firebase.md)
export const REGION = "us-central1";
setGlobalOptions({region: REGION});

export interface PingResponse {
  ok: boolean;
  mensaje: string;
  region: string;
  timestamp: string;
}

/**
 * Lógica pura del endpoint ping para facilitar pruebas unitarias y uso tanto en onCall como onRequest.
 */
export function construirRespuestaPing(now: Date = new Date()): PingResponse {
  return {
    ok: true,
    mensaje: "pong",
    region: REGION,
    timestamp: now.toISOString(),
  };
}

/**
 * Función callable v2 de prueba para el Slice 0.
 */
export const ping = onCall(
  {region: REGION},
  async (): Promise<PingResponse> => {
    return construirRespuestaPing();
  }
);

/**
 * Endpoint HTTP v2 de prueba para verificar fácilmente en navegador o curl contra el emulador.
 */
export const pingHttp = onRequest(
  {region: REGION},
  (_req, res) => {
    res.status(200).json(construirRespuestaPing());
  }
);
