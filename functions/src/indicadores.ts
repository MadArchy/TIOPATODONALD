/**
 * Indicadores puros (espejo de `app/lib/core/indicadores.dart`).
 */

export const CATEGORIAS_REDUCIBLES = new Set(["ocio", "otros"]);

export interface MovimientoIndicador {
  tipo: string;
  monto: number;
  estado: string;
  categoria?: string | null;
  deudaId?: string | null;
}

export function gastado(movimientos: MovimientoIndicador[]): number {
  let total = 0;
  for (const m of movimientos) {
    if (m.estado !== "activo") continue;
    if (m.tipo === "gasto" || m.tipo === "pagoCuota") {
      total += m.monto;
    }
  }
  return total;
}

export function ingresos(movimientos: MovimientoIndicador[]): number {
  let total = 0;
  for (const m of movimientos) {
    if (m.estado !== "activo") continue;
    if (m.tipo === "ingreso") {
      total += m.monto;
    }
  }
  return total;
}

export function semaforo(
  g: number,
  presupuesto: number
): "verde" | "rojo" {
  return g <= presupuesto ? "verde" : "rojo";
}

export function porcentajeReducible(
  movimientos: MovimientoIndicador[],
  g: number
): number {
  if (g <= 0) return 0;
  let reducible = 0;
  for (const m of movimientos) {
    if (m.estado !== "activo") continue;
    if (m.tipo !== "gasto") continue;
    if (m.categoria && CATEGORIAS_REDUCIBLES.has(m.categoria)) {
      reducible += m.monto;
    }
  }
  return reducible / g;
}

export function gastadoPorCategoria(
  movimientos: MovimientoIndicador[]
): Record<string, number> {
  const map: Record<string, number> = {};
  for (const m of movimientos) {
    if (m.estado !== "activo") continue;
    if (m.tipo === "gasto") {
      const cat = m.categoria ?? "otros";
      map[cat] = (map[cat] ?? 0) + m.monto;
    } else if (m.tipo === "pagoCuota") {
      map.pagoCuota = (map.pagoCuota ?? 0) + m.monto;
    }
  }
  return map;
}
