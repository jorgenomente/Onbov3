# AGENTS.md — ONBO (AI-Assisted Dev Playbook)

Este repositorio se desarrolla con asistencia de IA (Antigravity/Project IDX/Codex/ChatGPT).
Este archivo define cómo pedimos cambios, cómo se entregan y cómo se valida que estén bien.

Objetivo: avanzar rápido con **mínimo error**, sin comprometer **seguridad**, **multi-tenancy** ni **DX**.

---

## 0) Principios No Negociables (MUST)

1. **Zero Trust**

- El frontend NO es fuente confiable.
- Toda autorización se valida en PostgreSQL (RLS) o Edge Functions.

2. **PostgreSQL como Fuente Única de Verdad**

- No hay lógica de permisos en JS/TS.
- No asumir nada: RLS obligatorio en todas las tablas sensibles.

3. **Multi-tenancy estricto**

- Ninguna query “filtra por org_id/local_id desde el cliente”.
- org/local se derivan desde `auth.uid()` vía joins y helpers SQL.

4. **Nada de `service_role` en clientes**

- `SUPABASE_SERVICE_ROLE_KEY` nunca vive en frontend.
- Si hace falta admin, se hace vía Edge Function (en Supabase) + auditoría.

5. **Nada de `select *`**

- Siempre seleccionar columnas explícitas.
- Preferir views por pantalla (screen contracts).

6. **Audit logs append-only**

- No UPDATE / DELETE.
- Acciones críticas siempre auditadas.

---

## 1) Stack Mandatorio

Frontend

- Next.js 16 (App Router)
- TypeScript
- Tailwind CSS (mobile-first estricto)

Backend

- Supabase: Postgres + Auth + RLS + Edge Functions + Storage

Tooling

- Resend (emails transaccionales, siempre desde Edge Functions)
- Vitest (unit)
- Playwright (E2E)
- Prettier + Husky + lint-staged

---

## 2) Estructura del Repo (Convención)

- `app/` (Next App Router)
- `lib/` (helpers, supabase client, invokeEdge, etc.)
- `components/` (UI)
- `supabase/migrations/` (SQL migrations)
- `supabase/functions/` (Edge Functions)
- `docs/master/` (Libro Maestro)
- `docs/audit/` (auditorías técnicas, contexto, decisiones)

---

## 3) Roles de Agentes (Quién hace qué)

> Un “agent” es un perfil de trabajo. En cada tarea, se invoca explícitamente uno o más.

### A) Security Architect (RLS + Multi-tenant)

Responsable de:

- Schema seguro (FKs, constraints)
- Helpers SQL (`is_superadmin()`, `current_org_id()`, etc.)
- Policies RLS (USING/WITH CHECK)
- Threat model mínimo
- Smoke tests de aislamiento entre tenants

Entregables:

- SQL migration lista
- RLS policies completas
- Queries de verificación

---

### B) Database Architect (Schema + Vistas)

Responsable de:

- Tablas, índices, constraints
- Views por pantalla (screen contracts)
- RPCs solo cuando hagan falta
- Performance básica (índices compuestos)

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
- Auditoría (audit_logs)
- Errores claros y estables (contracts)

Entregables:

- Edge function completa (TypeScript)
- Contrato request/response
- Tests manuales (curl) y smoke checks

---

### D) Frontend Engineer (Next.js App Router)

Responsable de:

- UI mobile-first
- Integración con views/RPC/Edge Functions
- Estados: loading/empty/error/forbidden
- No duplicar lógica de permisos

Entregables:

- Páginas + componentes
- Contract de datos (qué view consume)
- Manejo de errores + toasts

---

### E) QA / E2E Engineer (Playwright)

Responsable de:

- Flujos críticos por rol
- Tests E2E reproducibles
- Seeds o fixtures mínimos

Entregables:

- Specs de Playwright
- Checklist de ejecución local/CI
- Criterios de aceptación verificables

---

### F) UX/Product Spec Agent

Responsable de:

- Validar consistencia con `/docs/master`
- UX “simple pero potente”
- Navegación por rol, microcopy, estados

Entregables:

- Ajustes al PRD/libro maestro
- Wireframes textuales
- Criterios UX

---

## 4) Formato Obligatorio de Respuestas (para IA)

Toda respuesta (cuando pedimos cambios) debe incluir SIEMPRE:

1. **Análisis de Seguridad**

- Cómo respeta RLS
- Cómo evita cross-org/local
- Qué endpoint/tabla es sensible

2. **Plan de Cambios**

- Archivos a tocar
- Migrations/Functions/UI

3. **Código Crítico**

- SQL migrations completas
- Policies RLS completas
- Edge functions completas (si aplica)

4. **Verificación**

- Smoke tests SQL
- Checks de RLS (dos usuarios/tenants)
- Playwright: caso mínimo (si aplica)

Prohibido:

- “podría” / “quizás” en seguridad
- dejar policies “para luego”
- asumir columnas o tablas que no existen

---

## 5) Contratos de Pantalla (Screen Data Contracts)

Regla: cada pantalla consume **una view** (o RPC) diseñada para ella.

Cada contrato debe definir:

- view/rpc name
- columnas exactas
- filtros permitidos (ideal: ninguno desde el cliente)
- índices necesarios
- ejemplos de queries

---

## 6) Lotes de Desarrollo (Workflow)

Trabajamos por “Lotes”. Cada lote tiene:

- objetivo claro
- alcance cerrado
- checklist de seguridad
- verificación

Estructura sugerida:

- Lote 0: Auth + profiles + org/local + RLS base
- Lote 1: Course Builder (outline + lessons + media)
- Lote 2: Quiz Engine (pool + sessions + attempts + answers_log)
- Lote 3: Dashboards + analytics
- Lote 4: Invites + Resend + onboarding
- Lote 5: Hardening + Playwright + observabilidad

Cada lote produce:

- migrations
- views
- UI
- tests
- docs/audit update

---

## 6.1) Commits (higiene de cambios)

- Commits frecuentes y atómicos por bloque lógico.
- Mensajes convencionales (ej: `feat: ...`, `fix: ...`, `chore: ...`).
- No mezclar cambios no relacionados en un mismo commit.

---

## 7) Checklist de Seguridad (antes de merge)

- [ ] RLS habilitado en todas las tablas sensibles
- [ ] Policies no usan `org_id`/`local_id` del cliente
- [ ] No existe `select *`
- [ ] Edge functions validan JWT y rol
- [ ] Acciones críticas escriben `audit_logs`
- [ ] Pruebas de aislamiento tenant (Org A vs Org B)
- [ ] No `service_role` en Vercel/frontend

---

## 8) Variables de Entorno (Guía práctica)

Vercel (mínimo):

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

Supabase (secrets en el proyecto):

- Resend API key (si aplica)
- cualquier secreto de Edge Functions

CI (GitHub Actions Secrets):

- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`
- `SUPABASE_DB_PASSWORD` (si tu flujo lo requiere)

---

## 9) Plantillas de Prompts (Copy/Paste)

### Prompt — SQL + RLS (Security + DB)

Actúa como Security Architect y Database Architect.
Objetivo: [OBJETIVO DEL LOTE]
Restricciones:

- RLS obligatorio
- sin select \*
- multi-tenant derivado desde auth.uid()
  Entrega:

1. Análisis de seguridad
2. SQL migration completa (tablas + índices + policies)
3. Vistas por pantalla
4. Smoke tests SQL (incluye 2 orgs, 2 users)

---

### Prompt — Edge Function

Actúa como Edge Functions Engineer.
Objetivo: [FUNCION]
Contrato:

- request/response JSON estable
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

- consumir view/rpc: [NOMBRE]
  Reglas:
- mobile-first
- estados loading/empty/error/forbidden
- nada de lógica de permisos en UI
  Entrega:
- archivos exactos
- componentes
- puntos de verificación

---

## 10) Documentación viva (obligatorio)

Cada lote actualiza:

- `docs/audit/<fecha>_<tema>.md` con:
  - qué se cambió
  - por qué
  - cómo verificar
  - riesgos y mitigaciones

---
