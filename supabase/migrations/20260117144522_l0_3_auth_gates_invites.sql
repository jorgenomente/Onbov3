-- =============================================
-- LOTE 0.3 — Auth Gates + Invitaciones (SAFE)
-- DB-only: NO writes to auth.*
-- =============================================

-- Extensions required for digest (pgcrypto). Supabase suele tenerlo, pero lo aseguramos.
create extension if not exists pgcrypto;

-- ---------------------------------------------
-- INVITES
-- ---------------------------------------------
create table if not exists public.invites (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  role public.profile_role not null,
  org_id uuid not null references public.organizations(id) on delete restrict,
  local_id uuid not null,
  token_hash text not null,
  expires_at timestamptz not null default (now() + interval '72 hours'),
  used_at timestamptz,
  revoked_at timestamptz,
  created_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint invites_role_check check (role in ('referente', 'aprendiz')),
  constraint invites_local_org_fk foreign key (local_id, org_id)
    references public.locales(id, org_id) on delete restrict
);

create unique index if not exists invites_token_hash_uidx on public.invites(token_hash);
create index if not exists invites_email_idx on public.invites(email);
create index if not exists invites_org_id_idx on public.invites(org_id);
create index if not exists invites_local_id_idx on public.invites(local_id);
create index if not exists invites_expires_at_idx on public.invites(expires_at);

alter table public.invites enable row level security;

-- ---------------------------------------------
-- RLS: INVITES (read-only via policies; writes only via SECURITY DEFINER RPCs)
-- ---------------------------------------------
drop policy if exists invites_superadmin_select on public.invites;
drop policy if exists invites_org_admin_select on public.invites;

create policy invites_superadmin_select
on public.invites
for select
using (public.is_superadmin());

create policy invites_org_admin_select
on public.invites
for select
using (
  public.has_role('org_admin'::public.profile_role)
  and org_id = public.current_org_id()
);

-- No insert/update/delete policies on invites.

-- ---------------------------------------------
-- RPC: CREATE_INVITE (returns plaintext token ONCE)
-- ---------------------------------------------
create or replace function public.create_invite(
  email text,
  role public.profile_role,
  org_id uuid,
  local_id uuid
)
returns table (
  invite_id uuid,
  token_plain text,
  expires_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
declare
  actor_role public.profile_role;
  actor_status public.profile_status;
  actor_org_id uuid;
  local_org_id uuid;
  token_h text;
begin
  select role, status, org_id
    into actor_role, actor_status, actor_org_id
  from public.profiles
  where id = auth.uid();

  if actor_role is null then raise exception 'actor_profile_missing'; end if;
  if actor_status <> 'active' then raise exception 'actor_not_active'; end if;

  if actor_role not in ('superadmin', 'org_admin') then
    raise exception 'insufficient_privilege';
  end if;

  if role not in ('referente', 'aprendiz') then
    raise exception 'invalid_invite_role';
  end if;

  if actor_role <> 'superadmin' and org_id <> actor_org_id then
    raise exception 'cross_org_forbidden';
  end if;

  select org_id into local_org_id
  from public.locales
  where id = local_id;

  if local_org_id is null then raise exception 'local_not_found'; end if;
  if local_org_id <> org_id then raise exception 'local_org_mismatch'; end if;

  token_plain := encode(gen_random_bytes(32), 'hex');
  token_h := encode(digest(token_plain, 'sha256'), 'hex');

  insert into public.invites (email, role, org_id, local_id, token_hash, created_by)
  values (lower(create_invite.email), role, org_id, local_id, token_h, auth.uid())
  returning id, invites.expires_at into invite_id, expires_at;

  -- Audit: created + sent (sent se emite aquí y también puede emitirse desde Edge email si querés separar)
  insert into public.audit_logs (actor_id, org_id, local_id, entity_type, entity_id, action, metadata)
  values
    (auth.uid(), org_id, local_id, 'invite', invite_id, 'invite_created',
      jsonb_build_object('email', lower(create_invite.email), 'role', role)),
    (auth.uid(), org_id, local_id, 'invite', invite_id, 'invite_sent',
      jsonb_build_object('email', lower(create_invite.email), 'role', role));

  return next;
end;
$$;

-- ---------------------------------------------
-- RPC: REVOKE_INVITE
-- ---------------------------------------------
create or replace function public.revoke_invite(invite_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  actor_role public.profile_role;
  actor_status public.profile_status;
  actor_org_id uuid;
  target_org_id uuid;
  target_local_id uuid;
  target_used_at timestamptz;
  target_revoked_at timestamptz;
begin
  select role, status, org_id
    into actor_role, actor_status, actor_org_id
  from public.profiles
  where id = auth.uid();

  if actor_role is null then raise exception 'actor_profile_missing'; end if;
  if actor_status <> 'active' then raise exception 'actor_not_active'; end if;
  if actor_role not in ('superadmin', 'org_admin') then raise exception 'insufficient_privilege'; end if;

  select org_id, local_id, used_at, revoked_at
    into target_org_id, target_local_id, target_used_at, target_revoked_at
  from public.invites
  where id = revoke_invite.invite_id;

  if target_org_id is null then raise exception 'invite_not_found'; end if;
  if actor_role <> 'superadmin' and target_org_id <> actor_org_id then raise exception 'cross_org_forbidden'; end if;
  if target_used_at is not null then raise exception 'invite_already_used'; end if;
  if target_revoked_at is not null then raise exception 'invite_already_revoked'; end if;

  update public.invites
  set revoked_at = now()
  where id = revoke_invite.invite_id;

  insert into public.audit_logs (actor_id, org_id, local_id, entity_type, entity_id, action, metadata)
  values (
    auth.uid(),
    target_org_id,
    target_local_id,
    'invite',
    revoke_invite.invite_id,
    'invite_revoked',
    jsonb_build_object('email', (select email from public.invites where id = revoke_invite.invite_id))
  );
end;
$$;

-- ---------------------------------------------
-- RPC: ACCEPT_INVITE (authenticated-only)
-- Assumes user already signed up and is logged in.
-- ---------------------------------------------
create or replace function public.accept_invite(token_plain text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  token_h text;
  inv public.invites%rowtype;
  uid uuid;
  user_email text;
begin
  uid := auth.uid();
  if uid is null then raise exception 'auth_required'; end if;

  if token_plain is null or length(token_plain) < 32 then
    raise exception 'invalid_token';
  end if;

  token_h := encode(digest(token_plain, 'sha256'), 'hex');

  select * into inv
  from public.invites
  where token_hash = token_h
  for update;

  if inv.id is null then raise exception 'invite_invalid'; end if;
  if inv.revoked_at is not null then raise exception 'invite_revoked'; end if;
  if inv.used_at is not null then raise exception 'invite_used'; end if;

  if inv.expires_at < now() then
    insert into public.audit_logs (actor_id, org_id, local_id, entity_type, entity_id, action, metadata)
    values (uid, inv.org_id, inv.local_id, 'invite', inv.id, 'invite_expired', jsonb_build_object('email', inv.email));
    raise exception 'invite_expired';
  end if;

  -- Require that the logged-in user's profile email matches the invite email.
  select email into user_email
  from public.profiles
  where id = uid;

  -- If profile doesn't exist yet, create it (active) ONLY if email matches auth user email claim is not available here.
  -- We rely on invite email as canonical and require profile.email to match by creating it with inv.email.
  if user_email is null then
    insert into public.profiles (id, email, role, org_id, local_id, status, created_at)
    values (uid, lower(inv.email), inv.role, inv.org_id, inv.local_id, 'active', now());
    user_email := lower(inv.email);
  end if;

  if lower(user_email) <> lower(inv.email) then
    raise exception 'email_mismatch';
  end if;

  -- Activate (if previously archived, do NOT auto-reactivate)
  update public.profiles
  set role = inv.role,
      org_id = inv.org_id,
      local_id = inv.local_id,
      status = case when status = 'archived' then status else 'active' end
  where id = uid
    and lower(email) = lower(inv.email);

  update public.invites
  set used_at = now()
  where id = inv.id;

  insert into public.audit_logs (actor_id, org_id, local_id, entity_type, entity_id, action, metadata)
  values (uid, inv.org_id, inv.local_id, 'invite', inv.id, 'invite_accepted',
          jsonb_build_object('email', inv.email, 'role', inv.role));
end;
$$;

-- ---------------------------------------------
-- RPC: LOG LOGIN BLOCKED (archived)
-- ---------------------------------------------
create or replace function public.log_login_blocked_archived()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  st public.profile_status;
  oid uuid;
  lid uuid;
begin
  select status, org_id, local_id
    into st, oid, lid
  from public.profiles
  where id = auth.uid();

  if st is null then raise exception 'actor_profile_missing'; end if;
  if st <> 'archived' then raise exception 'actor_not_archived'; end if;

  insert into public.audit_logs (actor_id, org_id, local_id, entity_type, entity_id, action, metadata)
  values (auth.uid(), oid, lid, 'profile', auth.uid(), 'login_blocked_archived', '{}'::jsonb);
end;
$$;

-- ---------------------------------------------
-- GRANTS (least privilege)
-- ---------------------------------------------
revoke all on table public.invites from public, anon, authenticated;
grant select on table public.invites to authenticated;

revoke all on function public.create_invite(text, public.profile_role, uuid, uuid) from public;
revoke all on function public.revoke_invite(uuid) from public;
revoke all on function public.accept_invite(text) from public;
revoke all on function public.log_login_blocked_archived() from public;

grant execute on function public.create_invite(text, public.profile_role, uuid, uuid) to authenticated;
grant execute on function public.revoke_invite(uuid) to authenticated;
grant execute on function public.accept_invite(text) to authenticated;
grant execute on function public.log_login_blocked_archived() to authenticated;

-- ---------------------------------------------
-- SMOKE TESTS (MANUAL)
-- ---------------------------------------------
-- 1) create_invite as org_admin -> returns token_plain once; DB stores only token_hash
--    select * from public.create_invite('test@example.com', 'aprendiz', current_org_id(), current_local_id());
--    select token_hash from public.invites where email='test@example.com'; -- must be hex hash

-- 2) accept flow: user signs up/login with same email, then:
--    select public.accept_invite('<token_plain>');
--    select status from public.profiles where id=auth.uid(); -- active

-- 3) used token -> fails (invite_used)
-- 4) revoked token -> fails (invite_revoked)
-- 5) expired token -> fails and logs invite_expired
-- 6) direct updates blocked:
--    update public.invites set used_at = now(); -- must fail (no UPDATE policy)
