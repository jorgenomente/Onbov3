# AGENTS.md — ONBO (AI-Assisted Dev Playbook)

Estado: v1.1 — SELLADO  
Rol: Guía operativa para desarrollo asistido por IA  
Audiencia: Devs, auditoría técnica, continuidad del proyecto

Este repositorio se desarrolla con asistencia de IA (Antigravity / Project IDX / Codex / ChatGPT).

Este archivo define:

- cómo se piden cambios
- cómo se entregan
- cómo se valida que estén bien
- cómo se trabaja con Git (ramas/commits/push/merge) sin desorden

Objetivo: avanzar rápido con **mínimo error**, sin comprometer
**seguridad**, **multi-tenancy** ni **DX**.

---

## Marco de Ejecución del Proyecto

Este playbook se ejecuta dentro del marco definido por:

- `/docs/roadmap.md` → orden de ejecución y lotes activos
- `/docs/milestones.md` → criterios de cierre y control de calidad

Reglas:

- Ningún lote se considera terminado si no cumple su checklist en `roadmap.md`
- Ningún milestone se cierra si no cumple sus criterios en `milestones.md`

---

## 0) Principios No Negociables (MUST)

1. **Zero Trust**

- El frontend **NO** es fuente confiable.
- Toda autorización se valida en PostgreSQL (RLS) o Edge Functions.

2. **PostgreSQL como Fuente Única de Verdad**

- No hay lógica de permisos en JS/TS.
- RLS obligatorio en todas las tablas sensibles.

3. **Multi-tenancy estricto**

- Ninguna query filtra `org_id` / `local_id` desde el cliente.
- org/local se derivan desde `auth.uid()` vía joins y helpers SQL.

4. **Nada de `service_role` en clientes**

- `SUPABASE_SERVICE_ROLE_KEY` nunca vive en frontend ni SSR.
- Acciones admin → Edge Functions + auditoría.

5. **Nada de `select *`**

- Columnas explícitas siempre.
- Preferir views por pantalla (screen contracts).

6. **Audit logs append-only**

- No UPDATE / DELETE.
- Acciones críticas siempre auditadas.

---

## 1) Stack Mandatorio

### Frontend

- Next.js 16 (App Router)
- TypeScript
- Tailwind CSS (mobile-first estricto)

### Backend

- Supabase:
  - PostgreSQL
  - Auth
  - RLS
  - Edge Functions
  - Storage

### Tooling

- Resend (emails transaccionales, solo desde Edge Functions)
- Vitest (unit tests)
- Playwright (E2E)
- Prettier + Husky + lint-staged

---

## 2) Estructura del Repo (Convención)

- `app/` — Next App Router
- `lib/` — helpers compartidos (supabase client, invokeEdge, etc.)
- `components/` — UI
- `supabase/migrations/` — SQL migrations
- `supabase/functions/` — Edge Functions
- `docs/master/` — Libro Maestro (PRD canónico)
- `docs/audit/` — auditorías técnicas y decisiones

---

## 3) Roles de Agentes (Quién hace qué)

> Un **agent** es un perfil de trabajo.
> En cada tarea se debe invocar explícitamente uno o más.

---

### A) Security Architect (RLS + Multi-tenant)

Responsable de:

- Schema seguro (FKs, constraints)
- Helpers SQL (`current_org_id()`, `current_local_id()`, `has_role()`, `is_superadmin()`)
- Policies RLS (`USING` / `WITH CHECK`)
- Threat model mínimo
- Smoke tests de aislamiento entre tenants

Entregables:

- SQL migration lista
- Policies RLS completas
- Queries de verificación (2 orgs / 2 users)

---

### B) Database Architect (Schema + Vistas)

Responsable de:

- Tablas, índices y constraints
- Views por pantalla (screen data contracts)
- RPCs **solo cuando sean estrictamente necesarios**
- Performance básica (índices compuestos)

Regla importante:

- Preferir **VIEWS** para lectura
- Usar **RPCs solo si**:
  - hay lógica transaccional
  - hay múltiples writes coordinados
  - no puede expresarse como view segura

Entregables:

- Migration SQL + índices
- Views con columnas explícitas
- Ejemplos de SELECT (sin `*`)

---

### C) Edge Functions Engineer

Responsable de:

- Lógica sensible (start-quiz, submit-quiz, reset-attempts, invites)
- Validación JWT
- CORS
- Auditoría (`audit_logs`)
- Contratos de error claros y estables

#### Tipos de Edge Functions

- **User-context**
  - Ejecutan con JWT del usuario
  - Respetan RLS
  - Ej: `start-quiz`, `submit-quiz`
- **Admin-context**
  - Validan rol explícitamente
  - Ejecutan acciones privilegiadas
  - Siempre auditadas
  - Ej: `reset-attempts`, `invites`

Entregables:

- Edge Function completa (TypeScript)
- Contrato request / response
- Tests manuales (curl) + smoke checks

---

### D) Frontend Engineer (Next.js App Router)

Responsable de:

- UI mobile-first
- Integración con views / RPCs / Edge Functions
- Estados: loading / empty / error / forbidden
- **No duplicar lógica de permisos**

Entregables:

- Páginas y componentes
- Data contract (qué view/RPC consume)
- Manejo de errores y toasts

---

### E) QA / E2E Engineer (Playwright)

Responsable de:

- Flujos críticos por rol
- Tests E2E reproducibles
- Seeds o fixtures mínimos

Entregables:

- Specs de Playwright
- Checklist de ejecución local / CI
- Criterios de aceptación verificables

---

### F) UX / Product Spec Agent

Responsable de:

- Consistencia con `/docs/master`
- UX simple pero potente
- Navegación por rol
- Estados vacíos, errores y microcopy

Entregables:

- Ajustes al Libro Maestro
- Wireframes textuales
- Criterios UX

---

## 4) Formato Obligatorio de Respuestas (para IA)

Toda respuesta debe incluir **SIEMPRE**:

1. **Análisis de Seguridad**

- Cómo respeta RLS
- Cómo evita cross-org / cross-local
- Qué tabla / endpoint es sensible

2. **Plan de Cambios**

- Archivos a tocar
- Migrations / Functions / UI

3. **Código Crítico**

- SQL migrations completas
- Policies RLS completas
- Edge Functions completas (si aplica)

4. **Verificación**

- Smoke tests SQL
- Checks de RLS (mínimo 2 tenants)
- Playwright (caso mínimo si aplica)

Prohibido:

- “podría”, “quizás” en seguridad
- dejar policies “para luego”
- asumir tablas o columnas inexistentes

---

## 5) Contratos de Pantalla (Screen Data Contracts)

Regla:

> Cada pantalla consume **una view (o RPC)** diseñada para ella.

Cada contrato define:

- view / rpc name
- columnas exactas
- filtros permitidos (idealmente ninguno desde el cliente)
- índices necesarios
- ejemplos de queries

---

## 6) Lotes de Desarrollo (Workflow)

Trabajamos por **Lotes**.

Cada lote tiene:

- objetivo claro
- alcance cerrado
- checklist de seguridad
- verificación obligatoria

Estructura típica:

- Lote 0 — Auth + org/local + profiles + RLS base
- Lote 1 — Course Builder
- Lote 2 — Quiz Engine
- Lote 3 — Dashboards + Analytics
- Lote 4 — Invites + Resend + onboarding
- Lote 5 — Hardening + observabilidad

Cada lote produce:

- migrations
- views
- UI
- tests
- update en `docs/audit/`

### Definition of Done (DoD) de un Lote

Un lote se considera **terminado solo si**:

- checklist completo (roadmap)
- smoke tests pasan
- E2E mínimos (si aplica) pasan
- existe documento en `docs/audit/`

---

## 6.1) Git Protocol (Obligatorio, sin olvidos)

### Objetivo

Trabajar ordenado con ramas y commits atómicos.
El agente debe **guiar** el flujo y proveer comandos listos.

Importante:

- El agente **NO ejecuta Git por sí mismo** (no tiene control del repo).
- El agente **SI** debe:
  - proponer rama
  - sugerir commits
  - dar comandos exactos para `git add/commit/push/merge`
  - pedir confirmación “pasaron los tests” antes de merge

### Reglas base

- No trabajar directo en `main`.
- **Branch por lote o issue**.
- **Commit por bloque lógico**, no por milestone.
- Push frecuente (después de cada commit estable).
- Merge a `main` **solo cuando el lote cumple DoD**.

### Naming de branches

- `feat/<lote>-<slug>` (ej: `feat/l0-1-rls-base`)
- `fix/<slug>`
- `chore/<slug>`
- `docs/<slug>`

### Mensajes de commit (convención)

- `feat(db): ...`
- `feat(rls): ...`
- `feat(edge): ...`
- `fix: ...`
- `test: ...`
- `docs(audit): ...`
- `chore: ...`

### Start-of-lote (comandos estándar)

Al iniciar un lote, el agente debe proponer y el usuario ejecuta:

```bash
git checkout main
git pull
git checkout -b feat/<lote>-<slug>
```

### Commit loop (cada objetivo importante)

Cada vez que se completa un bloque importante, el agente debe proponer:

```bash
git status
git add <archivos>
git commit -m "<mensaje>"
git push -u origin HEAD
```

y luego preguntar:

- “¿Pasaron los checks (build/smoke/e2e) para seguir?”

### End-of-lote (merge gate)

Antes de mergear, el agente debe exigir confirmación de DoD:

- checklist completo
- smoke tests OK
- E2E mínimos OK (si aplica)
- `docs/audit/...` creado o actualizado

Luego propone merge (preferido vía PR). Si se hace local:

```bash
git checkout main
git pull
git merge --no-ff feat/<lote>-<slug>
git push
```

---

## 7) Checklist de Seguridad (antes de merge)

- [ ] RLS habilitado en todas las tablas sensibles
- [ ] Policies no usan org/local del cliente
- [ ] No existe `select *`
- [ ] Edge Functions validan JWT y rol
- [ ] Acciones críticas auditadas
- [ ] Pruebas de aislamiento tenant
- [ ] No `service_role` en Vercel / frontend

---

## 8) Variables de Entorno (Guía Práctica)

### Vercel (mínimo)

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

### Supabase (secrets del proyecto)

- Resend API key (si aplica)
- Secrets de Edge Functions

### CI (GitHub Actions)

- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`
- `SUPABASE_DB_PASSWORD` (si el flujo lo requiere)

---

## 9) Plantillas de Prompts (Copy / Paste)

### Prompt — SQL + RLS

Actúa como Security Architect y Database Architect.
Objetivo: [OBJETIVO DEL LOTE]

Restricciones:

- RLS obligatorio
- sin `select *`
- multi-tenant derivado desde `auth.uid()`

Entrega:

1. Análisis de seguridad
2. SQL migration completa (tablas + índices + policies)
3. Views por pantalla
4. Smoke tests SQL (2 orgs / 2 users)

---

### Prompt — Edge Function

Actúa como Edge Functions Engineer.
Objetivo: [FUNCIÓN]

Contrato:

- request / response JSON estable

Seguridad:

- validar JWT
- validar rol/scope en DB
- auditar acción crítica

Entrega:

- código completo
- curl tests
- errores estandarizados

---

### Prompt — UI (Next.js)

Actúa como Frontend Engineer.
Objetivo: [PANTALLA]

Data contract:

- consumir view/RPC: [NOMBRE]

Reglas:

- mobile-first
- estados loading/empty/error/forbidden
- sin lógica de permisos en UI

Entrega:

- archivos exactos
- componentes
- puntos de verificación

---

## 10) Documentación Viva (Obligatorio)

Cada lote actualiza:

- `docs/audit/<fecha>_<tema>.md` con:
  - qué se cambió
  - por qué
  - cómo verificar
  - riesgos y mitigaciones

---

**Fin de AGENTS.md**
Estado: **SELLADO v1.1**

```

---
```
