# ONBO — Roadmap Técnico de Implementación

Estado: v1.0 (Ejecutable)  
Rol: Orden de ejecución + checklist de verificación  
Audiencia: Devs, auditoría técnica, continuidad de proyecto

Este roadmap define **qué construir, en qué orden y cómo verificarlo**, para minimizar errores estructurales y deuda técnica.

Principio rector:

> Nunca construir UX sin contratos de datos.  
> Nunca construir lógica sin RLS.  
> Nunca avanzar sin tests mínimos.

---

## 🧱 FASE 0 — Fundaciones (OBLIGATORIA)

### Objetivo

Cerrar **identidad, multi-tenancy, roles y lifecycle base**.  
Nada avanza si esta fase no está verificada.

---

### LOTE 0.1 — Identidad, Jerarquía y RLS Base

**Construir**

- Tablas:
  - `organizations`
  - `locales`
  - `profiles`
- Enums:
  - roles (`superadmin`, `org_admin`, `referente`, `aprendiz`)
- Helpers SQL (SECURITY DEFINER):
  - `current_org_id()`
  - `current_local_id()`
  - `has_role(role)`
  - `is_superadmin()`
- RLS en todas las tablas

**Checklist**

- [ ] Todas las tablas sensibles tienen RLS `ENABLED`
- [ ] Ninguna policy usa `org_id`/`local_id` del cliente
- [ ] Superadmin puede ver todo
- [ ] Org Admin solo su org
- [ ] Referente / Aprendiz solo su local

**Tests (obligatorios)**

- SQL smoke test:
  - Usuario A (Org A) no ve Org B
  - Usuario B (Local B) no ve Local A
- Test negativo:
  - Forzar `org_id` desde cliente → no cambia resultados

---

### LOTE 0.2 — Lifecycle Base + Auditoría

**Construir**

- Estados:
  - usuarios: `active / archived`
  - cursos: `draft / active / archived`
- Reactivación de usuarios
- Transferencia de local
- Tabla `audit_logs` (append-only)

**Checklist**

- [ ] No existe DELETE lógico/físico
- [ ] Reactivación conserva historial
- [ ] Transferencia solo intra-org
- [ ] Acciones críticas auditadas

**Tests**

- Archivar → reactivar → login OK
- Transferir usuario → cursos visibles correctos
- Audit log registra actor + acción

---

### LOTE 0.3 — Infra mínima funcional

**Construir**

- Login / logout
- App shell por rol (sin features)
- Redirección correcta por rol

**Checklist**

- [ ] Login funciona para todos los roles
- [ ] Aprendiz no accede rutas admin
- [ ] Forbidden state visible en UI

**Tests**

- Playwright: login por rol
- Intento de acceso a ruta no permitida → 403 UX

---

## 📚 FASE 1 — Course Builder (Contenido)

### Objetivo

Crear cursos reales, usables y asignables.

---

### LOTE 1.1 — Estructura de Cursos

**Construir**

- Tablas:
  - `courses`
  - `units`
  - `lessons`
  - `local_courses`
- Views por pantalla (sin `select *`)

**Checklist**

- [ ] Curso mínimo viable validado
- [ ] Asignación a locales funciona
- [ ] Cursos visibles solo en locales asignados

**Tests**

- SQL: usuario ve solo cursos de su local
- UI: asignar / quitar curso de local

---

### LOTE 1.2 — Editor de Lecciones

**Construir**

- Tiptap
- Guardado JSON
- Autosave
- Preview

**Checklist**

- [ ] No HTML crudo
- [ ] Cambios persistentes
- [ ] Preview refleja contenido real

**Tests**

- Editar → refresh → contenido intacto

---

### LOTE 1.3 — Importación de Contenido

**Construir**

- Paste-to-create
- PDF → texto
- Parser con preview
- Upload imágenes:
  - compresión
  - bucket `course-media`

**Checklist**

- [ ] Preview obligatorio antes de persistir
- [ ] Errores de formato explicados
- [ ] Importación parcial permitida

**Tests**

- Pegar texto mal formado → no persiste
- Imagen pegada → URL en Supabase Storage

---

## 🧠 FASE 2 — Quiz Engine (CORE)

### Objetivo

Motor de evaluación exacto al diseño.

---

### LOTE 2.1 — Pool de Preguntas

**Construir**

- `question_bank`
- dificultad
- anclaje conceptual
- importador ONBO-QUIZ

**Checklist**

- [ ] Explicación obligatoria
- [ ] Importación parcial
- [ ] Sin detección forzada de duplicados

**Tests**

- Importar 10 preguntas → 2 inválidas → 8 guardadas

---

### LOTE 2.2 — Estados e Intentos

**Construir**

- `quiz_state`
- `quiz_sessions`
- `quiz_attempts`
- `quiz_answers_log`

**Checklist**

- [ ] Sesiones inmutables
- [ ] Estado mutable correcto
- [ ] Histórico nunca se borra

**Tests**

- Dos intentos → dos sesiones distintas
- answers_log con una fila por pregunta

---

### LOTE 2.3 — Edge Functions Críticas

**Construir**

- `start-quiz`
- `submit-quiz`
- `admin-reset-attempts`

**Checklist**

- [ ] JWT validado
- [ ] Rol validado en DB
- [ ] Auditoría en acciones admin

**Tests**

- curl start → submit → resultado correcto
- Reset agrega intentos, no borra historial

---

### LOTE 2.4 — UX de Quizzes (Aprendiz)

**Checklist**

- [ ] Pregunta por pantalla
- [ ] Confirmación obligatoria
- [ ] Feedback inmediato
- [ ] Cooldown visible

**Tests**

- Reprobar → cooldown activo
- Aprobar → desbloquea siguiente etapa

---

## 👤 FASE 3 — Player del Aprendiz

### LOTE 3.1 — Home del Aprendiz

- Cursos en progreso
- Cursos disponibles
- Estado personal

### LOTE 3.2 — Navegación completa

- Curso → unidad → lección
- Acceso claro a quizzes

**Tests**

- Playwright: completar curso end-to-end

---

## 🧭 FASE 4 — Dashboards Operativos

### LOTE 4.1 — Referente

- Estado del local
- Usuarios en riesgo
- Reset de intentos

### LOTE 4.2 — Org Admin

- Comparativa de locales
- Gestión de usuarios
- Asignación de cursos

**Tests**

- Referente no ve otros locales
- Org Admin ve todos los locales de su org

---

## 📊 FASE 5 — Analytics

### LOTE 5.1 — Métricas Base

- Aprobación
- Intentos
- Usuarios en riesgo

### LOTE 5.2 — Analytics por Pregunta

- Distractores
- % fallos
- Anclaje problemático

**Tests**

- Query analytics devuelve datos consistentes

---

## 🧩 FASE 6 — Feature Flags

### LOTE 6.1 — Infra de Flags

- Tabla `feature_flags`
- Validación backend

### LOTE 6.2 — Capacidades

- org_can_create_courses
- advanced_analytics
- custom_quiz_settings

**Tests**

- Flag OFF → feature bloqueada
- Flag ON → feature habilitada sin deploy

---

## 🧪 FASE 7 — Hardening & QA

### LOTE 7.1 — Playwright

- Login
- Quiz completo
- Reset
- Transferencias

### LOTE 7.2 — Auditoría Final

- RLS
- Edge Functions
- Performance
- Logs

---

## Criterio de Cierre del Proyecto

- [ ] Todos los lotes completados
- [ ] Todos los tests verdes
- [ ] Docs actualizados
- [ ] Sin deuda estructural conocida

---

Estado del documento: **ACTIVO — Fuente Única del Roadmap**

```

---
```
