# Nuestras Finanzas

Documento de producto (borrador post-entrevista).  
App móvil para finanzas del **hogar**, multiusuario, con foco en **transparencia** y claridad del estado financiero familiar.

---

## 1. Visión

Ayudar a un hogar a ver, en un solo lugar:

- Quién gasta y en qué
- Cuánto entra y cuánto sale
- Qué deudas pesan mes a mes
- Cuánto margen real queda
- Si el mes va en **verde** (superávit) o en **rojo** (déficit)

La idea no es “poner una camisa de fuerza”, sino transparentar las finanzas —como una dieta— para poder mejorarlas. Más adelante, un agente de IA podrá sugerir optimizaciones con base en esas cuentas.

**Nombre provisional:** Nuestras Finanzas  
**Stack previsto:** Flutter (móvil) · Firebase Auth · Cloud Firestore · Cloud Functions

---

## 2. Principios de diseño

1. **Hogar primero** — la unidad principal no es el individuo aislado, sino el hogar compartido.
2. **Transparencia sobre edición libre** — registrar mal y corregir a escondidas no debe ser fácil; las correcciones pasan por el admin.
3. **Claridad del mes** — al abrir la app se entiende el mes: gasto, ahorro/margen y categorías.
4. **Simplicidad en el MVP** — pocos roles, una moneda, flujos cortos; lo avanzado va a etapas posteriores.
5. **Base para IA** — los datos del hogar deben quedar estructurados para consejos futuros.

---

## 3. Usuarios y roles (MVP)

| Rol | Quién | Puede |
|-----|--------|--------|
| **Admin** | Quien crea el hogar (ej. cabeza de familia) | Crear hogar, invitar por QR, gestionar miembros, aprobar correcciones, registrar movimientos |
| **Miembro** | Pareja u otros adultos del hogar | Registrar gastos, ingresos y deudas del hogar; ver el estado del hogar; solicitar corrección al admin |

**Fuera del MVP (etapa 2+):** perfil “hijo” con autorización del padre/madre según madurez contable.

Todos los miembros activos pueden **registrar** movimientos. No hay diferenciación de “quién puede cargar” en el MVP.

---

## 4. Alcance del MVP

### Incluye

- Autenticación con **email/contraseña** (Firebase Auth)
- Crear un **hogar** (admin)
- Unirse a un hogar escaneando un **código QR**
- Registrar **gastos**, **ingresos** y **deudas del hogar**
- Deudas con entidad, monto total y **cuota mensual comprometida**
- Vista home del mes: total gastado, margen/ahorro, verde/rojo
- Desglose por **categorías**
- Moneda: **COP (pesos colombianos)** únicamente
- Solicitud de corrección → aprobación del **admin**

### No incluye (etapas posteriores)

- Multi-moneda
- Login social (Google, etc.)
- Metas de ahorro y gamificación / puntuación por “fidelidad”
- Perfil hijo / permisos por edad
- Deudas entre miembros (“Juan le debe a María”)
- Agente de IA para consejos y optimización
- Edición libre de movimientos históricos

---

## 5. Conceptos del dominio

### Hogar
Grupo familiar con un admin, varios miembros y un conjunto compartido de movimientos y deudas.

### Movimiento
Registro de dinero. Tipos en MVP:

- **Gasto** — salida (tienda, mercado, comida afuera, servicios, etc.)
- **Ingreso** — entrada (salario, otros)
- **Corrección** — ajuste aprobado por el admin tras una solicitud (no edición silenciosa)

Campos típicos de un movimiento:

- Monto (COP)
- Fecha
- Tipo (gasto / ingreso / corrección)
- Categoría (si aplica)
- Quién lo registró / a quién se atribuye
- Nota opcional
- Hogar al que pertenece

### Deuda del hogar
Obligación con una entidad externa (banco, tarjeta, etc.):

- Nombre / entidad
- Saldo o monto total
- **Cuota mensual comprometida**

Sirve para calcular el **margen de maniobra**:

> Ingresos del mes − gastos del mes − cuotas de deuda comprometidas ≈ disponible

Ejemplo: salario $5.000.000, cuota $1.000.000 → ~$4.000.000 de margen antes de otros gastos (el detalle fino lo define la lógica de reportes).

### Categorías (propuesta inicial)

Lista fija sugerida para el MVP (ajustable en implementación):

- Alimentación
- Servicios
- Transporte
- Vivienda
- Salud
- Educación
- Ocio / caprichos
- Otros

Objetivo: distinguir lo necesario de lo reducible.

> **Supuesto abierto:** categorías fijas al inicio; el admin podrá personalizarlas en una etapa siguiente si hace falta.

---

## 6. Flujos principales

### 6.1 Onboarding
1. Registro / login con email y contraseña
2. Crear hogar **o** unirse con QR
3. Entrar al home del hogar

### 6.2 Invitación por QR
1. El admin genera/muestra un QR del hogar
2. El otro usuario inicia sesión y escanea el QR
3. Queda vinculado como **miembro** de ese hogar

### 6.3 Registrar un gasto (o ingreso)
1. Miembro o admin abre “Nuevo movimiento”
2. Elige tipo, monto, categoría, fecha, nota
3. Se guarda y se refleja en el mes del hogar

### 6.4 Registrar / actualizar una deuda
1. Se indica entidad, monto y cuota mensual
2. La cuota entra en el cálculo de margen del mes

### 6.5 Corrección (transparencia)
1. Quien detecta un error solicita corrección (motivo + valor propuesto)
2. El admin revisa y aprueba o rechaza
3. Si aprueba, queda el ajuste trazable (no un “borrado mágico”)

### 6.6 Home del mes
Al abrir la app se ve, como mínimo:

- Total gastado en el mes
- Si hubo ahorro / superávit o déficit (verde / rojo)
- En qué categorías se va el dinero
- Contexto de margen según ingresos y cuotas de deuda

---

## 7. Indicadores del MVP (home)

| Indicador | Descripción |
|-----------|-------------|
| Gasto del mes | Suma de gastos del período |
| Ingresos del mes | Suma de ingresos del período |
| Cuotas comprometidas | Suma de cuotas mensuales de deudas activas |
| Resultado / margen | Lectura verde o roja del mes |
| Por categoría | Distribución del gasto para detectar “caprichos” vs. necesidades |

Patrimonio / posición financiera (visión): combinación de ingresos, gastos, deudas y resultado del período — sin pretender un balance contable completo en el MVP.

---

## 8. Arquitectura prevista

```
Flutter (iOS + Android)
        │
        ▼
Firebase Auth  ──  email/contraseña
        │
        ├── Cloud Firestore  (hogares, miembros, movimientos, deudas, solicitudes)
        └── Cloud Functions  (reglas de negocio sensibles: invitaciones, correcciones, agregados)
```

- **Cliente:** UI, escaneo QR, formularios, vistas de resumen
- **Firestore:** modelo documental del hogar y sus datos
- **Cloud Functions:** operaciones que no deben confiar solo en el cliente (ej. aceptar corrección, vincular por QR, cálculos agregados si aplica)
- **Security Rules:** un usuario solo ve/escribe en su hogar; solo el admin aprueba correcciones

> **Supuesto abierto:** Flutter apunta a **Android e iOS** desde el inicio.

---

## 9. Roadmap orientativo

### Etapa 1 — MVP (este documento)
Hogar, QR, auth email, gastos/ingresos/deudas, categorías, home verde/rojo, correcciones vía admin.

### Etapa 2 — Hábitos y motivación
Metas de ahorro, puntuación / fidelidad familiar, categorías editables, perfil hijo con autorización.

### Etapa 3 — Alcance
Multi-moneda, más métodos de login, deudas entre miembros (opcional).

### Etapa 4 — Inteligencia
Agente de IA que lea cuentas del hogar y dé consejos para optimizar gastos y mejorar finanzas.

---

## 10. Criterios de éxito del MVP

- Una familia de 2+ personas puede crear hogar, unirse por QR y cargar movimientos en menos de unos minutos.
- El home responde: “¿cómo vamos este mes?” sin abrir hojas de cálculo.
- No se puede reescribir el historial a fin de mes sin pasar por el admin.
- Las cuotas de deuda se reflejan en el margen disponible.
- Los datos quedan listos para reportes y, luego, para un agente de IA.

---

## 11. Decisiones abiertas / supuestos

| Tema | Estado |
|------|--------|
| Nombre “Nuestras Finanzas” | Provisional |
| Categorías fijas vs. editables por admin | Fijas en MVP (propuesta) |
| Plataformas | Android + iOS (supuesto) |
| Un hogar por usuario vs. varios | Un hogar activo en MVP (supuesto) |
| Foto de recibo / adjuntos | Fuera de MVP salvo que se priorice |
| Período del “mes” (calendario vs. personalizado) | Mes calendario (supuesto) |

---

## 12. Próximos pasos sugeridos

1. Validar este documento (nombre, categorías, supuestos de la §11)
2. Definir modelo de datos Firestore (colecciones y campos)
3. Bocetar pantallas: onboarding, home, nuevo movimiento, deudas, correcciones, QR
4. Scaffold del proyecto Flutter + Firebase
5. Implementar MVP por vertical slices (auth → hogar/QR → movimientos → home → correcciones)

---

*Última actualización: borrador tras entrevista inicial con el product owner.*
