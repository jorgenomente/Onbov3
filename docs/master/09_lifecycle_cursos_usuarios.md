# 09 — Lifecycle de Cursos y Usuarios

## Propósito del documento

Definir de forma **explícita, completa y sin ambigüedades**:

- Los estados posibles de **Usuarios** y **Cursos**
- Las **transiciones permitidas**
- El impacto de cada estado sobre:
  - Acceso
  - Progreso
  - Historial
  - Analytics

- Qué acciones están permitidas y por quién

Este documento es **crítico para la integridad del sistema**.
Nada se borra, nada se recalcula, todo queda trazable.

---

## Principios generales de Lifecycle

1. **Nada se elimina físicamente**
   - Todo es archivado o desactivado

2. **El historial es inmutable**
   - Cursos aprobados, intentos y notas nunca se modifican

3. **Estados explícitos**
   - No existen estados implícitos o “inferidos”

4. **Transiciones controladas**
   - Solo ciertos roles pueden cambiar estados

5. **Impacto predecible**
   - Cada estado tiene reglas claras de visibilidad y comportamiento

---

## Lifecycle de Usuarios

### Estados de Usuario

| Estado     | Descripción                                       |
| ---------- | ------------------------------------------------- |
| `active`   | Usuario operativo                                 |
| `archived` | Usuario desactivado (baja lógica, **reversible**) |

---

### Estado: `active`

#### Comportamiento

- Puede iniciar sesión
- Puede consumir cursos
- Puede rendir quizzes
- Aparece en dashboards operativos y analytics

#### Quién puede activarlo

- Org Admin
- Superadmin

---

### Estado: `archived`

#### Descripción

Usuario dado de baja operativa de forma **lógica y reversible**, sin pérdida de información.

#### Comportamiento

- ❌ No puede iniciar sesión
- ❌ No aparece en listados activos
- ✅ Aparece en históricos y reportes
- ✅ Conserva todo su historial:
  - Cursos completados
  - Notas
  - Intentos
  - Certificaciones

#### Quién puede archivarlo

- Org Admin
- Superadmin

---

### Reactivación de Usuarios Archivados

Un usuario en estado `archived` **puede ser reactivado**.

#### Quién puede reactivar

- Org Admin
- Superadmin

#### Efectos de la reactivación

- El usuario vuelve al estado `active`
- Puede iniciar sesión nuevamente
- Mantiene **todo su historial completo**
- Accede únicamente a:
  - Cursos asignados a su **Local actual**

#### Restricciones

La reactivación **NO**:

- Cambia el rol
- Cambia el Local
- Resetea intentos
- Modifica notas
- Recalcula progreso

---

### Transiciones de Usuario

```
active   ──► archived
archived ──► active
```

> No existe borrado definitivo de usuarios.

---

## Cambio de Rol y Transferencias

### Cambio de Rol

- Permitido solo a:
  - Org Admin
  - Superadmin

- Efectos:
  - El cambio aplica al próximo login
  - La UI y permisos visibles cambian completamente

- El historial de aprendizaje:
  - **Se conserva íntegro**

---

### Transferencia de Local

#### Reglas

- Permitida solo **dentro de la misma Organización**
- El usuario:
  - Conserva cursos completados
  - Conserva historial

- Accede únicamente a:
  - Cursos asignados al nuevo Local

#### Impacto en cursos

- Cursos no asignados al nuevo Local:
  - Dejan de ser visibles

- Cursos completados:
  - Siguen visibles en historial

---

## Lifecycle de Cursos

### Estados de Curso

| Estado     | Descripción                        |
| ---------- | ---------------------------------- |
| `draft`    | En creación / edición              |
| `active`   | Asignable a Locales                |
| `archived` | Retirado operativamente, histórico |

---

### Estado: `draft`

#### Comportamiento

- Visible solo para admins
- Editable completamente
- No visible para Aprendices

#### Transición permitida

```
draft ──► active
```

---

### Estado: `active`

#### Comportamiento

- Puede asignarse a uno o más Locales
- Visible para Aprendices del Local
- Puede modificarse bajo reglas controladas

#### Modificaciones en curso activo

- Usuarios **NO aprobados**:
  - Ven siempre la versión más reciente

- Usuarios **YA aprobados**:
  - Mantienen su versión congelada

> Esto garantiza consistencia histórica sin versionado explícito.

---

### Estado: `archived`

#### Descripción

Curso retirado de la operación diaria, pero conservado para auditoría y análisis.

#### Comportamiento

- ❌ No puede asignarse a nuevos Locales
- ❌ No aparece en listados activos
- ✅ Permanece visible:
  - En historial de usuarios
  - En analytics históricos

#### Transición permitida

```
active ──► archived
```

---

## Asignación y desasignación de Cursos a Locales

### Reglas generales

- Los cursos se asignan a **Locales**, no a usuarios
- Un curso puede:
  - Asignarse a múltiples Locales
  - Quitarse de un Local específico

### Quitar curso de un Local

| Estado del usuario | Comportamiento       |
| ------------------ | -------------------- |
| No iniciado        | Deja de ver el curso |
| En progreso        | Puede continuarlo    |
| Aprobado           | Conserva historial   |

---

## Lifecycle de Quizzes e Intentos

### Quizzes

- No tienen lifecycle independiente
- Su existencia depende del Curso y Unidad

### Intentos

- Nunca se borran
- Nunca se recalculan
- Siempre visibles en analytics

---

## Certificaciones y Evidencia

### Evidencia de aprobación de curso

Para cada curso aprobado se registra:

- Usuario
- Curso
- Nota final
- Fecha de aprobación
- Evidencia completa:
  - Quizzes de unidad aprobados
  - Quiz final aprobado

### Uso de la evidencia

- Auditoría
- Cumplimiento
- Reportes
- Validaciones externas

---

## Archivado vs Eliminación (regla dura)

- Archivado ≠ Eliminación
- Eliminación física **no existe** en ONBO
- Todo lo archivado:
  - Es invisible para la operación diaria
  - Es visible para históricos y analytics

---

## Reglas duras (inviolables)

1. Nunca borrar usuarios ni cursos
2. Nunca modificar históricos
3. Todas las transiciones están limitadas por rol
4. El archivado es reversible solo para usuarios
5. El sistema debe mostrar siempre el estado actual de forma clara

---

## Referencias

- Roles y permisos: `01_roles_y_permisos.md`
- Dashboards: `06_dashboards_referente_org.md`
- Analytics: `07_analytics_y_metricas.md`

---

### ✅ Estado del documento

Este documento se considera **FINAL y CERRADO**.
Cualquier cambio futuro debe:

- Ser explícito
- Evaluar impacto en historial y analytics
- Aprobarse a nivel de arquitectura

---
