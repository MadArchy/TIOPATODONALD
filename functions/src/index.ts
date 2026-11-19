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
import {
  AsistenteInput,
  AsistenteResult,
  ejecutarAsistente,
} from "./asistente";
import {
  ejecutarAvisosDiarios,
  enviarAvisoAMiembrosHogar,
  enviarAvisoAUids,
  payloadAdminCorrigeLoSuyo,
  payloadCorreccionPendiente,
  payloadCorreccionResuelta,
  payloadDeudaInternaNueva,
  payloadPagoPorConfirmar,
} from "./avisos";

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
    const db = getFirestore();
    const result = await ejecutarResolverCorreccion(
      db,
      request.auth?.uid,
      request.data
    );
    if (!result.yaResuelta && result.solicitanteUid && result.hogarId) {
      const aprobada = result.estado === "aprobada";
      await enviarAvisoAUids({
        db,
        uids: [result.solicitanteUid],
        tipo: "correcciones",
        payload: payloadCorreccionResuelta(aprobada),
      });
      if (result.adminCorrigeLoSuyo) {
        await enviarAvisoAMiembrosHogar({
          db,
          hogarId: result.hogarId,
          tipo: "correcciones",
          payload: payloadAdminCorrigeLoSuyo(),
          excluirUid: request.auth?.uid,
        });
      }
    }
    return result;
  }
);

/**
 * Slice 8: puerta de IA — hoy responde "próximamente".
 */
export const asistente = onCall(
  {region: REGION},
  async (
    request: CallableRequest<AsistenteInput>
  ): Promise<AsistenteResult> => {
    return ejecutarAsistente(
      getFirestore(),
      request.auth?.uid,
      request.data
    );
  }
);

/**
 * Slice 9: recordatorio diario, cuotas mañana, correcciones pendientes.
 * Cada 15 min en America/Bogota para respetar horaRecordatorio HH:mm.
 */
export const avisosDiarios = onSchedule(
  {
    region: REGION,
    schedule: "every 15 minutes",
    timeZone: "America/Bogota",
  },
  async () => {
    await ejecutarAvisosDiarios(getFirestore());
  }
);

/** Slice 9: push al admin cuando llega una corrección pendiente. */
export const alCrearCorreccion = onDocumentCreated(
  {
    document: "hogares/{hogarId}/correcciones/{correccionId}",
    region: REGION,
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const data = snap.data();
    if (data.estado !== "pendiente") return;
    const db = getFirestore();
    const hogarId = event.params.hogarId;
    const hogarSnap = await db.collection("hogares").doc(hogarId).get();
    const adminUid = String(hogarSnap.data()?.adminUid ?? "");
    if (!adminUid) return;
    await enviarAvisoAUids({
      db,
      uids: [adminUid],
      tipo: "correcciones",
      payload: payloadCorreccionPendiente(),
    });
  }
);

/** Slice 9: push al deudor cuando el acreedor crea una deuda interna. */
export const alCrearDeudaInterna = onDocumentCreated(
  {
    document: "hogares/{hogarId}/deudasInternas/{deudaId}",
    region: REGION,
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const data = snap.data();
    const deudorUid = String(data.deudorUid ?? "");
    if (!deudorUid) return;
    const acreedorUid = String(data.acreedorUid ?? "");
    const db = getFirestore();
    let nombre = "Alguien del hogar";
    if (acreedorUid) {
      const u = await db.collection("usuarios").doc(acreedorUid).get();
      nombre = String(u.data()?.nombre ?? nombre);
    }
    await enviarAvisoAUids({
      db,
      uids: [deudorUid],
      tipo: "deudasInternas",
      payload: payloadDeudaInternaNueva(nombre),
    });
  }
);

/** Slice 9: push al acreedor cuando hay un pago por confirmar. */
export const alCrearPagoInterno = onDocumentCreated(
  {
    document: "hogares/{hogarId}/deudasInternas/{deudaId}/pagos/{pagoId}",
    region: REGION,
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const data = snap.data();
    if (data.confirmado === true) return;
    const db = getFirestore();
    const hogarId = event.params.hogarId;
    const deudaId = event.params.deudaId;
    const deudaSnap = await db
      .collection("hogares")
      .doc(hogarId)
      .collection("deudasInternas")
      .doc(deudaId)
      .get();
    if (!deudaSnap.exists) return;
    const deuda = deudaSnap.data()!;
    const acreedorUid = String(deuda.acreedorUid ?? "");
    if (!acreedorUid) return;
    const porUid = String(data.registradoPor ?? deuda.deudorUid ?? "");
    let nombre = "Tu deudor";
    if (porUid) {
      const u = await db.collection("usuarios").doc(porUid).get();
      nombre = String(u.data()?.nombre ?? nombre);
    }
    await enviarAvisoAUids({
      db,
      uids: [acreedorUid],
      tipo: "deudasInternas",
      payload: payloadPagoPorConfirmar(nombre),
    });
  }
);
