# Preguntas de implementación — Nuestras Finanzas

Documento para responder y cerrar brechas del MVP antes de codear.  
Basado en `PRODUCTO.md`.

**Cómo usarlo:** escribe la respuesta debajo de cada pregunta (o marca la opción elegida).  
Cuando esté completo, usamos esto para definir modelo Firestore, pantallas y orden de implementación.

---

## 1. Producto / reglas de negocio

### 1.1 Fórmula del mes (verde / rojo)

¿El resultado del mes es `ingresos − gastos − suma de cuotas`, o las cuotas solo son contexto y el verde/rojo es solo `ingresos − gastos`?

**Respuesta:**



### 1.2 Doble conteo: cuota vs gasto de pago

Si alguien registra un gasto “pago de cuota” y también existe la deuda con cuota mensual, ¿contamos dos veces, lo prohibimos, o usamos una categoría/regla especial?

**Respuesta:**



### 1.3 Atribución del movimiento

En un movimiento, ¿necesitamos distinguir “quién lo registró” de “a quién se atribuye el gasto/ingreso”?

- [ ] Solo quién lo registró
- [ ] Ambos campos (registró + atribuido a)
- [ ] Otra:

**Respuesta:**



### 1.4 Qué se puede corregir

¿Qué permite una solicitud de corrección?

- [ ] Cambiar monto
- [ ] Cambiar categoría
- [ ] Cambiar fecha
- [ ] Cambiar nota
- [ ] Anular / invalidar el movimiento
- [ ] Otra:

**Respuesta:**



### 1.5 Cómo se ve el historial tras corregir

Si el admin aprueba una corrección, ¿cómo queda el historial?

- [ ] Original + ajuste trazable (ambos visibles)
- [ ] Se reemplaza el valor pero queda log de auditoría
- [ ] Otra:

**Respuesta:**



### 1.6 Quién gestiona deudas

¿Quién puede crear / editar / desactivar deudas del hogar?

- [ ] Solo admin
- [ ] Cualquier miembro
- [ ] Crear: cualquier miembro / editar o borrar: solo admin
- [ ] Otra:

**Respuesta:**



### 1.7 Pago de cuota y saldo de deuda

¿Hay un flujo de “pago de cuota” que reduzca el saldo de la deuda, o en el MVP la deuda es solo informativa (entidad + total + cuota) sin bajar saldo?

**Respuesta:**



### 1.8 Categorías del MVP

¿Confirmamos esta lista fija, o hay cambios antes de implementar?

- Alimentación
- Servicios
- Transporte
- Vivienda
- Salud
- Educación
- Ocio / caprichos
- Otros

**Respuesta (confirmar o editar lista):**



### 1.9 Ingresos: ¿también van por categoría?

¿Los ingresos usan categorías (salario, otros, etc.) o solo los gastos?

**Respuesta:**



### 1.10 Fecha del movimiento

¿Se puede registrar un movimiento con fecha de otro mes (atrasado / adelantado)?

**Respuesta:**



---

## 2. Roles y hogar

### 2.1 Cantidad de admins

¿Solo un admin por hogar en el MVP?

- [ ] Sí, un solo admin
- [ ] No, varios admins
- [ ] Otra:

**Respuesta:**



### 2.2 Transferir el rol admin

¿Se puede transferir el admin a otro miembro? ¿Qué pasa si el admin se va o pierde acceso?

**Respuesta:**



### 2.3 Salir del hogar

¿Un miembro puede salir del hogar? ¿Qué pasa con los movimientos que registró?

- [ ] No puede salir en MVP
- [ ] Puede salir; movimientos se quedan en el hogar
- [ ] Puede salir; otra regla:

**Respuesta:**



### 2.4 Usuario ya en un hogar + nuevo QR

Si alguien escanea el QR de un hogar pero ya está en otro, ¿qué hacemos?

- [ ] Error: un hogar activo por usuario
- [ ] Debe salir del actual antes de unirse
- [ ] Puede pertenecer a varios (rompe supuesto MVP)
- [ ] Otra:

**Respuesta:**



### 2.5 Usuario sin hogar

Después del login, si no tiene hogar: ¿obligatorio crear o unirse antes de usar la app?

**Respuesta:**



### 2.6 Caducidad / límites del QR

¿El QR de invitación expira o tiene límites?

- [ ] No expira
- [ ] Expira por tiempo (¿cuánto?)
- [ ] Un solo uso
- [ ] Se puede regenerar / invalidar el anterior
- [ ] Otra:

**Respuesta:**



### 2.7 Quién genera el QR

¿Solo el admin genera/muestra el QR?

**Respuesta:**



---

## 3. Home e indicadores

### 3.1 Qué debe verse sí o sí en el primer viewport del home

Confirmar o ajustar la lista mínima:

- Total gastado del mes
- Ingresos del mes
- Cuotas comprometidas
- Resultado / margen (verde o rojo)
- Desglose por categorías

**Respuesta:**



### 3.2 Definición de “verde” y “rojo”

¿Verde = margen ≥ 0 y rojo = margen < 0? ¿Hay umbral (ej. verde solo si ahorras X)?

**Respuesta:**



### 3.3 Período del mes

¿Confirmamos mes calendario (1–último día), o hay otro corte (ej. día de pago)?

**Respuesta:**



### 3.4 Zona horaria

¿Todo en hora Colombia (America/Bogota)?

**Respuesta:**



---

## 4. Técnica y entrega

### 4.1 Plataformas

¿Android primero, o iOS + Android desde el día 1?

- [ ] Android primero
- [ ] iOS + Android juntos
- [ ] Otra:

**Respuesta:**



### 4.2 Cálculo de agregados del home

¿Cómo calculamos totales del mes?

- [ ] En el cliente (sumar movimientos al leer)
- [ ] Cloud Function al escribir (actualizar documento resumen)
- [ ] Documento de resumen en Firestore mantenido por rules/functions
- [ ] Decidir después del primer slice
- [ ] Otra:

**Respuesta:**



### 4.3 Proyecto Firebase

¿Ya existe proyecto Firebase / cuenta, o partimos de cero?

**Respuesta:**



### 4.4 Entorno y acceso

¿Quién tendrá acceso a Firebase Console, App Store / Play Console (si aplica)?

**Respuesta:**



### 4.5 Offline

¿El MVP debe funcionar sin internet (cache / cola de escritura), o solo online?

- [ ] Solo online
- [ ] Lectura offline básica
- [ ] Lectura + escritura offline
- [ ] Otra:

**Respuesta:**



### 4.6 Auth

¿Confirmamos solo email/contraseña en MVP (sin Google u otros)?

**Respuesta:**



### 4.7 Recuperación de contraseña

¿Incluimos “olvidé mi contraseña” en el MVP?

**Respuesta:**



### 4.8 Orden de implementación preferido

- [ ] Vertical slice: auth → hogar/QR → un movimiento → home → deudas → correcciones
- [ ] Pantallas mock / UI primero, luego Firebase
- [ ] Modelo de datos + rules primero, luego UI
- [ ] Otra:

**Respuesta:**



---

## 5. Validación y éxito

### 5.1 Usuario piloto

¿Quién prueba el MVP primero? (ej. una pareja concreta, familia, solo product owner)

**Respuesta:**



### 5.2 Criterio “listo para probar”

¿Qué debe funcionar sí o sí para la primera prueba con usuarios reales?

**Respuesta:**



### 5.3 Tiempo objetivo de onboarding

El doc dice “en menos de unos minutos”. ¿Cuál es el número concreto que queremos medir? (ej. < 3 min crear hogar + invitar + primer gasto)

**Respuesta:**



### 5.4 Nombre de la app

¿Seguimos con “Nuestras Finanzas” para el MVP o hay otro nombre candidato?

**Respuesta:**



---

## 6. Alcance: qué entra / qué queda fuera (confirmación)

Marca si confirmas el supuesto del `PRODUCTO.md` o lo cambias.

| Tema | Supuesto actual | ¿OK? | Si no, ¿qué cambia? |
|------|-----------------|------|---------------------|
| Moneda solo COP | Sí | [ ] OK / [ ] Cambiar | |
| Un hogar activo por usuario | Sí | [ ] OK / [ ] Cambiar | |
| Sin login social | Sí | [ ] OK / [ ] Cambiar | |
| Sin foto de recibo | Sí | [ ] OK / [ ] Cambiar | |
| Sin metas / gamificación | Sí | [ ] OK / [ ] Cambiar | |
| Sin perfil hijo | Sí | [ ] OK / [ ] Cambiar | |
| Sin deudas entre miembros | Sí | [ ] OK / [ ] Cambiar | |
| Sin agente IA en MVP | Sí | [ ] OK / [ ] Cambiar | |
| Categorías fijas | Sí | [ ] OK / [ ] Cambiar | |
| Mes calendario | Sí | [ ] OK / [ ] Cambiar | |

---

## 7. Riesgos y preferencias al ejecutar

### 7.1 Transparencia vs velocidad

Si hay muchos errores tipográficos, ¿preferimos fricción (todo vía admin) o permitir ediciones menores sin aprobación?

**Respuesta:**



### 7.2 Qué preferimos sacrificar si hay que recortar el MVP

Ordena del 1 (no sacrificar) al N (se puede sacar):

- [ ] Invitación por QR
- [ ] Deudas + cuotas en el margen
- [ ] Correcciones vía admin
- [ ] Desglose por categorías
- [ ] Home verde/rojo completo
- [ ] Otro:

**Respuesta (prioridad):**



### 7.3 Mayor miedo al implementar

¿Qué te preocupa más: seguridad, usabilidad familiar, cálculos incorrectos, tiempo de entrega, otro?

**Respuesta:**



---

## Cierre

Cuando termines de responder:

1. Avisa para revisar respuestas.
2. Consolidamos decisiones abiertas de la §11 de `PRODUCTO.md`.
3. Bajamos a: modelo Firestore → pantallas → scaffold Flutter + Firebase.

*Archivo generado para taller de definición de implementación.*
