# 07 — Analytics y Métricas (Data-Driven Learning)

## Propósito del documento

Definir **qué medimos**, **por qué lo medimos** y **cómo se interpreta**, de forma que ONBO no sea solo un LMS, sino una **herramienta de mejora continua** de capacitación.

Este documento define:

- Métricas canónicas
- Vistas analíticas por rol
- Reglas para interpretar datos
- Señales de alerta y acción

---

## Principios de Analytics en ONBO

1. **Analytics accionables**
   - Cada métrica debe responder _qué hacer después_

2. **Granularidad descendente**
   - Org → Local → Usuario → Curso → Unidad → Pregunta

3. **Fuente única**
   - Todo sale del Quiz Engine (intentos + answers_log)

4. **Sin “vanity metrics”**
   - Nada que no ayude a tomar decisiones

5. **Privacidad y alcance**
   - Cada rol ve solo lo que le corresponde

---

## Niveles de análisis

### Nivel Plataforma (Superadmin)

- Comparativas entre organizaciones
- Eficacia global de cursos
- Identificación de cursos problemáticos

### Nivel Organización (Org Admin)

- Comparativa entre Locales
- Performance por curso
- Riesgos operativos

### Nivel Local (Referente)

- Estado real de los aprendices
- Detección temprana de problemas

### Nivel Usuario

- Evolución individual
- Dificultades específicas

---

## Métricas canónicas (definitivas)

---

## Métricas de Usuario

| Métrica                   | Descripción                       |
| ------------------------- | --------------------------------- |
| Último login              | Detección de inactividad          |
| Estado de aprendizaje     | En curso / En riesgo / Capacitado |
| Cursos activos            | Cantidad                          |
| Cursos aprobados          | Historial                         |
| Intentos totales          | Señal de dificultad               |
| Tiempo medio por pregunta | (si se captura)                   |

### Usuario en riesgo

Un usuario está **en riesgo** si:

- No loguea hace +7 días
- Y no aprobó el quiz final del curso activo

---

## Métricas de Curso

| Métrica             | Descripción           |
| ------------------- | --------------------- |
| % de completación   | Usuarios que terminan |
| % de aprobación     | Usuarios que aprueban |
| Intentos promedio   | Dificultad real       |
| Tiempo promedio     | Fricción del curso    |
| Drop-off por unidad | Abandono              |

---

## Métricas de Unidad

| Métrica           | Descripción          |
| ----------------- | -------------------- |
| % de aprobación   | Dificultad           |
| Promedio de nota  | Nivel de comprensión |
| Intentos promedio | Complejidad          |
| Tiempo total      | Carga cognitiva      |

---

## Métricas de Pregunta (core)

| Métrica                | Descripción                      |
| ---------------------- | -------------------------------- |
| % de aciertos          | Claridad                         |
| Distractor más elegido | Confusión                        |
| Fallos por dificultad  | Ajuste del nivel                 |
| Fallos por anclaje     | Parte problemática del contenido |
| Repetición de error    | Brecha persistente               |

> Estas métricas son el **diferencial clave** de ONBO.

---

## Métricas de Quiz

| Métrica                | Descripción       |
| ---------------------- | ----------------- |
| Aprobación por intento | Aprendizaje real  |
| % de bloqueo           | Frustración       |
| Resets realizados      | Señal de problema |
| Tiempo real vs límite  | Presión temporal  |

---

## Dashboards Analíticos por Rol

---

## Referente (Local)

### Vistas principales

- Usuarios en riesgo
- Usuarios bloqueados
- Unidades con mayor tasa de fallo
- Preguntas problemáticas

### Decisiones habilitadas

- Acompañar a un aprendiz
- Resetear intentos
- Reportar contenido confuso

---

## Org Admin

### Vistas principales

- Comparativa de Locales
- Performance por curso
- Tendencias de aprobación
- Cursos con baja eficacia

### Decisiones habilitadas

- Ajustar contenido
- Reasignar cursos
- Capacitar referentes

---

## Superadmin

### Vistas principales

- Cursos más efectivos
- Cursos problemáticos
- Brechas comunes entre clientes
- Impacto de cambios en templates

### Decisiones habilitadas

- Mejorar templates
- Ajustar dificultad global
- Definir roadmap de producto

---

## Visualización de datos

### Principios

- Mobile-first
- Claridad sobre densidad
- Colores semánticos (riesgo, ok, alerta)

### Componentes recomendados

- Barras de progreso
- Heatmaps (pregunta × fallo)
- Rankings simples
- Tendencias temporales

---

## Reglas duras

1. Ninguna métrica se calcula en frontend
2. No se exponen datos fuera del scope del rol
3. No se recalculan históricos
4. Toda vista analítica tiene fuente definida
5. Las métricas deben poder explicarse en una frase

---

## Referencias

- Quiz Engine: `04_quiz_engine.md`
- Dashboards: `06_dashboards_referente_org.md`
- Feature Flags: `08_feature_flags_y_planes.md`

---

### ✅ Estado del documento

Este documento se considera **CERRADO**.
Los analytics definidos aquí son **contrato de producto**.

---
