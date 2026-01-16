# 03 — Course Builder (CMS de Cursos)

## Propósito del documento

Definir de forma **explícita, completa y sin ambigüedades**:

- Cómo se crean cursos en ONBO
- Qué puede hacer cada rol en el builder
- Cómo funciona la importación (texto / PDF / paste)
- Cómo se editan unidades, lecciones y quizzes
- Qué reglas garantizan simplicidad, potencia y consistencia
- Qué UX se considera correcta y cuál no

Este documento define el **estándar de calidad del builder**.
Si el builder es malo, el producto falla.

---

## Principios del Course Builder

1. **Crear cursos debe ser fácil**
   - No debe requerir conocimiento técnico
   - No debe sentirse “pesado” ni burocrático

2. **El builder debe escalar en complejidad**
   - Simple para el 80%
   - Potente para el 20%

3. **Nunca romper cursos ya completados**
   - Usuarios completados ven su versión

4. **Importar > editar > confirmar**
   - Siempre preview antes de persistir

5. **El builder no asume estructura perfecta**
   - Detecta errores
   - Guía correcciones

---

## Roles que interactúan con el Builder

| Rol        | Puede crear | Puede editar | Puede asignar |
| ---------- | ----------- | ------------ | ------------- |
| Superadmin | ✅          | ✅           | ✅            |
| Org Admin  | ⚠️ (flag)   | ✅           | ✅            |
| Referente  | ❌          | ❌           | ❌            |
| Aprendiz   | ❌          | ❌           | ❌            |

⚠️ `org_can_create_courses = true` habilita creación desde Org.

---

## Estructura obligatoria de un Curso

```
Curso
├── Metadata
│   ├── Nombre
│   ├── Descripción
│   ├── Duración estimada
│   └── Estado (draft / active / archived)
├── Unidades (>=1)
│   ├── Lecciones (>=1)
│   └── Quiz de Unidad
└── Quiz Final (obligatorio)
```

### Mínimo viable

Un curso **no puede publicarse** si no tiene:

- Nombre
- 1 Unidad
- 1 Lección
- Quiz Final configurado

---

## Flujos principales del Builder

### 1. Crear curso desde cero

**Roles:** Superadmin / Org Admin (flag)

Pasos:

1. Ingresar nombre + metadata mínima
2. Crear primera unidad
3. Crear primera lección
4. Configurar quiz final
5. Guardar en estado `draft`
6. Asignar a Org (Superadmin)
7. Asignar a Local(es)

---

### 2. Duplicar curso existente

**Roles:** Superadmin

- Seleccionar curso existente
- “Duplicar curso”
- Cambiar nombre
- El duplicado:
  - Es completamente independiente
  - Se convierte automáticamente en una nueva plantilla

- Puede asignarse a otra Org

---

## Importación de contenido (Paste / PDF)

### Tipos de importación soportados

- Texto pegado (ChatGPT, Docs, Markdown)
- PDF

### Flujo de importación

1. Usuario pega texto o sube PDF
2. Sistema analiza estructura
3. Propone:
   - Unidades
   - Lecciones

4. Muestra **preview editable**
5. Marca errores de formato (si los hay)
6. Usuario corrige o confirma
7. Persistencia final

### Reglas del parser

- Headings → Unidades / Lecciones
- URLs de YouTube → iframe embebido
- Imágenes pegadas:
  - Se comprimen automáticamente
  - Se suben a bucket `course-media`
  - Se reemplazan por URL final

- Si no se puede parsear:
  - Se explica por qué
  - No se persiste nada

---

## Editor de Lecciones (Rich Text)

### Características

- Editor tipo Notion / Google Docs
- Soporta:
  - Texto enriquecido
  - Títulos
  - Links
  - Imágenes
  - Videos YouTube
  - Recursos embebidos

### UX obligatoria

- Autosave
- Undo / Redo
- Duplicar lección con un tap
- Vista previa instantánea

### Almacenamiento

- Contenido guardado como **JSON estructurado (Tiptap)**
- No HTML crudo

---

## Gestión de Unidades

### Funciones

- Crear / editar / eliminar
- Reordenar
- Duplicar unidad completa (lecciones + quiz)
- Asignar dificultad global (opcional)

---

## Quizzes dentro del Builder

### Principio clave

> El builder **no crea exámenes**, crea **pools de preguntas**.

### Quiz de Unidad

- Cada unidad tiene su quiz propio
- Configurable:
  - Cantidad de preguntas
  - Distribución por dificultad
  - Puntaje mínimo
  - Tiempo límite

- Las preguntas:
  - Pertenecen a la unidad
  - Están ancladas a una parte conceptual de la unidad

### Quiz Final

- Obligatorio para todo curso
- Usa preguntas de todas las unidades
- Configurable igual que los quizzes de unidad
- Se desbloquea solo al aprobar todos los quizzes de unidad

---

## Importación de Preguntas (Bulk)

### Formato

Formato ONBO-QUIZ (definido en apéndice técnico).

Cada pregunta debe incluir:

- Pregunta
- 4 opciones
- Opción correcta
- Dificultad
- Explicación (obligatoria)

### Comportamiento

- Importación parcial:
  - Preguntas inválidas se excluyen
  - Se explica el error y cómo corregirlo

- No se rechaza todo el lote
- No se detectan duplicados por texto

---

## Vista previa del curso (Preview Mode)

### Objetivo

Permitir al creador:

- Ver el curso **exactamente como un aprendiz**
- Sin cerrar sesión
- Sin cambiar de rol

### Comportamiento

- Navegación completa
- Quizzes funcionales
- Resultados no persistidos

---

## Estados del curso

| Estado   | Comportamiento           |
| -------- | ------------------------ |
| draft    | Visible solo para admins |
| active   | Asignable a locales      |
| archived | No visible a usuarios    |

Cursos archivados:

- No se eliminan
- Mantienen historial

---

## Reglas duras

1. Ningún curso se publica sin quiz final
2. Ningún quiz existe sin pool
3. Ninguna importación persiste sin preview
4. Cursos completados no cambian para ese usuario
5. Todo cambio estructural es auditable

---

## Referencias

- Roles y permisos: `01_roles_y_permisos.md`
- Sitemap y navegación: `02_sitemap_y_navegacion.md`
- Quiz Engine: `04_quiz_engine.md`

---

### ✅ Estado del documento

Este documento se considera **CERRADO**.
Cualquier cambio al builder requiere:

- Revisión de UX
- Revisión de impacto en quizzes
- Revisión de analytics

---
