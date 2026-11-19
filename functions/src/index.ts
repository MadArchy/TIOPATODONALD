import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {onCall, onRequest, CallableRequest} from "firebase-functions/v2/https";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
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
import {
  manejarAlCrearMovimiento,
  manejarAlEditarMovimiento,
} from "./movimientos";
import {
  CambiarPresupuestoInput,
  CambiarPresupuestoResult,
  ejecutarCambiarPresupuesto,
} from "./presupuesto";
import {ejecutarCerrarPeriodos} from "./cerrar_periodos";
import {
  ConfirmarPagoInternoInput,
  ConfirmarPagoInternoResult,
  ejecutarConfirmarPagoInterno,
} from "./deudas_internas";
import {
  ResolverCorreccionInput,
  ResolverCorreccionResult,
  ejecutarResolverCorreccion,
} from "./correcciones";

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

/**
 * Slice 5: al crear pagoCuota, baja saldoActual (idempotente con saldoAplicado).
 */
export const alCrearMovimiento = onDocumentCreated(
  {
    document: "hogares/{hogarId}/movimientos/{movimientoId}",
    region: REGION,
  },
  async (event) => {
    await manejarAlCrearMovimiento(getFirestore(), event);
  }
);

/**
 * Slice 4: cambiar presupuesto del período vigente + auditoría.
 */
export const cambiarPresupuesto = onCall(
  {region: REGION},
  async (
    request: CallableRequest<CambiarPresupuestoInput>
  ): Promise<CambiarPresupuestoResult> => {
    return ejecutarCambiarPresupuesto(
      getFirestore(),
      request.auth?.uid,
      request.data
    );
  }
);

/**
 * Slice 4: cierre diario de períodos (~00:30 America/Bogota).
 * Genera `resumenes` y aplica `diaInicioPendiente`.
 */
export const cerrarPeriodos = onSchedule(
  {
    region: REGION,
    schedule: "30 0 * * *",
    timeZone: "America/Bogota",
  },
  async () => {
    await ejecutarCerrarPeriodos(getFirestore());
  }
);

/**
 * Slice 6: acreedor confirma pago interno → baja saldo; en 0 → pagada.
 */
export const confirmarPagoInterno = onCall(
  {region: REGION},
  async (
    request: CallableRequest<ConfirmarPagoInternoInput>
  ): Promise<ConfirmarPagoInternoResult> => {
    return ejecutarConfirmarPagoInterno(
      getFirestore(),
      request.auth?.uid,
      request.data
    );
  }
);

/**
 * Slice 7: admin aprueba/rechaza corrección → aplica cambios, saldos y auditoría.
 */
export const resolverCorreccion = onCall(
  {region: REGION},
  async (
    request: CallableRequest<ResolverCorreccionInput>
  ): Promise<ResolverCorreccionResult> => {
    return ejecutarResolverCorreccion(
      getFirestore(),
      request.auth?.uid,
      request.data
    );
  }
);
