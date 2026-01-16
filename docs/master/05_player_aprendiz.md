# 05 — Player del Aprendiz (Experiencia de Aprendizaje)

## Propósito del documento

Definir de forma **precisa y sin ambigüedades**:

- La experiencia completa del Aprendiz
- Qué ve al ingresar
- Cómo navega el contenido
- Cómo interactúa con lecciones y quizzes
- Cómo recibe feedback y entiende su progreso
- Qué información puede consultar en todo momento

Este documento define el **estándar UX del usuario final**.
Si el Player no es claro y rápido, **el producto falla**, aunque el backend sea perfecto.

---

## Principios UX del Player

1. **Mobile-first real**
   - Todo debe ser usable con una mano
   - Botones grandes, tipografía clara

2. **Progreso siempre visible**
   - El Aprendiz debe saber:
     - dónde está
     - qué sigue
     - qué le falta

3. **Feedback inmediato**
   - Nunca dejar al usuario en duda

4. **No bloquear el aprendizaje**
   - Puede navegar libremente por contenido
   - El bloqueo es lógico, no de navegación

5. **Simplicidad cognitiva**
   - Una tarea principal por pantalla

---

## Home del Aprendiz

### Ruta

`/app`

### Objetivo

- Dar una visión clara del estado del Aprendiz
- Incentivar continuidad

### Contenido de la Home

1. **Cursos en progreso**
   - Barra de progreso
   - Última unidad/lección visitada
   - CTA: “Continuar”

2. **Cursos disponibles**
   - Cursos asignados al Local
   - CTA: “Empezar”

3. **Estado personal**
   - Cursos completados
   - Certificaciones (si aplica)

4. **Info contextual**
   - Organización
   - Local

---

## Vista de Curso

### Ruta

`/app/courses/[courseId]/overview`

### Objetivo

- Entender la estructura del curso
- Saber qué está bloqueado y qué no

### Contenido

- Descripción del curso
- Lista de Unidades:
  - Estado: no iniciado / en progreso / aprobado

- Estado del Quiz Final:
  - Bloqueado / Disponible / Aprobado

- CTA principal:
  - “Continuar curso” o “Rendir quiz final”

---

## Navegación por Unidades y Lecciones

### Ruta

`/app/courses/[courseId]/units/[unitId]/lessons/[lessonId]`

### Comportamiento

- Navegación libre entre lecciones
- Puede saltar unidades
- El sistema **no bloquea contenido**
- El progreso se guarda automáticamente

### UX obligatoria

- Indicador de progreso por unidad
- Botón claro de “Siguiente”
- Acceso rápido a:
  - Volver al curso
  - Ir al quiz de la unidad

---

## Quiz de Unidad (Player)

### Ruta

`/app/courses/[courseId]/units/[unitId]/quiz`

### Objetivo

- Evaluar comprensión de la unidad
- Reforzar aprendizaje con feedback inmediato

### UX del Quiz

- Una pregunta por pantalla
- Confirmación explícita de respuesta
- Feedback inmediato:
  - Correcto / Incorrecto
  - Explicación pedagógica

### Al finalizar

- Nota
- Estado:
  - Aprobado
  - Reprobado

- Si reprobado:
  - Mensaje claro de cooldown (si aplica)
  - Contador de intentos restantes

---

## Quiz Final del Curso

### Ruta

`/app/courses/[courseId]/final`

### Condiciones de acceso

- Todos los quizzes de unidad aprobados

### UX adicional

- Aviso de tiempo límite antes de comenzar
- Confirmación explícita de inicio
- Temporizador visible (si aplica)

### Al finalizar

- Nota final
- Estado del curso:
  - Aprobado
  - No aprobado

- Acceso a:
  - Resumen completo
  - Feedback por pregunta

---

## Feedback y Resultados

### Principios

- El Aprendiz **siempre** sabe:
  - Por qué aprobó
  - Por qué falló

- El feedback es pedagógico, no punitivo

### Resultados visibles

- Por intento:
  - Nota
  - Fecha
  - Tiempo empleado

- Por pregunta:
  - Respuesta dada
  - Respuesta correcta
  - Explicación

---

## Cursos Completados

### Comportamiento

- Un curso aprobado:
  - Permanece visible
  - Es navegable en modo repaso

- El Aprendiz puede:
  - Ver lecciones
  - Ver resultados
  - Ver evidencia de aprobación

> El contenido **no se vuelve a evaluar** una vez aprobado.

---

## Perfil del Aprendiz

### Ruta

`/app/profile`

### Contenido

- Datos básicos
- Organización y Local
- Historial de cursos
- Certificaciones (si aplica)

### Restricciones

- No puede modificar rol
- No puede modificar Local
- No puede ver otros usuarios

---

## Estados del Player

Cada vista debe contemplar:

- Loading
- Empty (sin cursos)
- Error
- Bloqueo (cooldown / intentos agotados)

Mensajes:

- Claros
- No técnicos
- Orientados a acción (“Volvé en 6h”, “Revisá el contenido”)

---

## Reglas duras

1. El Aprendiz nunca ve data de otros usuarios
2. El Aprendiz nunca ejecuta acciones administrativas
3. El progreso se guarda automáticamente
4. El feedback es inmediato y obligatorio
5. Un curso aprobado no cambia para ese usuario

---

## Referencias

- Quiz Engine: `04_quiz_engine.md`
- Roles y permisos: `01_roles_y_permisos.md`
- Dashboards: `06_dashboards_referente_org.md`

---

### ✅ Estado del documento

Este documento se considera **CERRADO**.
Cualquier cambio en esta experiencia impacta directamente:

- Engagement
- Retención
- Eficacia de la capacitación

---
