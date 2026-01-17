# Audit — L0.1: Identity base + RLS

Date: 2026-01-17
Branch: feat/l0-1-rls-base

## Qué cambió

- Se creó el schema base: organizations, locales, profiles.
- Se agregaron enums de status/role.
- Helpers security definer: current_org_id, current_local_id, has_role, is_superadmin.
- RLS habilitado y policies por rol.
- Se endurecieron permisos de ejecución de helpers (revoke/grant).

## Por qué

- Fundar el aislamiento multi-tenant (org/local) con Zero Trust.
- Garantizar que el frontend no pueda filtrar org/local.
- Preparar base para invites, builder, player y analytics.

## Seguridad

- Multi-tenant derivado desde auth.uid() vía profiles y helpers.
- FK compuesto (local_id, org_id) evita asignación cross-org.
- Org Admin no tiene delete en locales (soft-archive futuro).
- Helpers security definer restringidos a authenticated.

## Cómo verificar

1. `npx supabase db reset` (OK)
2. Verificar RLS por rol:
   - superadmin: acceso total
   - org_admin: solo su org
   - referente/aprendiz: solo su local/self

## Riesgos y mitigaciones

- Risk: re-ejecución en entornos sin reset puede fallar por policies existentes.
  - Mitigación: se agregaron `drop policy if exists`.
