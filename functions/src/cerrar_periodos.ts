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
 * - Si un miembro está en el día 1 de su período actual, genera el resumen del período anterior.
 * - Si tiene `diaInicioPendiente = Dnuevo`:
 *   - Al cerrar el período viejo (día Dviejo), si hoy aún no es Dnuevo, inicia un **período puente**
 *     (`enPuenteHastaDia: Dnuevo`) copiando el presupuesto vigente para no bloquear la app.
 *   - Al llegar el día Dnuevo (`hoyDia === Dnuevo`) estando en puente (o si hoy mismo coincide con el cierre),
 *     cierra el período puente, aplica `diaInicioPeriodo = Dnuevo`, guarda `diaInicioAnterior = Dviejo`
 *     (para tolerar escrituras offline en transición), limpia `diaInicioPendiente` y asegura el
 *     presupuesto del nuevo período copiando el vigente si aún no existe.
 */
export async function ejecutarCerrarPeriodos(
  db: Firestore,
  now: Date = new Date()
): Promise<CerrarPeriodosResultado> {
  const hogaresSnap = await db.collection("hogares").get();
  let resumenesCreados = 0;
  let diasPendientesAplicados = 0;

  // Día calendario actual en América/Bogotá (UTC-5, sin horario de verano).
  const bogota = new Date(now.getTime() - 5 * 3600_000);
  const hoyDiaBogota = bogota.getUTCDate();

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
      const enPuente = usuario.enPuentePeriodo === true;

      const periodoActual = periodoDe(now, diaInicio);
      const transcurridos = diasTranscurridos(periodoActual, now);

      // 1) Primer día del período según diaInicio actual: cerrar el anterior.
      if (transcurridos === 1) {
        const anterior = periodoAnteriorDe(periodoActual);
        const creado = await asegurarResumenPeriodo({
          db,
          hogarId,
          uid,
          periodoId: anterior.periodoId,
        });
        if (creado) resumenesCreados += 1;

        if (
          pendiente != null &&
          pendiente >= 1 &&
          pendiente <= 28 &&
          pendiente !== diaInicio
        ) {
          if (hoyDiaBogota === pendiente) {
            // Coincide justo hoy con el día nuevo: aplicar de inmediato.
            await usuarioRef.update({
              diaInicioPeriodo: pendiente,
              diaInicioAnterior: diaInicio,
              diaInicioPendiente: null,
              enPuentePeriodo: false,
            });
            const nuevoPeriodo = periodoDe(now, pendiente);
            await asegurarPresupuestoCopiado({
              db,
              hogarId,
              uid,
              desdePeriodoId: anterior.periodoId,
              haciaPeriodoId: nuevoPeriodo.periodoId,
            });
            diasPendientesAplicados += 1;
          } else {
            // Arranca período puente (Dviejo .. Dnuevo-1) con el presupuesto copiado.
            await usuarioRef.update({
              enPuentePeriodo: true,
            });
            await asegurarPresupuestoCopiado({
              db,
              hogarId,
              uid,
              desdePeriodoId: anterior.periodoId,
              haciaPeriodoId: periodoActual.periodoId,
            });
          }
        }
        continue;
      }

      // 2) Fin del período puente: hoy es el día D nuevo.
      if (
        enPuente &&
        pendiente != null &&
        pendiente >= 1 &&
        pendiente <= 28 &&
        pendiente !== diaInicio &&
        hoyDiaBogota === pendiente
      ) {
        const creado = await asegurarResumenPeriodo({
          db,
          hogarId,
          uid,
          periodoId: periodoActual.periodoId,
        });
        if (creado) resumenesCreados += 1;

        await usuarioRef.update({
          diaInicioPeriodo: pendiente,
          diaInicioAnterior: diaInicio,
          diaInicioPendiente: null,
          enPuentePeriodo: false,
        });

        const nuevoPeriodo = periodoDe(now, pendiente);
        await asegurarPresupuestoCopiado({
          db,
          hogarId,
          uid,
          desdePeriodoId: periodoActual.periodoId,
          haciaPeriodoId: nuevoPeriodo.periodoId,
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

async function asegurarPresupuestoCopiado(args: {
  db: Firestore;
  hogarId: string;
  uid: string;
  desdePeriodoId: string;
  haciaPeriodoId: string;
}): Promise<void> {
  const {db, hogarId, uid, desdePeriodoId, haciaPeriodoId} = args;
  const col = db.collection("hogares").doc(hogarId).collection("presupuestos");
  const destinoRef = col.doc(`${uid}_${haciaPeriodoId}`);
  const destinoSnap = await destinoRef.get();
  if (destinoSnap.exists) return;

  const origenSnap = await col.doc(`${uid}_${desdePeriodoId}`).get();
  const monto = origenSnap.data()?.monto;
  if (typeof monto === "number" && Number.isInteger(monto) && monto > 0) {
    await destinoRef.set({
      uid,
      periodoId: haciaPeriodoId,
      monto,
      alertasEnviadas: [],
      actualizadoEn: FieldValue.serverTimestamp(),
    });
  }
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
