/**
 * Slice 9: selección y armado de avisos push (FCM).
 * Lógica pura testeable + envío vía Admin Messaging.
 */
import {
  Firestore,
  FieldValue,
} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {componentesBogota} from "./periodo";
import {gastado as sumarGastado} from "./indicadores";
import {umbralesAlcanzados} from "./presupuesto";

export type TipoAviso =
  | "alertasPresupuesto"
  | "recordatorioDiario"
  | "cuotas"
  | "correcciones"
  | "deudasInternas";

export interface PreferenciasAvisos {
  alertasPresupuesto: boolean;
  recordatorioDiario: boolean;
  cuotas: boolean;
  correcciones: boolean;
  deudasInternas: boolean;
}

export const PREFERENCIAS_AVISOS_DEFAULT: PreferenciasAvisos = {
  alertasPresupuesto: true,
  recordatorioDiario: true,
  cuotas: true,
  correcciones: true,
  deudasInternas: true,
};

export interface PayloadAviso {
  titulo: string;
  cuerpo: string;
  data?: Record<string, string>;
}

export interface DestinatarioAviso {
  uid: string;
  tokens: string[];
}

/** Normaliza preferencias (docs faltantes → true). */
export function normalizarPreferencias(
  raw: unknown
): PreferenciasAvisos {
  const r =
    raw && typeof raw === "object"
      ? (raw as Record<string, unknown>)
      : {};
  const bool = (k: keyof PreferenciasAvisos): boolean =>
    r[k] === false ? false : true;
  return {
    alertasPresupuesto: bool("alertasPresupuesto"),
    recordatorioDiario: bool("recordatorioDiario"),
    cuotas: bool("cuotas"),
    correcciones: bool("correcciones"),
    deudasInternas: bool("deudasInternas"),
  };
}

export function preferenciaActiva(
  prefs: PreferenciasAvisos,
  tipo: TipoAviso
): boolean {
  return prefs[tipo] !== false;
}

/** HH:mm en America/Bogota. */
export function horaBogotaHHMM(ahora: Date): string {
  const ms = ahora.getTime() - 5 * 60 * 60 * 1000;
  const b = new Date(ms);
  const hh = String(b.getUTCHours()).padStart(2, "0");
  const mm = String(b.getUTCMinutes()).padStart(2, "0");
  return `${hh}:${mm}`;
}

/**
 * Coincide si la hora del recordatorio cae en la ventana
 * [ahora - ventanaMin, ahora] (para cron cada 15 min).
 */
export function coincideHoraRecordatorio(params: {
  horaRecordatorio: string | null | undefined;
  ahora: Date;
  ventanaMinutos?: number;
}): boolean {
  const hora = (params.horaRecordatorio ?? "").trim();
  if (!/^\d{2}:\d{2}$/.test(hora)) return false;
  const ventana = params.ventanaMinutos ?? 15;
  const actual = horaBogotaHHMM(params.ahora);
  if (hora === actual) return true;

  const [th, tm] = hora.split(":").map(Number);
  const [ah, am] = actual.split(":").map(Number);
  const target = th * 60 + tm;
  const nowMin = ah * 60 + am;
  const diff = (nowMin - target + 24 * 60) % (24 * 60);
  return diff > 0 && diff < ventana;
}

/** Día calendario Bogotá de mañana (1–31). */
export function diaMananaBogota(ahora: Date): {
  year: number;
  month: number;
  day: number;
} {
  const c = componentesBogota(ahora);
  const manana = new Date(Date.UTC(c.year, c.month - 1, c.day + 1, 12, 0, 0));
  return {
    year: manana.getUTCFullYear(),
    month: manana.getUTCMonth() + 1,
    day: manana.getUTCDate(),
  };
}

/**
 * ¿La cuota con diaPago cae mañana en Bogotá?
 * diaPago 1–31; meses cortos usan el último día del mes.
 */
export function cuotaVenceManana(params: {
  diaPago: number;
  ahora: Date;
}): boolean {
  const diaPago = Math.trunc(params.diaPago);
  if (diaPago < 1 || diaPago > 31) return false;
  const manana = diaMananaBogota(params.ahora);
  const ultimoDia = new Date(
    Date.UTC(manana.year, manana.month, 0)
  ).getUTCDate();
  const efectivo = Math.min(diaPago, ultimoDia);
  return efectivo === manana.day;
}

export function payloadAlertaPresupuesto(umbral: number): PayloadAviso {
  return {
    titulo: "Alerta de presupuesto",
    cuerpo: `Ya vas en el ${umbral}% de tu presupuesto de este período.`,
    data: {tipo: "alertaPresupuesto", umbral: String(umbral)},
  };
}

export function payloadRecordatorioDiario(): PayloadAviso {
  return {
    titulo: "Recordatorio del hogar",
    cuerpo: "¿Registraste tus gastos de hoy?",
    data: {tipo: "recordatorioDiario"},
  };
}

export function payloadCuotaManana(entidad: string): PayloadAviso {
  return {
    titulo: "Cuota mañana",
    cuerpo: `Mañana vence la cuota de ${entidad}.`,
    data: {tipo: "cuotaManana"},
  };
}

export function payloadCorreccionPendiente(): PayloadAviso {
  return {
    titulo: "Corrección pendiente",
    cuerpo: "Hay una corrección esperando tu revisión.",
    data: {tipo: "correccionPendiente"},
  };
}

export function payloadCorreccionResuelta(aprobada: boolean): PayloadAviso {
  return {
    titulo: aprobada ? "Corrección aprobada" : "Corrección rechazada",
    cuerpo: aprobada
      ? "El admin aprobó tu corrección."
      : "El admin rechazó tu corrección.",
    data: {tipo: "correccionResuelta", aprobada: aprobada ? "1" : "0"},
  };
}

export function payloadAdminCorrigeLoSuyo(): PayloadAviso {
  return {
    titulo: "Aviso del hogar",
    cuerpo: "El administrador corrigió un movimiento propio.",
    data: {tipo: "correccionAdminPropia"},
  };
}

export function payloadDeudaInternaNueva(acreedorNombre: string): PayloadAviso {
  return {
    titulo: "Nueva deuda entre ustedes",
    cuerpo: `${acreedorNombre} te registró una deuda por confirmar.`,
    data: {tipo: "deudaInternaNueva"},
  };
}

export function payloadPagoPorConfirmar(deudorNombre: string): PayloadAviso {
  return {
    titulo: "Pago por confirmar",
    cuerpo: `${deudorNombre} marcó un pago. Confírmalo cuando puedas.`,
    data: {tipo: "pagoPorConfirmar"},
  };
}

/** Filtra tokens de usuarios con la preferencia activa. */
export function seleccionarTokens(params: {
  usuarios: Array<{
    uid: string;
    fcmTokens?: unknown;
    preferenciasAvisos?: unknown;
  }>;
  tipo: TipoAviso;
}): DestinatarioAviso[] {
  const out: DestinatarioAviso[] = [];
  for (const u of params.usuarios) {
    const prefs = normalizarPreferencias(u.preferenciasAvisos);
    if (!preferenciaActiva(prefs, params.tipo)) continue;
    const raw = Array.isArray(u.fcmTokens) ? u.fcmTokens : [];
    const tokens = raw
      .filter((t): t is string => typeof t === "string" && t.length > 0);
    if (tokens.length === 0) continue;
    out.push({uid: u.uid, tokens});
  }
  return out;
}

export interface EnviadorPush {
  enviar(tokens: string[], payload: PayloadAviso): Promise<string[]>;
}

/** Envío real con FCM; tokens inválidos se reportan para limpieza. */
export function crearEnviadorFcm(): EnviadorPush {
  return {
    async enviar(tokens, payload) {
      if (tokens.length === 0) return [];
      const messaging = getMessaging();
      const res = await messaging.sendEachForMulticast({
        tokens,
        notification: {
          title: payload.titulo,
          body: payload.cuerpo,
        },
        data: payload.data,
      });
      const invalidos: string[] = [];
      res.responses.forEach((r, i) => {
        if (!r.success) {
          const code = r.error?.code ?? "";
          if (
            code.includes("registration-token-not-registered") ||
            code.includes("invalid-registration-token")
          ) {
            invalidos.push(tokens[i]);
          }
        }
      });
      return invalidos;
    },
  };
}

async function cargarUsuario(
  db: Firestore,
  uid: string
): Promise<Record<string, unknown> | null> {
  const snap = await db.collection("usuarios").doc(uid).get();
  if (!snap.exists) return null;
  return {uid, ...snap.data()};
}

async function quitarTokensInvalidos(
  db: Firestore,
  uid: string,
  invalidos: string[]
): Promise<void> {
  if (invalidos.length === 0) return;
  await db
    .collection("usuarios")
    .doc(uid)
    .update({fcmTokens: FieldValue.arrayRemove(...invalidos)});
}

export async function enviarAvisoAUids(params: {
  db: Firestore;
  uids: string[];
  tipo: TipoAviso;
  payload: PayloadAviso;
  enviador?: EnviadorPush;
}): Promise<number> {
  const enviador = params.enviador ?? crearEnviadorFcm();
  const usuarios: Array<Record<string, unknown> & {uid: string}> = [];
  for (const uid of params.uids) {
    const u = await cargarUsuario(params.db, uid);
    if (u && typeof u.uid === "string") {
      usuarios.push(u as Record<string, unknown> & {uid: string});
    }
  }
  const destinos = seleccionarTokens({usuarios, tipo: params.tipo});
  let enviados = 0;
  for (const d of destinos) {
    const invalidos = await enviador.enviar(d.tokens, params.payload);
    await quitarTokensInvalidos(params.db, d.uid, invalidos);
    enviados += d.tokens.length - invalidos.length;
  }
  return enviados;
}

export async function enviarAvisoAMiembrosHogar(params: {
  db: Firestore;
  hogarId: string;
  tipo: TipoAviso;
  payload: PayloadAviso;
  excluirUid?: string;
  enviador?: EnviadorPush;
}): Promise<number> {
  const miembrosSnap = await params.db
    .collection("hogares")
    .doc(params.hogarId)
    .collection("miembros")
    .where("estado", "==", "activo")
    .get();
  const uids = miembrosSnap.docs
    .map((d) => d.id)
    .filter((id) => id !== params.excluirUid);
  return enviarAvisoAUids({
    db: params.db,
    uids,
    tipo: params.tipo,
    payload: params.payload,
    enviador: params.enviador,
  });
}

/**
 * Franja única diaria (America/Bogota) para avisos del hogar (cuotas mañana
 * y correcciones pendientes), evitando spam cuando el cron corre cada 15 min.
 */
export const HORA_AVISOS_HOGAR_BOGOTA = "08:00";

export function enFranjaAvisosHogar(
  ahora: Date,
  ventanaMinutos = 15
): boolean {
  return coincideHoraRecordatorio({
    horaRecordatorio: HORA_AVISOS_HOGAR_BOGOTA,
    ahora,
    ventanaMinutos,
  });
}

/**
 * Tras crear gasto/pagoCuota: calcula umbrales nuevos, marca alertasEnviadas
 * en transacción (idempotente) y devuelve los umbrales recién alcanzados.
 */
export async function procesarAlertasPresupuestoTrasMovimiento(params: {
  db: Firestore;
  hogarId: string;
  uid: string;
  periodoId: string;
}): Promise<number[]> {
  const presupuestoId = `${params.uid}_${params.periodoId}`;
  const prepRef = params.db
    .collection("hogares")
    .doc(params.hogarId)
    .collection("presupuestos")
    .doc(presupuestoId);

  const movsSnap = await params.db
    .collection("hogares")
    .doc(params.hogarId)
    .collection("movimientos")
    .where("uid", "==", params.uid)
    .where("periodoId", "==", params.periodoId)
    .get();

  const movimientos = movsSnap.docs.map((d) => {
    const data = d.data();
    return {
      tipo: String(data.tipo ?? ""),
      monto: typeof data.monto === "number" ? data.monto : 0,
      estado: String(data.estado ?? "activo"),
      categoria: data.categoria as string | null | undefined,
    };
  });
  const total = sumarGastado(movimientos);

  return params.db.runTransaction(async (tx) => {
    const prepSnap = await tx.get(prepRef);
    if (!prepSnap.exists) return [];
    const prep = prepSnap.data()!;
    const monto = typeof prep.monto === "number" ? prep.monto : 0;
    const yaEnviadas = Array.isArray(prep.alertasEnviadas)
      ? (prep.alertasEnviadas as number[])
      : [];

    const nuevas = umbralesAlcanzados(total, monto, yaEnviadas);
    if (nuevas.length === 0) return [];

    const combinadas = Array.from(new Set([...yaEnviadas, ...nuevas])).sort(
      (a, b) => a - b
    );
    tx.update(prepRef, {
      alertasEnviadas: combinadas,
      actualizadoEn: FieldValue.serverTimestamp(),
    });
    return nuevas;
  });
}

/**
 * Job programado (cada 15 min Bogotá):
 * - Recordatorio diario a la hora elegida por cada usuario.
 * - Cuotas que vencen mañana y correcciones pendientes al admin: solo una vez
 *   al día en la franja HORA_AVISOS_HOGAR_BOGOTA (08:00–08:14 Bogotá).
 */
export async function ejecutarAvisosDiarios(
  db: Firestore,
  ahora: Date = new Date(),
  enviador: EnviadorPush = crearEnviadorFcm()
): Promise<{recordatorios: number; cuotas: number; correcciones: number}> {
  let recordatorios = 0;
  let cuotas = 0;
  let correcciones = 0;

  const usuariosSnap = await db.collection("usuarios").get();
  const candidatosRecordatorio: string[] = [];
  for (const doc of usuariosSnap.docs) {
    const data = doc.data();
    if (!data.hogarId) continue;
    if (
      coincideHoraRecordatorio({
        horaRecordatorio: data.horaRecordatorio as string | null,
        ahora,
      })
    ) {
      candidatosRecordatorio.push(doc.id);
    }
  }
  if (candidatosRecordatorio.length > 0) {
    recordatorios = await enviarAvisoAUids({
      db,
      uids: candidatosRecordatorio,
      tipo: "recordatorioDiario",
      payload: payloadRecordatorioDiario(),
      enviador,
    });
  }

  if (!enFranjaAvisosHogar(ahora)) {
    return {recordatorios, cuotas, correcciones};
  }

  const hogaresSnap = await db.collection("hogares").get();
  for (const hogarDoc of hogaresSnap.docs) {
    const hogarId = hogarDoc.id;
    const adminUid = String(hogarDoc.data()?.adminUid ?? "");

    const deudasSnap = await db
      .collection("hogares")
      .doc(hogarId)
      .collection("deudas")
      .where("estado", "==", "activa")
      .get();

    for (const deudaDoc of deudasSnap.docs) {
      const deuda = deudaDoc.data();
      const diaPago =
        typeof deuda.diaPago === "number" ? deuda.diaPago : 0;
      if (!cuotaVenceManana({diaPago, ahora})) continue;
      const entidad = String(deuda.entidad ?? "una deuda");
      // Aviso a todos los miembros activos del hogar.
      const n = await enviarAvisoAMiembrosHogar({
        db,
        hogarId,
        tipo: "cuotas",
        payload: payloadCuotaManana(entidad),
        enviador,
      });
      cuotas += n;
    }

    if (adminUid) {
      const pendSnap = await db
        .collection("hogares")
        .doc(hogarId)
        .collection("correcciones")
        .where("estado", "==", "pendiente")
        .limit(1)
        .get();
      if (!pendSnap.empty) {
        correcciones += await enviarAvisoAUids({
          db,
          uids: [adminUid],
          tipo: "correcciones",
          payload: payloadCorreccionPendiente(),
          enviador,
        });
      }
    }
  }

  return {recordatorios, cuotas, correcciones};
}
