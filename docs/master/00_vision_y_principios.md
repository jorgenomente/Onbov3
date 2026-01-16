# 📘 00 — Visión y Principios (VERSIÓN RECOMENDADA)

```md
# ONBO — LMS Corporativo Mobile-First para Deskless Workers

Estado: Master Spec FINAL v1.1  
Rol: Documento fundacional — Fuente conceptual de verdad

---

## Visión del Producto

ONBO es una plataforma de capacitación corporativa B2B diseñada para
operativos (“deskless workers”), con foco en:

- experiencia mobile-first real
- aprendizaje medible
- control por ubicación física (Locales)
- mejora continua basada en datos

ONBO no es un LMS tradicional:
es un **sistema de aprendizaje operado por analytics**.

---

## Principios No Negociables

1. **Mobile-first real**
   - Todo el sistema debe ser usable desde un teléfono.
2. **Zero Trust**
   - El frontend no es fuente de verdad.
3. **PostgreSQL como fuente única**
   - Permisos y reglas viven en RLS y backend.
4. **Multi-tenant estricto**
   - Los datos nunca cruzan organizaciones.
5. **Auditabilidad**
   - Acciones críticas siempre registradas.
6. **Historial inmutable**
   - El pasado no se reescribe.

---

## Jerarquía Conceptual del Sistema
```

Plataforma
└── Organización
└── Local
└── Usuario

```

- Los usuarios pertenecen a **un solo Local**
- Los cursos se asignan a **Locales**, no a usuarios
- El Local es la unidad operativa clave

---

## Filosofía de Contenido y Evaluación

- El contenido se estructura en:
  - Cursos → Unidades → Lecciones
- Las preguntas:
  - pertenecen a Unidades
  - no a exámenes
- Los exámenes:
  - seleccionan preguntas dinámicamente
- El aprendizaje se valida con:
  - evidencia
  - no con completado superficial

---

## Filosofía de Evolución del Producto

- No hay borrados físicos
- No hay versionado explícito de cursos
- Los usuarios ven:
  - la versión que completaron
- El sistema evoluciona sin romper historial

---

## Referencias Canónicas

Este documento **no contiene detalles operativos**.
Para definición completa, ver:

- Roles y permisos → `01_roles_y_permisos.md`
- Navegación → `02_sitemap_y_navegacion.md`
- Course Builder → `03_course_builder.md`
- Quiz Engine → `04_quiz_engine.md`
- Analytics → `07_analytics_y_metricas.md`
- Lifecycle → `09_lifecycle_cursos_usuarios.md`
- Apéndice técnico → `10_apendice_tecnico.md`

---

Estado del documento: **CERRADO**
```

---

## Qué ganás con este ajuste

✔️ Un Doc 00 **estable durante años**
✔️ Menos mantenimiento
✔️ Menos contradicciones
✔️ Claridad total para devs nuevos
✔️ Cada documento tiene un propósito claro

---
