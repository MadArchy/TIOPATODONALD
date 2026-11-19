# Entrevista de implementación — Índice

Producto: **PATO DONALD**  
Cuestionario base: `PREGUNTAS_IMPLEMENTACION.md`  
Documento de producto original: `PRODUCTO.md`

---

## Archivos por sección

| # | Sección | Archivo |
|---|---------|---------|
| 1 | Producto y reglas de negocio | `ENTREVISTA_SECCION_01_PRODUCTO.md` |
| 2 | Roles y hogar | `ENTREVISTA_SECCION_02_ROLES_HOGAR.md` |
| 3 | Home e indicadores | `ENTREVISTA_SECCION_03_HOME.md` |
| 4 | Técnica y entrega | `ENTREVISTA_SECCION_04_TECNICA.md` |
| 5 | Validación y éxito | `ENTREVISTA_SECCION_05_VALIDACION.md` |
| 6 | Confirmación de alcance | `ENTREVISTA_SECCION_06_ALCANCE.md` |
| 7 | Riesgos y preferencias | `ENTREVISTA_SECCION_07_RIESGOS.md` |

---

## Decisiones que cambian el borrador original

1. Nombre: **PATO DONALD** (antes “Nuestras Finanzas”)
2. Semáforo por **presupuesto personal**, no solo ingresos − gastos − cuotas
3. Cada usuario define presupuesto; admin ve **dashboard**
4. **Período personalizado** (día de inicio por usuario), no mes calendario
5. **Foto de recibo** entra al MVP
6. **Deudas entre miembros** entra al MVP
7. Ediciones **menores sin aprobación** del admin
8. Android primero; offline lectura+escritura; agregados en cliente
9. Piloto: familia; debe funcionar todo el MVP
10. Miedo principal: **usabilidad familiar**

---

## Próximo paso sugerido

Consolidar estas respuestas en una actualización de `PRODUCTO.md` o un `DECISIONES_MVP.md`, y luego bajar a modelo Firestore + vertical slice (auth → hogar/QR → movimiento → home → deudas → correcciones).
