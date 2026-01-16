02 — Sitemap y Navegación (Mobile-First)
Propósito del documento

Este documento define de manera explícita y no ambigua:

El sitemap completo de ONBO

La estructura de URLs

Los menús de navegación por rol

La experiencia inicial (home) de cada tipo de usuario

Principios de navegación mobile-first

Este documento es la única referencia válida para rutas y navegación.
Ninguna pantalla debe crearse sin estar contemplada aquí.

Principios de navegación en ONBO

Mobile-first estricto

Todo el sistema debe ser completamente usable en móvil.

Menús cortos (máx. 4–5 ítems visibles).

URLs semánticas

Las rutas reflejan intención, no implementación.

Separación clara por rol

Un usuario ve una sola navegación según su rol activo.

No exponer jerarquía sensible en la URL

org_id y local_id no se usan como filtros funcionales desde el cliente.

Accesos predecibles

El usuario siempre sabe “dónde está” y “qué sigue”.

Convención general de rutas
Prefijo Uso principal
/superadmin Plataforma y librería global
/org Gestión de organización
/local Operación de un local
/app Experiencia del Aprendiz
Sitemap global (alto nivel)
/
├── /login
├── /app
├── /local
├── /org
└── /superadmin

Navegación por rol
Rol: Aprendiz
Home

Ruta: /app

Objetivo de la home

Saber:

Qué cursos está haciendo

Qué cursos puede empezar

Su estado general

Sitemap Aprendiz
/app
├── /courses
│ └── /[courseId]
│ ├── /overview
│ ├── /units/[unitId]
│ │ └── /lessons/[lessonId]
│ ├── /units/[unitId]/quiz
│ └── /final
├── /progress
└── /profile

Menú principal (mobile)

Cursos

Progreso

Perfil

Comportamientos clave

Cursos visibles solo si están asignados al Local

El quiz final aparece bloqueado hasta cumplir condiciones

Cursos completados son visitables en modo repaso

Rol: Referente
Home

Ruta: /local

Objetivo de la home

Obtener una visión inmediata del estado del Local

Detectar problemas rápidamente

Sitemap Referente
/local
├── /dashboard
├── /members
│ └── /[userId]
│ ├── /overview
│ ├── /courses/[courseId]
│ │ ├── /progress
│ │ └── /quizzes
│ └── /reset-attempts
├── /courses
│ └── /[courseId]/analytics
└── /invites

Menú principal (mobile)

Local

Personas

Cursos

Invitar

Comportamientos clave

Todas las vistas están limitadas al Local

Acceso a respuestas correctas/incorrectas por usuario

Reset de intentos siempre auditado

Rol: Org Admin
Home

Ruta: /org

Objetivo de la home

Ver la organización completa

Entrar a cada Local

Gestionar cursos y personas

Sitemap Org Admin
/org
├── /dashboard
├── /locals
│ └── /[localId]
│ ├── /dashboard
│ ├── /members
│ └── /courses
├── /courses
│ ├── /new (solo si flag activo)
│ └── /[courseId]
│ ├── /builder
│ └── /analytics
├── /members
└── /invites

Menú principal (mobile)

Organización

Locales

Cursos

Personas

Comportamientos clave

Puede ver lo mismo que un Referente dentro de cada Local

Puede asignar cursos a Locales

Puede crear cursos solo si el feature flag está activo

Rol: Superadmin
Home

Ruta: /superadmin

Objetivo de la home

Control total de la plataforma

Acceso rápido a Orgs y Librería

Sitemap Superadmin
/superadmin
├── /dashboard
├── /organizations
│ └── /[orgId]
│ ├── /dashboard
│ ├── /locals
│ ├── /members
│ └── /courses
├── /library
│ ├── /courses
│ │ ├── /new
│ │ └── /[courseId]/builder
│ ├── /assign
│ └── /duplicates
├── /analytics
└── /flags

Menú principal (mobile)

Plataforma

Organizaciones

Librería

Analytics

Comportamientos clave

Puede “entrar” a una org y operar como Org Admin

Controla feature flags

Gestiona cursos globales

Navegación transversal
Breadcrumbs

Obligatorios en vistas profundas:

Curso → Unidad → Lección

Org → Local → Usuario

Accesos rápidos

Desde cards y tablas:

Curso → Analytics

Usuario → Progreso

Local → Dashboard

Estados de navegación

Cada ruta debe contemplar:

Loading

Empty

Error

Forbidden (403 lógico)

Reglas duras

Ningún usuario puede acceder a rutas de otro rol

Cambiar de rol cambia completamente la navegación visible

El backend valida siempre el acceso real

No se renderizan menús “fantasma”

Referencias

Roles y permisos: 01_roles_y_permisos.md

Builder de cursos: 03_course_builder.md

Player Aprendiz: 05_player_aprendiz.md

✅ Estado del documento

Este documento se considera CERRADO.
Toda nueva pantalla debe:

Encajar en este sitemap

O justificar explícitamente su inclusión
