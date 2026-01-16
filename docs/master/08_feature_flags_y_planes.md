# 08 — Feature Flags y Planes (Control de Capacidades)

## Propósito del documento

Definir de forma **explícita y operativa**:

- Qué son los **Feature Flags** en ONBO
- Para qué se usan
- Qué capacidades existen
- Cómo se activan/desactivan
- Cómo se relacionan con planes comerciales y madurez del cliente

Este documento permite que ONBO:

- Evolucione sin forks
- Diferencie planes sin duplicar código
- Active funciones de forma segura y reversible

---

## Principio central

> **Un Feature Flag es un interruptor de capacidad, no de UI.**

- El flag **habilita o deshabilita comportamiento**
- La UI solo refleja lo que el backend permite
- El backend **siempre valida** el flag

---

## Alcance de los Feature Flags

Los flags pueden aplicarse a:

- Plataforma (global)
- Organización
- Curso (casos avanzados)

En ONBO, el **nivel primario es la Organización**.

---

## Por qué usar Feature Flags en ONBO

1. Diferenciar planes (Básico / Pro / Enterprise)
2. Habilitar funciones avanzadas progresivamente
3. Probar features sin riesgo
4. Adaptar el producto a distintos tipos de clientes
5. Evitar “hard forks” de producto

---

## Catálogo canónico de Feature Flags

### 1. `org_can_create_courses`

**Descripción:**
Permite que la Organización cree cursos desde cero usando el Course Builder completo.

- OFF:
  - La Org solo edita cursos asignados

- ON:
  - La Org crea, duplica y gestiona cursos propios

---

### 2. `advanced_analytics`

**Descripción:**
Habilita vistas analíticas profundas por pregunta, distractores y tendencias.

- OFF:
  - Métricas básicas

- ON:
  - Heatmaps
  - Análisis por pregunta
  - Comparativas temporales

---

### 3. `custom_quiz_settings`

**Descripción:**
Permite configurar parámetros avanzados de quizzes.

Incluye:

- Distribución por dificultad

- Puntaje de aprobación personalizado

- Tiempo límite por quiz

- OFF:
  - Defaults del sistema

- ON:
  - Configuración por curso / unidad

---

### 4. `extended_attempts_control`

**Descripción:**
Habilita control avanzado de intentos.

- OFF:
  - 3 intentos + resets manuales

- ON:
  - Límites personalizados
  - Alertas por exceso de intentos

---

### 5. `course_promotion_to_library`

**Descripción:**
Permite que una Organización promueva cursos a la Librería Global.

- OFF:
  - Cursos quedan solo en la Org

- ON:
  - Cursos pueden convertirse en templates reutilizables

---

### 6. `bulk_import_pro`

**Descripción:**
Habilita importaciones masivas avanzadas.

Incluye:

- Importación de preguntas complejas
- Validaciones extendidas
- Reportes detallados de errores

---

## Relación entre Feature Flags y Planes

### Ejemplo de Planes (conceptual)

| Plan       | Flags activos                                |
| ---------- | -------------------------------------------- |
| Básico     | —                                            |
| Pro        | org_can_create_courses, custom_quiz_settings |
| Enterprise | Todos                                        |

> Los planes **no existen en código**, solo activan flags.

---

## Gestión de Feature Flags

### Quién puede gestionar flags

- **Solo Superadmin**

### Dónde se gestionan

- Panel: `/superadmin/flags`
- Scope:
  - Por Organización

### Comportamiento al cambiar un flag

- Impacto inmediato
- No requiere deploy
- No rompe data existente

---

## Reglas de implementación (críticas)

1. El backend **siempre** valida flags
2. El frontend **nunca asume** flags activos
3. Un flag:
   - No elimina datos
   - Solo habilita o bloquea comportamiento

4. Flags deben ser:
   - Claros
   - Documentados
   - Reversibles

---

## Casos borde

### Desactivar un flag con data existente

Ejemplo:

- Org creó cursos propios
- Se desactiva `org_can_create_courses`

Comportamiento:

- No puede crear nuevos cursos
- Los cursos existentes siguen operativos
- No se borra nada

---

## Observabilidad y auditoría

- Todo cambio de flag:
  - Se audita
  - Registra actor, org, flag y valor

---

## Referencias

- Roles y permisos: `01_roles_y_permisos.md`
- Course Builder: `03_course_builder.md`
- Analytics: `07_analytics_y_metricas.md`

---

### ✅ Estado del documento

Este documento se considera **CERRADO**.
Los Feature Flags definidos aquí son **contrato de producto**.

---
