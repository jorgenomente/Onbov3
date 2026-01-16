01 — Roles y Permisos (RBAC)
Propósito del documento

Este documento define de forma exhaustiva y no ambigua:

Los roles del sistema

Su alcance jerárquico

Qué acciones pueden y no pueden realizar

Cómo se asignan, transicionan y restringen

Las reglas duras de seguridad que gobiernan el acceso

Este es el único lugar canónico donde se definen permisos.
Otros documentos referencian este, pero no duplican lógica de roles.

Principios generales de RBAC en ONBO

Un solo rol por usuario

El rol determina:

Qué datos puede ver

Qué acciones puede ejecutar

El alcance real se deriva de la jerarquía:

Usuario → Local → Organización

El frontend no es fuente de verdad:

Todo permiso se valida en PostgreSQL (RLS) o Edge Functions

Las acciones críticas:

Se ejecutan exclusivamente vía backend

Se auditan obligatoriamente

Jerarquía de alcance
Nivel Descripción
Plataforma Acceso global (todas las organizaciones)
Organización Acceso a todos los locales de una organización
Local Acceso restringido a un único local
Usuario Acceso únicamente a su propio progreso
Definición de Roles
Rol: Superadmin
Alcance

Global (Plataforma)

Descripción

Usuario con control total del sistema.
No pertenece a ningún Local por defecto, pero puede ingresar a cualquier Organización y operar exactamente como un Org Admin, además de tener capacidades globales adicionales.

Capacidades

Crear, editar y archivar Organizaciones

Acceder a cualquier Organización y Local

Ver y gestionar:

Usuarios

Cursos

Progreso

Quizzes

Analytics

Gestionar la Librería Maestra de Cursos

Crear, duplicar y modificar cursos globales

Asignar cursos a Organizaciones

Entrar a una Organización y:

Asignar cursos a Locales

Gestionar miembros

Invitar usuarios de cualquier rol

Configurar Feature Flags por Organización

Acceder a analytics globales

Acceder a logs y auditoría

Restricciones

Ninguna a nivel de datos

Todas las acciones críticas deben quedar auditadas

Rol: Org Admin
Alcance

Organización

Descripción

Administrador de una organización.
Tiene control total sobre los Locales, usuarios y cursos dentro de su organización.

Capacidades

Crear, editar y archivar Locales

Ver todos los Locales de la organización

Invitar:

Referentes

Aprendices

Asignar cursos a Locales

Editar cursos asignados a la organización

Ver analytics completos de la organización

Ver progreso detallado de todos los usuarios

Transferir usuarios entre Locales de la misma organización

Archivar usuarios (desactivación lógica)

Capacidades condicionales (Feature Flag)

Crear cursos desde cero

Solo si org_can_create_courses = true

Usa el mismo Course Builder avanzado que el Superadmin

Restricciones

No puede acceder a otras organizaciones

No puede modificar configuraciones globales de la plataforma

No puede ver analytics globales

Rol: Referente
Alcance

Local (único)

Descripción

Responsable operativo del proceso de capacitación en un Local específico.
Su foco es monitorear, acompañar y destrabar el aprendizaje.

Capacidades

Ver todos los aprendices de su Local

Ver progreso detallado por aprendiz:

Cursos

Unidades

Lecciones

Quizzes

Intentos

Respuestas correctas e incorrectas

Ver analytics del Local

Identificar:

Usuarios en riesgo

Unidades/preguntas problemáticas

Resetear intentos de quiz

Agrega 3 intentos adicionales

No borra historial

Acción obligatoriamente auditada

Invitar nuevos Aprendices al Local

Restricciones

No puede:

Ver otros Locales

Editar cursos

Asignar cursos

No puede modificar configuraciones de la organización

Rol: Aprendiz
Alcance

Local (único)

Descripción

Usuario final del sistema. Consume cursos y rinde evaluaciones.

Capacidades

Ver cursos:

Asignados a su Local

Consumir lecciones

Rendir quizzes de unidad

Rendir quiz final (cuando se habilita)

Ver:

Resultados

Notas

Feedback por pregunta

Estado de aprobación

Revisitar contenido y resultados de cursos completados

Ver información básica de su Local y Organización

Restricciones

No puede ver:

Otros usuarios

Otros Locales

No puede:

Invitar usuarios

Editar contenido

Resetear intentos

Transiciones y cambios de rol
Cambio de rol

Un usuario puede cambiar de rol solo por Org Admin o Superadmin

El cambio de rol:

Afecta inmediatamente la experiencia al próximo login

Cambia completamente la UI visible

El historial de aprendizaje:

No se pierde

Se conserva aunque el usuario deje de ser Aprendiz

Transferencia de Local

Permitida solo dentro de la misma Organización

El usuario conserva:

Cursos completados

Certificaciones

Historial

Accede únicamente a los cursos asignados al nuevo Local

Usuarios archivados (desactivación)
Definición

Un usuario archivado:

No puede iniciar sesión

No aparece en listados activos

Mantiene todo su historial

Quién puede archivar

Org Admin

Superadmin

Uso

Baja operativa

Rotación de personal

Auditoría histórica

Reglas duras de seguridad

Nunca confiar en datos enviados por el cliente para permisos

El local_id del usuario se deriva siempre desde su perfil

El org_id se deriva por relación:

profile.local_id → locales.org_id

Todas las validaciones críticas:

Ocurren en PostgreSQL (RLS)

O en Edge Functions

Toda acción crítica:

Se audita

No se puede borrar ni modificar

Referencias

Visión general y principios: 00_vision_y_principios.md

Navegación y UX por rol: 02_sitemap_y_navegacion.md

Ciclo de vida de usuarios: 09_lifecycle_cursos_usuarios.md

✅ Estado del documento

Este documento se considera cerrado.
Cualquier cambio futuro en roles o permisos requiere:

Revisión explícita

Actualización controlada

Aprobación de arquitectura
