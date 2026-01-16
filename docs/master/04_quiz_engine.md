# 04 — Quiz Engine (Motor de Evaluaciones)

## Propósito del documento

Definir de forma **precisa, cerrada y no ambigua**:

- Cómo funcionan los quizzes de unidad y el examen final
- Cómo se seleccionan las preguntas desde el pool
- Cómo se gestionan intentos, bloqueos y resets
- Cómo se registra el histórico y el detalle por pregunta
- Qué feedback recibe el aprendiz y cuándo
- Qué datos se generan para analytics

Este documento es **crítico**:
si el Quiz Engine es inconsistente o ambiguo, **el producto pierde credibilidad**.

---

## Principio rector

> **Las preguntas no pertenecen a los exámenes.
> Pertenecen a las Unidades.**

Los quizzes:

- **seleccionan** preguntas
- **no las contienen**
- **no duplican contenido**

---

## Tipos de evaluación

### 1. Quiz de Unidad

- Asociado a una única Unidad
- Usa únicamente el pool de esa unidad
- Se puede rendir múltiples veces (con reglas)

### 2. Quiz Final de Curso

- Asociado a un Curso
- Usa preguntas de **todas las unidades**
- Se desbloquea solo al aprobar todos los quizzes de unidad
- Es obligatorio para aprobar el curso

Ambos tipos usan **el mismo motor**, con distinta configuración.

---

## Entidades lógicas del Quiz Engine

### 1. Pool de Preguntas (`question_bank`)

- Asociado a `unit_id`
- Cada pregunta incluye:
  - Prompt
  - 4 opciones
  - Opción correcta
  - Dificultad
  - Explicación (obligatoria)
  - Anclaje conceptual dentro de la unidad

---

### 2. Estado del Quiz (`quiz_state`)

Representa el **estado actual** de un usuario frente a un quiz.

Campos conceptuales:

- Usuario
- Tipo (`unit` / `final`)
- Unidad o Curso
- Cantidad de intentos usados
- Cantidad total de intentos históricos
- Estado:
  - `available`
  - `cooldown`
  - `blocked`

- `blocked_until` (si aplica)

> Esta tabla es **mutable** y representa el “ahora”.

---

### 3. Sesión de Quiz (`quiz_sessions`)

Representa **un intento concreto**.

- Se crea al iniciar un quiz
- Contiene:
  - Usuario
  - Tipo de quiz
  - Unidad / Curso
  - Lista fija de preguntas seleccionadas
  - Configuración del intento:
    - distribución de dificultad
    - tiempo límite
    - pass score

- Es **inmutable**

> Permite saber exactamente **qué preguntas vio el usuario en ese intento**.

---

### 4. Intento de Quiz (`quiz_attempts`)

Representa el **resultado agregado** del intento.

- Asociado a una `quiz_session`
- Contiene:
  - Score final
  - Aprobado / Reprobado
  - Duración real
  - Fecha

- Es **inmutable**

---

### 5. Registro por Pregunta (`quiz_answers_log`)

Registro granular, **una fila por pregunta respondida**.

Incluye:

- Usuario
- Pregunta
- Sesión
- Respuesta seleccionada
- Correcta / Incorrecta
- Tiempo de respuesta (opcional)
- Dificultad
- Anclaje conceptual

> Esta tabla es la base de **toda la inteligencia analítica** del sistema.

---

## Selección de preguntas (algoritmo)

### Objetivos

1. Maximizar cobertura del pool
2. Minimizar repetición entre intentos
3. Respetar distribución de dificultad

### Reglas

- Para cada intento:
  1. Seleccionar primero preguntas **no vistas** por el usuario en ese scope
  2. Si no alcanza:
     - completar con preguntas vistas

  3. Aplicar distribución por dificultad configurada

- Intentos consecutivos deben mostrar:
  - la mayoría de preguntas distintas
  - idealmente todas distintas si el pool lo permite

### Definición de “no vista”

Una pregunta sin registros previos en `quiz_answers_log` para:

- ese usuario
- ese tipo de quiz
- esa unidad (o curso, en final)

---

## Configuración de un Quiz

Tanto quizzes de unidad como final permiten configurar:

- Cantidad de preguntas
- Distribución por dificultad
- Puntaje mínimo de aprobación
- Tiempo límite (obligatorio en final, opcional en unidad)

Estas configuraciones:

- Se guardan en la `quiz_session`
- No cambian durante el intento

---

## Flujo de UX del Aprendiz (evaluación)

### Inicio del Quiz

- El sistema valida:
  - estado (`quiz_state`)
  - cooldown
  - bloqueos

- Si está disponible:
  - crea `quiz_session`
  - inicia el temporizador (si aplica)

---

### Responder preguntas

- Se presenta **una pregunta a la vez**
- El usuario:
  1. Selecciona opción
  2. Confirma respuesta

- El sistema:
  - Indica inmediatamente si es correcta o incorrecta
  - Muestra explicación pedagógica

> El feedback es **siempre inmediato**.

---

### Finalización

Al terminar:

- Se calcula score
- Se crea `quiz_attempt`
- Se actualiza `quiz_state`:
  - aprobado → estado `passed`
  - reprobado → suma intento y evalúa bloqueo

El usuario ve:

- Nota final
- Resultado (aprobado / no aprobado)
- Resumen por pregunta

---

## Intentos, cooldown y bloqueos

### Reglas base

- Máximo 3 intentos por ciclo
- Cooldown de 6 horas desde el fail
- Al superar intentos:
  - estado `blocked`

### Reset por Referente

- Acción manual
- Agrega **3 intentos adicionales**
- No borra historial
- Incrementa contador total de intentos históricos
- Acción auditada obligatoriamente

> Un usuario puede tener 6, 9, 12 intentos históricos.
> Esto es información valiosa, no un error.

---

## Quiz Final y aprobación del curso

### Desbloqueo

- Solo si:
  - todos los quizzes de unidad están aprobados

### Aprobación del curso

Un curso se considera aprobado si:

- Todos los quizzes de unidad → aprobados
- Quiz final → aprobado

Se guarda:

- Nota final
- Fecha de aprobación
- Evidencia completa de evaluaciones

---

## Persistencia del histórico

- Ningún intento se borra
- Ninguna respuesta se borra
- Ninguna nota se recalcula

Esto garantiza:

- Auditoría
- Comparativas
- Analytics longitudinales

---

## Analytics habilitados por el Quiz Engine

Gracias a este diseño, el sistema puede medir:

### Por pregunta

- % de aciertos
- Distractores más elegidos
- Tiempo medio de respuesta
- Fallos por dificultad
- Fallos por anclaje conceptual

### Por usuario

- Evolución entre intentos
- Preguntas repetidamente falladas
- Cantidad total de intentos

### Por unidad / curso

- Unidades más difíciles
- Preguntas “problemáticas”
- Eficacia del contenido

---

## Reglas duras

1. No existe quiz sin pool
2. No existe intento sin sesión
3. No existe respuesta sin registro
4. El feedback es siempre inmediato
5. El histórico es inmutable

---

## Referencias

- Course Builder: `03_course_builder.md`
- Player Aprendiz: `05_player_aprendiz.md`
- Analytics: `07_analytics_y_metricas.md`

---

### ✅ Estado del documento

Este documento se considera **CERRADO**.
Cualquier cambio al motor de quizzes impacta directamente:

- UX
- Seguridad
- Analytics

Debe tratarse como cambio crítico.

---
