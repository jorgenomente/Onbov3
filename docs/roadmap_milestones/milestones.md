# ONBO — Milestones del Proyecto

Estado: v1.0 (Oficial)  
Rol: Puntos de control ejecutables del proyecto  
Audiencia: Desarrollo, auditoría técnica, planificación

Este documento define los **milestones oficiales de ONBO**.
Un milestone representa un **estado estable y verificable del sistema**.

Regla clave:

> Un milestone NO se cierra por “avance percibido”.  
> Se cierra solo cuando **todos sus criterios de aceptación pasan**.

---

## Modelo de trabajo

```

Milestone (control)
└── Lotes (entregables técnicos)
└── Issues / Tasks (trabajo concreto)

```

- **Milestone** → ¿podemos avanzar sin riesgo?
- **Lote** → ¿qué construimos exactamente?
- **Issue** → ¿qué archivo/código se toca?

---

## 🧱 M1 — Fundaciones Seguras

### Objetivo

Garantizar que ONBO es **multi-tenant, seguro y auditable**.
Nada avanza si este milestone no está cerrado.

### Incluye

- Lote 0.1 — Identidad, jerarquía y RLS base
- Lote 0.2 — Lifecycle base + auditoría
- Lote 0.3 — Infra mínima funcional

### Criterios de aceptación (OBLIGATORIOS)

- [ ] Dos organizaciones distintas no pueden verse entre sí
- [ ] Superadmin ve todo el sistema
- [ ] Org Admin solo ve su organización
- [ ] Referente / Aprendiz solo ven su local
- [ ] Usuarios archivados no pueden loguearse
- [ ] Usuarios archivados pueden reactivarse sin perder historial
- [ ] Transferencia de local solo intra-org
- [ ] Todas las acciones críticas escriben en `audit_logs`
- [ ] Playwright: login por rol pasa

### Estado esperado al cerrar

👉 Sistema estable, seguro y listo para construir features.

---

## 📚 M2 — Contenido Operable (Course Builder)

### Objetivo

Permitir crear, editar y asignar **cursos reales y usables**.

### Incluye

- Lote 1.1 — Estructura de cursos
- Lote 1.2 — Editor de lecciones
- Lote 1.3 — Importación de contenido

### Criterios de aceptación

- [ ] Curso mínimo viable publicable (título + 1 unidad + 1 lección + quiz final)
- [ ] Editor guarda contenido como JSON (no HTML crudo)
- [ ] Vista previa del curso funciona
- [ ] Importación desde texto/PDF con preview obligatorio
- [ ] Errores de formato se informan claramente
- [ ] Importación parcial permitida
- [ ] Cursos visibles solo en locales asignados

### Estado esperado

👉 Se pueden crear y asignar cursos sin fricción.

---

## 🧠 M3 — Evaluación Funcional (Quiz Engine)

### Objetivo

Implementar el **motor de evaluación** completo y confiable.

### Incluye

- Lote 2.1 — Pool de preguntas
- Lote 2.2 — Estados, sesiones e intentos
- Lote 2.3 — Edge Functions críticas
- Lote 2.4 — UX de quizzes

### Criterios de aceptación

- [ ] Preguntas pertenecen a unidades (pool)
- [ ] Selección aleatoria prioriza preguntas no vistas
- [ ] Feedback inmediato por pregunta
- [ ] Cooldown de 6h aplicado correctamente
- [ ] Reset de intentos agrega intentos, no borra historial
- [ ] `quiz_answers_log` registra 1 fila por pregunta
- [ ] Todo intento es auditable

### Estado esperado

👉 El core del producto funciona end-to-end.

---

## 👤 M4 — Experiencia Completa del Aprendiz

### Objetivo

Que un aprendiz pueda **capacitarse solo**, sin fricción.

### Incluye

- Lote 3.1 — Home del Aprendiz
- Lote 3.2 — Navegación completa del curso

### Criterios de aceptación

- [ ] El aprendiz ve cursos en progreso y disponibles
- [ ] El progreso es siempre visible
- [ ] Puede navegar libremente por lecciones
- [ ] El quiz final se desbloquea solo al cumplir condiciones
- [ ] Curso puede completarse end-to-end

### Estado esperado

👉 Experiencia clara, usable y mobile-first.

---

## 🧭 M5 — Operación B2B (Referente y Org Admin)

### Objetivo

Permitir a la empresa **gestionar y monitorear** la capacitación.

### Incluye

- Lote 4.1 — Dashboard Referente
- Lote 4.2 — Dashboard Org Admin

### Criterios de aceptación

- [ ] Referente ve solo su local
- [ ] Referente detecta usuarios en riesgo
- [ ] Referente puede resetear intentos (auditado)
- [ ] Org Admin ve todos los locales de su org
- [ ] Org Admin asigna cursos a locales
- [ ] Org Admin gestiona usuarios (transferir, archivar)

### Estado esperado

👉 Operación diaria B2B cubierta.

---

## 📊 M6 — Inteligencia y Analytics

### Objetivo

Convertir datos en **insights accionables**.

### Incluye

- Lote 5.1 — Métricas base
- Lote 5.2 — Analytics por pregunta

### Criterios de aceptación

- [ ] Usuarios en riesgo identificables
- [ ] Unidades con alta tasa de fallo visibles
- [ ] Preguntas problemáticas detectables
- [ ] Distractores más elegidos visibles
- [ ] Datos consistentes con answers_log

### Estado esperado

👉 ONBO pasa de LMS a sistema inteligente.

---

## 🧩 M7 — Producto Escalable (Feature Flags)

### Objetivo

Controlar capacidades sin forks ni deploys.

### Incluye

- Lote 6.1 — Infraestructura de feature flags
- Lote 6.2 — Capacidades por plan

### Criterios de aceptación

- [ ] Flags se validan en backend
- [ ] Flags cambian comportamiento real
- [ ] No se pierde data al apagar flags
- [ ] Cambios de flags auditados

### Estado esperado

👉 Producto controlable y escalable comercialmente.

---

## 🧪 M8 — Release Candidate (Hardening)

### Objetivo

Preparar ONBO para uso real en producción.

### Incluye

- Lote 7.1 — Playwright E2E
- Lote 7.2 — Auditoría final

### Criterios de aceptación

- [ ] Flujos críticos cubiertos por E2E
- [ ] No bypass de RLS detectado
- [ ] Edge Functions seguras
- [ ] Performance aceptable
- [ ] Sin deuda estructural conocida

### Estado esperado

👉 ONBO listo para clientes reales.

---

## Regla Final

> ❗ No se abre un milestone nuevo si el anterior no está cerrado.

Este documento es **fuente única de verdad** para el avance del proyecto.

Estado del documento: **ACTIVO**

```

---
```
