/**
 * Lógica pura de períodos en America/Bogota (UTC-5).
 * Espejo de `app/lib/core/periodo.dart` (`docs/02_reglas_negocio.md` §1).
 */

export interface Periodo {
  inicio: Date; // componentes locales Bogotá 00:00:00.000
  fin: Date; // 23:59:59.999
  periodoId: string; // YYYY-MM-DD
  diasTotales: number;
}

/** Interpreta un instante en hora de Bogotá (UTC-5). */
export function aHoraBogota(instante: Date): Date {
  // Trabajamos con componentes UTC del instante y restamos 5 h.
  const ms = instante.getTime() - 5 * 60 * 60 * 1000;
  const bogota = new Date(ms);
  return new Date(
    Date.UTC(
      bogota.getUTCFullYear(),
      bogota.getUTCMonth(),
      bogota.getUTCDate(),
      bogota.getUTCHours(),
      bogota.getUTCMinutes(),
      bogota.getUTCSeconds(),
      bogota.getUTCMilliseconds()
    )
  );
}

function formatearFechaId(y: number, m: number, d: number): string {
  const yy = String(y).padStart(4, "0");
  const mm = String(m).padStart(2, "0");
  const dd = String(d).padStart(2, "0");
  return `${yy}-${mm}-${dd}`;
}

/** Componentes calendario (año, mes 1-12, día) en Bogotá. */
export function componentesBogota(instante: Date): {
  year: number;
  month: number;
  day: number;
} {
  const ms = instante.getTime() - 5 * 60 * 60 * 1000;
  const b = new Date(ms);
  return {
    year: b.getUTCFullYear(),
    month: b.getUTCMonth() + 1,
    day: b.getUTCDate(),
  };
}

export function periodoDe(instante: Date, diaInicio: number): Periodo {
  if (diaInicio < 1 || diaInicio > 28) {
    throw new Error("El día de inicio del período debe estar entre 1 y 28.");
  }

  const bogota = componentesBogota(instante);
  let anioInicio: number;
  let mesInicio: number;

  if (bogota.day >= diaInicio) {
    anioInicio = bogota.year;
    mesInicio = bogota.month;
  } else if (bogota.month === 1) {
    anioInicio = bogota.year - 1;
    mesInicio = 12;
  } else {
    anioInicio = bogota.year;
    mesInicio = bogota.month - 1;
  }

  const anioSiguiente = mesInicio === 12 ? anioInicio + 1 : anioInicio;
  const mesSiguiente = mesInicio === 12 ? 1 : mesInicio + 1;

  // Fechas "locales Bogotá" representadas como UTC calendar puro.
  const inicio = new Date(Date.UTC(anioInicio, mesInicio - 1, diaInicio, 0, 0, 0, 0));
  const inicioSiguiente = new Date(
    Date.UTC(anioSiguiente, mesSiguiente - 1, diaInicio, 0, 0, 0, 0)
  );
  const fin = new Date(inicioSiguiente.getTime() - 1);

  const diasTotales = Math.round(
    (inicioSiguiente.getTime() - inicio.getTime()) / (24 * 60 * 60 * 1000)
  );

  return {
    inicio,
    fin,
    periodoId: formatearFechaId(anioInicio, mesInicio, diaInicio),
    diasTotales,
  };
}

export function diasTranscurridos(p: Periodo, hoy: Date): number {
  const b = componentesBogota(hoy);
  const hoyCal = Date.UTC(b.year, b.month - 1, b.day);
  const inicioCal = Date.UTC(
    p.inicio.getUTCFullYear(),
    p.inicio.getUTCMonth(),
    p.inicio.getUTCDate()
  );
  const finCal = Date.UTC(
    p.fin.getUTCFullYear(),
    p.fin.getUTCMonth(),
    p.fin.getUTCDate()
  );

  if (hoyCal < inicioCal) return 0;
  if (hoyCal > finCal) return p.diasTotales;
  return Math.floor((hoyCal - inicioCal) / (24 * 60 * 60 * 1000)) + 1;
}

export function periodoAnteriorDe(actual: Periodo): Periodo {
  const diaInicio = actual.inicio.getUTCDate();
  const instanteAnterior = new Date(actual.inicio.getTime() - 24 * 60 * 60 * 1000);
  // instanteAnterior está en UTC calendar del inicio; sumamos 5h para que
  // componentesBogota lo interprete como el día anterior en Bogotá.
  const comoUtcReal = new Date(instanteAnterior.getTime() + 5 * 60 * 60 * 1000);
  return periodoDe(comoUtcReal, diaInicio);
}
