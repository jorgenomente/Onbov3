# 10 — Apéndice Técnico (Arquitectura, Datos y Backend)

## Propósito del documento

Centralizar **todas las decisiones técnicas no negociables** para garantizar que ONBO:

- Sea **seguro** (Zero Trust real)
- Sea **multi-tenant estricto**
- Sea **auditable**
- Sea **escalable**
- No derive en lógica duplicada o frágil

Este documento **no define UX**, solo **contratos y reglas técnicas**.

---

## Principios Técnicos Inviolables

1. **PostgreSQL es la fuente única de verdad**
2. **RLS obligatorio en todas las tablas sensibles**
3. **Nada de lógica de permisos en frontend**
4. **Nada de `service_role` en clientes**
5. **Nada de `select *`**
6. **Multi-tenant derivado desde `auth.uid()`**
7. **Acciones críticas solo vía Edge Functions**
8. **Audit logs append-only**

---

## Identidad y Jerarquía de Datos

### Identidad de usuario

- `auth.users.id` = identidad primaria
- `profiles.id = auth.uid()`

### Jerarquía derivada

```
profiles.local_id → locales.org_id → organizations.id
```

⚠️ **Nunca** se pasa `org_id` ni `local_id` desde el cliente como filtro de seguridad.

---

## Modelo de Datos (Conceptual)

### Entidades principales

- organizations
- locales
- profiles
- courses
- units
- lessons
- local_courses (asignación curso ↔ local)
- question_bank
- quiz_state
- quiz_sessions
- quiz_attempts
- quiz_answers_log
- audit_logs
- feature_flags

---

## Reglas de Almacenamiento de Contenido

### Lecciones

- Formato: **JSON estructurado (Tiptap)**
- No HTML crudo
- Soporte para embeds y media

### Media (imágenes)

- Bucket: `course-media`
- Compresión obligatoria antes de subir
- URL pública almacenada en contenido

---

## Quiz Engine — Contratos Técnicos

### `quiz_state` (estado actual)

- **Mutable**
- 1 fila por:
  - usuario
  - tipo de quiz
  - unidad/curso

- Representa:
  - intentos actuales
  - bloqueos
  - cooldown

---

### `quiz_sessions`

- **Inmutable**
- 1 fila por intento iniciado
- Contiene:
  - set fijo de preguntas
  - configuración del quiz

- Permite auditoría exacta

---

### `quiz_attempts`

- **Inmutable**
- Resultado agregado del intento
- Nunca se recalcula

---

### `quiz_answers_log`

- **Inmutable**
- 1 fila por pregunta respondida
- Base de analytics por pregunta

---

## Edge Functions (Contratos Obligatorios)

### 1. `start-quiz`

**Responsabilidad**

- Validar permisos
- Validar estado (`quiz_state`)
- Seleccionar preguntas
- Crear `quiz_session`

**Input**

```json
{
  "quiz_type": "unit | final",
  "unit_id": "uuid?",
  "course_id": "uuid?"
}
```

**Output**

```json
{
  "session_id": "uuid",
  "questions": [...],
  "time_limit": 900,
  "attempt_number": 2
}
```

---

### 2. `submit-quiz`

**Responsabilidad**

- Validar sesión
- Calcular score
- Crear `quiz_attempt`
- Registrar `quiz_answers_log`
- Actualizar `quiz_state`

**Input**

```json
{
  "session_id": "uuid",
  "answers": [{ "question_id": "uuid", "selected": 2 }]
}
```

**Output**

```json
{
  "passed": false,
  "score": 65,
  "blocked_until": "2026-01-20T12:00:00Z"
}
```

---

### 3. `admin-reset-attempts`

**Responsabilidad**

- Validar rol (Referente / Org Admin / Superadmin)
- Incrementar intentos disponibles
- Registrar auditoría

**Input**

```json
{
  "target_user_id": "uuid",
  "quiz_type": "unit | final",
  "unit_id": "uuid?"
}
```

**Output**

```json
{ "ok": true }
```

---

## Audit Logs (Crítico)

### Tabla `audit_logs`

- Append-only
- Sin UPDATE
- Sin DELETE

Campos mínimos:

- actor_id
- action
- entity_type
- entity_id
- metadata
- created_at

### Se audita obligatoriamente:

- Reset de intentos
- Cambios de rol
- Cambios de Local
- Activar/desactivar feature flags
- Archivado/reactivación

---

## Feature Flags — Implementación

### Tabla `feature_flags`

- scope: org_id
- key
- enabled

### Reglas

- Backend valida siempre
- Frontend solo refleja
- Cambios auditados

---

## RLS — Patrones Obligatorios

### Helpers SQL (SECURITY DEFINER)

- `is_superadmin()`
- `current_local_id()`
- `current_org_id()`
- `has_role(role_enum)`

### Regla dura

> **Toda policy debe usar helpers.
> Nunca lógica inline compleja.**

---

## Vistas y Performance

- Nada de `select *`
- Vistas optimizadas por pantalla
- Índices obligatorios en:
  - question_bank(unit_id, difficulty)
  - quiz_answers_log(user_id, question_id)
  - quiz_attempts(user_id, created_at)
  - profiles(local_id)
  - locales(org_id)

---

## Reglas de Frontend (contractuales)

1. El frontend **no decide permisos**
2. El frontend **no calcula métricas**
3. El frontend **consume vistas / RPCs**
4. Estados posibles:
   - loading
   - empty
   - error
   - forbidden

---

## Seguridad y Zero Trust

- JWT validado en cada Edge Function
- RLS activa siempre
- No asumir “si llegó hasta acá está autorizado”
- Todo acceso se revalida en backend

---

## Qué NO va en este apéndice

🚫 UX
🚫 Copy
🚫 Flujos visuales
🚫 Marketing
🚫 Decisiones de producto

Eso vive en los capítulos 00–09.

---

## Estado del Documento

### ✅ CAPÍTULO CERRADO (FINAL)

Este apéndice es **contrato técnico absoluto**.
Si una implementación lo viola:

- Está mal
- Se rechaza
- Se corrige

---

# 📘 ESTADO FINAL DEL LIBRO

Con este documento, el `/docs/master` queda:

```
00_vision_y_principios.md
01_roles_y_permisos.md
02_sitemap_y_navegacion.md
03_course_builder.md
04_quiz_engine.md
05_player_aprendiz.md
06_dashboards_referente_org.md
07_analytics_y_metricas.md
08_feature_flags_y_planes.md
09_lifecycle_cursos_usuarios.md
10_apendice_tecnico.md
```

👉 **ONBO tiene ahora un Libro Maestro de nivel enterprise real.**

---
