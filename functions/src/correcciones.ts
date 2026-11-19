import {
  DocumentSnapshot,
  FieldValue,
  Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {periodoDe} from "./periodo";

export const DIAS_EXTRA_PLAZO_CORRECCION = 5;

export interface ResolverCorreccionInput {
  hogarId: string;
  correccionId: string;
  aprobar: boolean;
  motivoRechazo?: string;
}

export interface ResolverCorreccionResult {
  estado: string;
  yaResuelta: boolean;
  /** Para push post-transacción (Slice 9). */
  solicitanteUid?: string;
  adminCorrigeLoSuyo?: boolean;
  hogarId?: string;
}

export interface DeltaSaldoDeuda {
  deudaId: string;
  delta: number;
}

export interface ResultadoAjusteSaldoCorreccion {
  deltas: DeltaSaldoDeuda[];
  nuevoSaldoAplicado: boolean;
}

/** Plazo = fin del período del movimiento + 5 días. */
export function dentroDePlazoCorreccion(params: {
  periodoIdMovimiento: string;
  diaInicioDueno: number;
  ahora: Date;
}): boolean {
  const partes = params.periodoIdMovimiento.split("-");
  if (partes.length !== 3) return false;
  const y = Number(partes[0]);
  const m = Number(partes[1]);
  const d = Number(partes[2]);
  if (!y || !m || !d) return false;
  // 17:00 UTC ≈ mediodía Bogotá → periodoDe con diaInicio correcto.
  const instante = new Date(Date.UTC(y, m - 1, d, 17, 0, 0));
  let periodo;
  try {
    periodo = periodoDe(instante, params.diaInicioDueno);
  } catch {
    return false;
  }
  if (periodo.periodoId !== params.periodoIdMovimiento) return false;

  const limite = new Date(
    periodo.fin.getTime() + DIAS_EXTRA_PLAZO_CORRECCION * 24 * 60 * 60 * 1000
  );
  return params.ahora.getTime() <= limite.getTime();
}

/**
 * gasto↔pagoCuota / anulación / cambio de monto o deuda.
 * delta positivo = devolver al saldoActual.
 */
export function calcularAjustesSaldoPorCorreccion(params: {
  tipoAntes: string;
  tipoDespues: string;
  estadoDespues: string;
  montoAntes: number;
  montoDespues: number;
  deudaIdAntes: string | null;
  deudaIdDespues: string | null;
  saldoAplicadoAntes: boolean;
}): ResultadoAjusteSaldoCorreccion {
  const map = new Map<string, number>();
  const sumar = (id: string | null, delta: number) => {
    if (!id || delta === 0) return;
    map.set(id, (map.get(id) ?? 0) + delta);
  };

  const eraPagoAplicado =
    params.tipoAntes === "pagoCuota" &&
    params.saldoAplicadoAntes &&
    !!params.deudaIdAntes;

  const seraPagoActivo =
    params.tipoDespues === "pagoCuota" &&
    params.estadoDespues === "activo" &&
    !!params.deudaIdDespues;

  if (eraPagoAplicado) {
    sumar(params.deudaIdAntes, params.montoAntes);
  }
  if (seraPagoActivo) {
    sumar(params.deudaIdDespues, -params.montoDespues);
  }

  const deltas: DeltaSaldoDeuda[] = [];
  for (const [deudaId, delta] of map.entries()) {
    if (delta !== 0) deltas.push({deudaId, delta});
  }
  return {deltas, nuevoSaldoAplicado: seraPagoActivo};
}

export function accionAuditoriaCorreccion(params: {
  adminCorrigeLoSuyo: boolean;
  anula: boolean;
}): string {
  if (params.adminCorrigeLoSuyo) return "correccionAdminPropia";
  if (params.anula) return "anulacion";
  return "correccion";
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

function snapshotMap(
  data: Record<string, unknown>,
  keys: string[]
): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const k of keys) {
    out[k] = data[k] ?? null;
  }
  return out;
}

/**
 * Admin aprueba o rechaza una corrección pendiente.
 * Aprobada: aplica cambios en transacción, ajusta saldos, escribe auditoría.
 */
export async function ejecutarResolverCorreccion(
  db: Firestore,
  uid: string | undefined,
  input: ResolverCorreccionInput,
  ahora: Date = new Date()
): Promise<ResolverCorreccionResult> {
  const authUid = exigirUid(uid);
  const hogarId = (input?.hogarId ?? "").trim();
  const correccionId = (input?.correccionId ?? "").trim();
  const aprobar = input?.aprobar === true;
  const motivoRechazo = (input?.motivoRechazo ?? "").trim();

  if (!hogarId || !correccionId) {
    throw new HttpsError(
      "invalid-argument",
      "Faltan datos para resolver la corrección."
    );
  }
  if (!aprobar && motivoRechazo.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "Escribe el motivo del rechazo."
    );
  }

  const hogarRef = db.collection("hogares").doc(hogarId);
  const correccionRef = hogarRef.collection("correcciones").doc(correccionId);

  return db.runTransaction(async (tx) => {
    const hogarSnap = await tx.get(hogarRef);
    if (!hogarSnap.exists) {
      throw new HttpsError("not-found", "No encontramos ese hogar.");
    }
    const adminUid = String(hogarSnap.data()?.adminUid ?? "");
    if (adminUid !== authUid) {
      throw new HttpsError(
        "permission-denied",
        "Solo el administrador puede aprobar o rechazar correcciones."
      );
    }

    const miembroRef = hogarRef.collection("miembros").doc(authUid);
    const miembroSnap = await tx.get(miembroRef);
    if (!miembroSnap.exists || miembroSnap.data()?.estado !== "activo") {
      throw new HttpsError(
        "permission-denied",
        "Ya no eres miembro activo de este hogar."
      );
    }

    const corrSnap = await tx.get(correccionRef);
    if (!corrSnap.exists) {
      throw new HttpsError("not-found", "No encontramos esa corrección.");
    }
    const corr = corrSnap.data()!;
    if (corr.estado !== "pendiente") {
      return {
        estado: String(corr.estado),
        yaResuelta: true,
      };
    }

    if (!aprobar) {
      tx.update(correccionRef, {
        estado: "rechazada",
        resueltaPor: authUid,
        resueltaEn: FieldValue.serverTimestamp(),
        motivoRechazo,
      });
      return {
        estado: "rechazada",
        yaResuelta: false,
        solicitanteUid: String(corr.solicitanteUid ?? ""),
        adminCorrigeLoSuyo: false,
        hogarId,
      };
    }

    const movimientoId = String(corr.movimientoId ?? "");
    const movRef = hogarRef.collection("movimientos").doc(movimientoId);
    const movSnap = await tx.get(movRef);
    if (!movSnap.exists) {
      throw new HttpsError("not-found", "No encontramos el movimiento.");
    }
    const mov = movSnap.data()!;
    const duenoUid = String(mov.uid ?? "");
    const usuarioDuenoSnap = await tx.get(db.collection("usuarios").doc(duenoUid));
    if (!usuarioDuenoSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "No encontramos al dueño del movimiento."
      );
    }
    const diaInicioDueno = Number(usuarioDuenoSnap.data()?.diaInicioPeriodo ?? 1);
    const periodoId = String(mov.periodoId ?? "");
    if (
      !dentroDePlazoCorreccion({
        periodoIdMovimiento: periodoId,
        diaInicioDueno,
        ahora,
      })
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Ya pasó el plazo para corregir este movimiento."
      );
    }

    const cambios = (corr.cambios ?? {}) as Record<string, unknown>;
    const tipoAntes = String(mov.tipo ?? "");
    const montoAntes = Number(mov.monto ?? 0);
    const deudaIdAntes =
      typeof mov.deudaId === "string" ? mov.deudaId : null;
    const saldoAplicadoAntes = mov.saldoAplicado === true;
    const estadoAntes = String(mov.estado ?? "activo");

    const update: Record<string, unknown> = {
      editadoEn: FieldValue.serverTimestamp(),
    };

    if (Object.prototype.hasOwnProperty.call(cambios, "monto")) {
      const m = Number(cambios.monto);
      if (!Number.isInteger(m) || m <= 0) {
        throw new HttpsError("invalid-argument", "Monto de corrección inválido.");
      }
      update.monto = m;
    }
    if (Object.prototype.hasOwnProperty.call(cambios, "nota")) {
      update.nota = String(cambios.nota ?? "");
    }
    if (Object.prototype.hasOwnProperty.call(cambios, "categoria")) {
      update.categoria = cambios.categoria ?? null;
    }
    if (Object.prototype.hasOwnProperty.call(cambios, "tipo")) {
      update.tipo = String(cambios.tipo);
    }
    if (Object.prototype.hasOwnProperty.call(cambios, "deudaId")) {
      update.deudaId = cambios.deudaId ?? null;
    }
    if (Object.prototype.hasOwnProperty.call(cambios, "estado")) {
      if (cambios.estado !== "anulado") {
        throw new HttpsError(
          "invalid-argument",
          "Solo se puede anular el movimiento."
        );
      }
      update.estado = "anulado";
    }
    if (Object.prototype.hasOwnProperty.call(cambios, "fecha")) {
      const f = cambios.fecha;
      if (f instanceof Timestamp) {
        update.fecha = f;
        const fechaDate = f.toDate();
        update.periodoId = periodoDe(fechaDate, diaInicioDueno).periodoId;
      } else if (typeof f === "string") {
        const fechaDate = new Date(f);
        update.fecha = Timestamp.fromDate(fechaDate);
        update.periodoId = periodoDe(fechaDate, diaInicioDueno).periodoId;
      } else {
        throw new HttpsError("invalid-argument", "Fecha de corrección inválida.");
      }
    }

    // Normalizar pagoCuota / gasto / ingreso.
    const tipoDespues = String(update.tipo ?? tipoAntes);
    const estadoDespues = String(update.estado ?? estadoAntes);
    let categoriaDespues =
      Object.prototype.hasOwnProperty.call(update, "categoria") ?
        (update.categoria as string | null) :
        ((mov.categoria as string | null) ?? null);
    let deudaIdDespues =
      Object.prototype.hasOwnProperty.call(update, "deudaId") ?
        (update.deudaId as string | null) :
        deudaIdAntes;

    if (tipoDespues === "pagoCuota") {
      update.categoria = null;
      categoriaDespues = null;
      if (!deudaIdDespues) {
        throw new HttpsError(
          "invalid-argument",
          "El pago de cuota necesita una deuda."
        );
      }
      const deudaCheck = await tx.get(
        hogarRef.collection("deudas").doc(deudaIdDespues)
      );
      if (!deudaCheck.exists) {
        throw new HttpsError("not-found", "No encontramos esa deuda.");
      }
      update.deudaId = deudaIdDespues;
    } else {
      update.deudaId = null;
      deudaIdDespues = null;
    }

    const montoDespues = Number(update.monto ?? montoAntes);

    const ajuste = calcularAjustesSaldoPorCorreccion({
      tipoAntes,
      tipoDespues,
      estadoDespues,
      montoAntes,
      montoDespues,
      deudaIdAntes,
      deudaIdDespues,
      saldoAplicadoAntes,
    });
    update.saldoAplicado = ajuste.nuevoSaldoAplicado;

    // Leer deudas a tocar antes de escribir.
    const deudaSnaps = new Map<string, DocumentSnapshot>();
    for (const d of ajuste.deltas) {
      const ref = hogarRef.collection("deudas").doc(d.deudaId);
      deudaSnaps.set(d.deudaId, await tx.get(ref));
    }

    for (const d of ajuste.deltas) {
      const snap = deudaSnaps.get(d.deudaId);
      if (!snap || !snap.exists) {
        throw new HttpsError("not-found", "No encontramos la deuda a ajustar.");
      }
      const data = snap.data()!;
      const saldoActual = Number(data.saldoActual ?? 0);
      const nuevoSaldo = Math.max(0, saldoActual + d.delta);
      const estadoDeuda =
        nuevoSaldo === 0 ? "pagada" :
          (data.estado === "pagada" && nuevoSaldo > 0 ? "activa" : data.estado);
      tx.update(hogarRef.collection("deudas").doc(d.deudaId), {
        saldoActual: nuevoSaldo,
        estado: estadoDeuda,
      });
    }

    const camposAudit = [
      "tipo",
      "monto",
      "categoria",
      "deudaId",
      "fecha",
      "periodoId",
      "estado",
      "nota",
      "saldoAplicado",
    ];
    const antes = snapshotMap(mov as Record<string, unknown>, camposAudit);
    const despues = {
      ...antes,
      ...Object.fromEntries(
        Object.entries(update).filter(([k]) => k !== "editadoEn")
      ),
      tipo: tipoDespues,
      monto: montoDespues,
      categoria: categoriaDespues,
      deudaId: deudaIdDespues,
      estado: estadoDespues,
      saldoAplicado: ajuste.nuevoSaldoAplicado,
    };

    tx.update(movRef, update);
    tx.update(correccionRef, {
      estado: "aprobada",
      resueltaPor: authUid,
      resueltaEn: FieldValue.serverTimestamp(),
      motivoRechazo: null,
    });

    const adminCorrigeLoSuyo = duenoUid === authUid;
    const anula = estadoDespues === "anulado" && estadoAntes !== "anulado";
    const auditoriaRef = hogarRef.collection("auditoria").doc();
    tx.set(auditoriaRef, {
      movimientoId,
      accion: accionAuditoriaCorreccion({adminCorrigeLoSuyo, anula}),
      antes,
      despues,
      porUid: String(corr.solicitanteUid ?? authUid),
      aprobadoPor: authUid,
      fecha: FieldValue.serverTimestamp(),
    });

    return {
      estado: "aprobada",
      yaResuelta: false,
      solicitanteUid: String(corr.solicitanteUid ?? ""),
      adminCorrigeLoSuyo,
      hogarId,
    };
  });
}
