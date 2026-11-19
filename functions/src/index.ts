import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {onCall, onRequest, CallableRequest} from "firebase-functions/v2/https";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {setGlobalOptions} from "firebase-functions/v2";
import {
  CrearHogarInput,
  CrearHogarResult,
  ejecutarCrearHogar,
  ejecutarGenerarInvitacion,
  ejecutarSacarMiembro,
  ejecutarUnirseConCodigo,
  GenerarInvitacionInput,
  GenerarInvitacionResult,
  SacarMiembroInput,
  SacarMiembroResult,
  UnirseConCodigoInput,
  UnirseConCodigoResult,
} from "./hogar";
import {manejarAlEditarMovimiento} from "./movimientos";

if (getApps().length === 0) {
  initializeApp();
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

/**
 * Slice 2: Callables de Hogar y QR (docs/04_seguridad_y_functions.md)
 */
export const crearHogar = onCall(
  {region: REGION},
  async (request: CallableRequest<CrearHogarInput>): Promise<CrearHogarResult> => {
    return ejecutarCrearHogar(
      getFirestore(),
      request.auth?.uid,
      request.data
    );
  }
);

export const generarInvitacion = onCall(
  {region: REGION},
  async (
    request: CallableRequest<GenerarInvitacionInput>
  ): Promise<GenerarInvitacionResult> => {
    return ejecutarGenerarInvitacion(
      getFirestore(),
      request.auth?.uid,
      request.data
    );
  }
);

export const unirseConCodigo = onCall(
  {region: REGION},
  async (
    request: CallableRequest<UnirseConCodigoInput>
  ): Promise<UnirseConCodigoResult> => {
    return ejecutarUnirseConCodigo(
      getFirestore(),
      request.auth?.uid,
      request.data
    );
  }
);

export const sacarMiembro = onCall(
  {region: REGION},
  async (
    request: CallableRequest<SacarMiembroInput>
  ): Promise<SacarMiembroResult> => {
    return ejecutarSacarMiembro(
      getFirestore(),
      request.auth?.uid,
      request.data
    );
  }
);

/**
 * Slice 3: auditoría de edición menor (nota / categoría) en movimientos.
 */
export const alEditarMovimiento = onDocumentUpdated(
  {
    document: "hogares/{hogarId}/movimientos/{movimientoId}",
    region: REGION,
  },
  async (event) => {
    await manejarAlEditarMovimiento(getFirestore(), event);
  }
);
