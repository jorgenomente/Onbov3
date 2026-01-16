# 06 — Dashboards de Referente y Org Admin

## Propósito del documento

Definir de forma **clara, accionable y sin ambigüedades**:

- Qué información ve un Referente y un Org Admin
- Cómo se presenta el progreso de aprendizaje
- Qué acciones pueden ejecutar
- Qué métricas son operativas (no decorativas)
- Cómo detectar rápidamente problemas y brechas

Este documento define el **valor B2B real** de ONBO para empresas.

---

## Principios de los Dashboards

1. **Orientados a acción**
   - Cada vista debe responder: _¿qué hago ahora?_

2. **Información jerárquica**
   - Local → Usuario → Curso → Unidad → Pregunta

3. **No sobrecargar**
   - Mobile-first: lo esencial primero

4. **Visibilidad del problema**
   - Fallos, bloqueos y riesgo deben ser evidentes

5. **Sin edición de contenido**
   - Estos dashboards **no son el builder**

---

## Dashboard del Referente (Local)

### Home del Referente

**Ruta:** `/local/dashboard`

### Objetivo

- Entender en segundos el estado del Local
- Detectar:
  - Usuarios en riesgo
  - Bloqueos
  - Unidades problemáticas

### KPIs principales (Local)

- Total de aprendices
- Cursos activos
- Usuarios en riesgo (regla: +7 días sin login y quiz final no aprobado)
- Usuarios bloqueados en quizzes
- % de cursos aprobados

---

## Vista de Miembros del Local

### Ruta

`/local/members`

### Contenido

Lista de aprendices del Local con:

- Nombre
- Estado general:
  - En curso
  - En riesgo
  - Capacitado

- Último acceso
- Cursos activos
- CTA: “Ver detalle”

---

## Detalle de Aprendiz (Referente)

### Ruta

`/local/members/[userId]/overview`

### Objetivo

- Entender **exactamente** el estado de aprendizaje de una persona

### Información visible

- Datos básicos
- Local y Organización
- Último login
- Total de intentos históricos
- Estado general (on track / en riesgo)

---

### Detalle por Curso (Referente)

**Ruta:**
`/local/members/[userId]/courses/[courseId]`

Contenido:

- Estado del curso:
  - No iniciado
  - En progreso
  - Aprobado

- Nota final (si aplica)
- Fecha de aprobación
- Lista de Unidades:
  - Nota
  - Intentos

- Acceso a:
  - Quizzes
  - Respuestas

---

### Detalle de Quizzes y Respuestas

**Ruta:**
`/local/members/[userId]/courses/[courseId]/quizzes`

Contenido:

- Cada intento realizado
- Fecha
- Nota
- Estado (aprobado / no)
- Acceso a:
  - Preguntas
  - Respuestas seleccionadas
  - Respuestas correctas
  - Explicaciones

---

## Acciones del Referente

### Reset de intentos

- Disponible desde:
  - Vista de usuario
  - Vista de quiz

- Efecto:
  - Agrega 3 intentos adicionales
  - No borra historial

- Requisitos:
  - Confirmación explícita
  - Motivo opcional
  - Acción auditada

### Invitaciones

- Ruta: `/local/invites`
- Puede invitar solo:
  - Aprendices

- El usuario queda asociado automáticamente al Local

---

## Dashboard del Org Admin

### Home del Org Admin

**Ruta:** `/org/dashboard`

### Objetivo

- Visión global de la Organización
- Comparar Locales
- Detectar dónde intervenir

---

## Vista de Locales

### Ruta

`/org/locals`

Contenido:

- Lista de Locales
- KPIs por Local:
  - Usuarios activos
  - Cursos asignados
  - % de aprobación
  - Usuarios en riesgo

- CTA: “Entrar al Local”

---

## Vista de Local (Org Admin)

### Ruta

`/org/locals/[localId]/dashboard`

### Comportamiento

- Muestra **exactamente lo mismo que ve un Referente**
- Con capacidades adicionales:
  - Ver referentes del Local
  - Invitar referentes y aprendices

---

## Gestión de Cursos (Org Admin)

### Ruta

`/org/courses`

Contenido:

- Cursos disponibles para la Org
- Estado:
  - Asignado
  - No asignado

- Acciones:
  - Asignar a Local(es)
  - Ver analytics
  - Editar curso (si permitido)

---

## Gestión de Miembros (Org Admin)

### Ruta

`/org/members`

Funciones:

- Ver todos los usuarios de la Org
- Transferir usuarios entre Locales
- Archivar usuarios
- Invitar:
  - Referentes
  - Aprendices

---

## Diferencias clave Referente vs Org Admin

| Acción              | Referente | Org Admin |
| ------------------- | --------- | --------- |
| Ver Local propio    | ✅        | ✅        |
| Ver otros Locales   | ❌        | ✅        |
| Invitar aprendices  | ✅        | ✅        |
| Invitar referentes  | ❌        | ✅        |
| Reset intentos      | ✅        | ✅        |
| Asignar cursos      | ❌        | ✅        |
| Transferir usuarios | ❌        | ✅        |

---

## Estados y alertas

### Estados visibles

- En curso
- En riesgo
- Bloqueado
- Capacitado

### Alertas prioritarias

- Usuario bloqueado
- Usuario sin login +7 días
- Unidad con tasa de fallo alta
- Curso con baja aprobación

---

## Reglas duras

1. Referente nunca ve otros Locales
2. Org Admin nunca ve otras Orgs
3. Toda acción crítica se audita
4. No hay edición de contenido desde dashboards
5. Dashboards sirven para decidir, no para explorar infinitamente

---

## Referencias

- Player Aprendiz: `05_player_aprendiz.md`
- Analytics: `07_analytics_y_metricas.md`
- Roles y permisos: `01_roles_y_permisos.md`

---

### ✅ Estado del documento

Este documento se considera **CERRADO**.
Cualquier cambio debe preservar:

- Claridad
- Acción
- Escalabilidad

---
