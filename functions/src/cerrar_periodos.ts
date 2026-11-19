import {Firestore, FieldValue} from "firebase-admin/firestore";
import {
  diasTranscurridos,
  periodoAnteriorDe,
  periodoDe,
} from "./periodo";
import {
  gastado,
  gastadoPorCategoria,
  ingresos,
  MovimientoIndicador,
  porcentajeReducible,
  semaforo,
} from "./indicadores";

export interface CerrarPeriodosResultado {
  hogaresRevisados: number;
  resumenesCreados: number;
  diasPendientesAplicados: number;
}

/**
 * Job diario (~00:30 América/Bogotá):
 * - Si un miembro está en el día 1 de su período, genera el resumen del período anterior.
 * - Aplica `diaInicioPendiente` → `diaInicioPeriodo` y limpia el pendiente.
 */
export async function ejecutarCerrarPeriodos(
  db: Firestore,
  now: Date = new Date()
): Promise<CerrarPeriodosResultado> {
  const hogaresSnap = await db.collection("hogares").get();
  let resumenesCreados = 0;
  let diasPendientesAplicados = 0;

  for (const hogarDoc of hogaresSnap.docs) {
    const hogarId = hogarDoc.id;
    const miembrosSnap = await hogarDoc.ref
      .collection("miembros")
      .where("estado", "==", "activo")
      .get();

    for (const miembroDoc of miembrosSnap.docs) {
      const uid = miembroDoc.id;
      const usuarioRef = db.collection("usuarios").doc(uid);
      const usuarioSnap = await usuarioRef.get();
      if (!usuarioSnap.exists) continue;

      const usuario = usuarioSnap.data()!;
      if (usuario.hogarId !== hogarId) continue;

      const diaInicio =
        typeof usuario.diaInicioPeriodo === "number"
          ? usuario.diaInicioPeriodo
          : 1;
      const pendiente =
        typeof usuario.diaInicioPendiente === "number"
          ? usuario.diaInicioPendiente
          : null;

      const periodoActual = periodoDe(now, diaInicio);
      const transcurridos = diasTranscurridos(periodoActual, now);

      // Solo el primer día del nuevo período genera el cierre del anterior.
      if (transcurridos === 1) {
        const anterior = periodoAnteriorDe(periodoActual);
        const creado = await asegurarResumenPeriodo({
          db,
          hogarId,
          uid,
          periodoId: anterior.periodoId,
        });
        if (creado) resumenesCreados += 1;
      }

      if (
        pendiente != null &&
        pendiente >= 1 &&
        pendiente <= 28 &&
        pendiente !== diaInicio &&
        transcurridos === 1
      ) {
        await usuarioRef.update({
          diaInicioPeriodo: pendiente,
          diaInicioPendiente: null,
        });
        diasPendientesAplicados += 1;
      }
    }
  }

  return {
    hogaresRevisados: hogaresSnap.size,
    resumenesCreados,
    diasPendientesAplicados,
  };
}

async function asegurarResumenPeriodo(args: {
  db: Firestore;
  hogarId: string;
  uid: string;
  periodoId: string;
}): Promise<boolean> {
  const {db, hogarId, uid, periodoId} = args;
  const resumenId = `${uid}_${periodoId}`;
  const resumenRef = db
    .collection("hogares")
    .doc(hogarId)
    .collection("resumenes")
    .doc(resumenId);

  const existente = await resumenRef.get();
  if (existente.exists) {
    return false; // idempotente
  }

  const movsSnap = await db
    .collection("hogares")
    .doc(hogarId)
    .collection("movimientos")
    .where("uid", "==", uid)
    .where("periodoId", "==", periodoId)
    .get();

  const movimientos: MovimientoIndicador[] = movsSnap.docs.map((d) => {
    const data = d.data();
    return {
      tipo: String(data.tipo ?? ""),
      monto: typeof data.monto === "number" ? data.monto : 0,
      estado: String(data.estado ?? "activo"),
      categoria: data.categoria ?? null,
      deudaId: data.deudaId ?? null,
    };
  });

  const prepSnap = await db
    .collection("hogares")
    .doc(hogarId)
    .collection("presupuestos")
    .doc(`${uid}_${periodoId}`)
    .get();
  const presupuesto =
    typeof prepSnap.data()?.monto === "number" ? prepSnap.data()!.monto : 0;

  const g = gastado(movimientos);
  const ing = ingresos(movimientos);
  const sem = semaforo(g, presupuesto);
  const porCat = gastadoPorCategoria(movimientos);
  const reducible = porcentajeReducible(movimientos, g);

  // Variación vs resumen anterior (si existe).
  let variacionVsAnterior: Record<string, unknown> = {};
  try {
    const periodoCerrado = periodoDe(
      // Instantáneo al inicio del período cerrado (mediodía Bogotá ≈ 17:00 UTC)
      new Date(`${periodoId}T17:00:00.000Z`),
      Number(periodoId.slice(8, 10))
    );
    const ant = periodoAnteriorDe(periodoCerrado);
    const antSnap = await db
      .collection("hogares")
      .doc(hogarId)
      .collection("resumenes")
      .doc(`${uid}_${ant.periodoId}`)
      .get();
    if (antSnap.exists) {
      const antData = antSnap.data()!;
      const gastadoAnt =
        typeof antData.gastado === "number" ? antData.gastado : 0;
      variacionVsAnterior = {
        gastadoAnterior: gastadoAnt,
        diferenciaGastado: g - gastadoAnt,
      };
    }
  } catch {
    variacionVsAnterior = {};
  }

  await resumenRef.set({
    uid,
    periodoId,
    gastado: g,
    ingresos: ing,
    presupuesto,
    semaforo: sem,
    porCategoria: porCat,
    porcentajeReducible: reducible,
    variacionVsAnterior,
    creadoEn: FieldValue.serverTimestamp(),
  });

  return true;
}
