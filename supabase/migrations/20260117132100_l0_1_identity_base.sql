create extension if not exists "pgcrypto";

do $$
begin
  if not exists (select 1 from pg_type where typname = 'org_status') then
    create type public.org_status as enum ('active', 'archived');
  end if;
  if not exists (select 1 from pg_type where typname = 'local_status') then
    create type public.local_status as enum ('active', 'archived');
  end if;
  if not exists (select 1 from pg_type where typname = 'profile_status') then
    create type public.profile_status as enum ('active', 'archived');
  end if;
  if not exists (select 1 from pg_type where typname = 'profile_role') then
    create type public.profile_role as enum ('superadmin', 'org_admin', 'referente', 'aprendiz');
  end if;
end $$;

create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  status public.org_status not null default 'active',
  created_at timestamptz not null default now()
);

create table public.locales (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organizations(id) on delete restrict,
  name text not null,
  status public.local_status not null default 'active',
  created_at timestamptz not null default now(),
  unique (id, org_id)
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role public.profile_role not null,
  org_id uuid references public.organizations(id) on delete restrict,
  local_id uuid,
  status public.profile_status not null default 'active',
  created_at timestamptz not null default now(),
  constraint profiles_role_scope_check check (
    (role = 'superadmin' and org_id is null and local_id is null) or
    (role = 'org_admin' and org_id is not null and local_id is null) or
    (role in ('referente', 'aprendiz') and org_id is not null and local_id is not null)
  ),
  constraint profiles_local_org_fk foreign key (local_id, org_id)
    references public.locales(id, org_id)
    on delete restrict
);

create index organizations_status_idx on public.organizations(status);
create index locales_org_id_idx on public.locales(org_id);
create index profiles_org_id_idx on public.profiles(org_id);
create index profiles_local_id_idx on public.profiles(local_id);
create index profiles_role_idx on public.profiles(role);

create or replace function public.current_org_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select org_id from public.profiles where id = auth.uid();
$$;

create or replace function public.current_local_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select local_id from public.profiles where id = auth.uid();
$$;

create or replace function public.has_role(role_name public.profile_role)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select role = role_name from public.profiles where id = auth.uid()), false);
$$;

create or replace function public.is_superadmin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_role('superadmin'::public.profile_role);
$$;

alter table public.organizations enable row level security;
alter table public.locales enable row level security;
alter table public.profiles enable row level security;

-- Drop policies if they already exist (safe re-apply in non-reset envs)
drop policy if exists organizations_superadmin_all on public.organizations;
drop policy if exists organizations_org_admin_select on public.organizations;

drop policy if exists locales_superadmin_all on public.locales;
drop policy if exists locales_org_admin_select on public.locales;
drop policy if exists locales_org_admin_insert on public.locales;
drop policy if exists locales_org_admin_update on public.locales;
drop policy if exists locales_local_member_select on public.locales;

drop policy if exists profiles_superadmin_all on public.profiles;
drop policy if exists profiles_org_admin_select on public.profiles;
drop policy if exists profiles_referente_select on public.profiles;
drop policy if exists profiles_aprendiz_select_self on public.profiles;

create policy organizations_superadmin_all
on public.organizations
for all
using (public.is_superadmin())
with check (public.is_superadmin());

create policy organizations_org_admin_select
on public.organizations
for select
using (public.has_role('org_admin'::public.profile_role) and id = public.current_org_id());

create policy locales_superadmin_all
on public.locales
for all
using (public.is_superadmin())
with check (public.is_superadmin());

create policy locales_org_admin_select
on public.locales
for select
using (
  public.has_role('org_admin'::public.profile_role)
  and org_id = public.current_org_id()
);

create policy locales_org_admin_insert
on public.locales
for insert
with check (
  public.has_role('org_admin'::public.profile_role)
  and org_id = public.current_org_id()
);

create policy locales_org_admin_update
on public.locales
for update
using (
  public.has_role('org_admin'::public.profile_role)
  and org_id = public.current_org_id()
)
with check (
  public.has_role('org_admin'::public.profile_role)
  and org_id = public.current_org_id()
);

create policy locales_local_member_select
on public.locales
for select
using (
  (public.has_role('referente'::public.profile_role) or public.has_role('aprendiz'::public.profile_role))
  and id = public.current_local_id()
);

create policy profiles_superadmin_all
on public.profiles
for all
using (public.is_superadmin())
with check (public.is_superadmin());

create policy profiles_org_admin_select
on public.profiles
for select
using (public.has_role('org_admin'::public.profile_role) and org_id = public.current_org_id());

create policy profiles_referente_select
on public.profiles
for select
using (public.has_role('referente'::public.profile_role) and local_id = public.current_local_id());

create policy profiles_aprendiz_select_self
on public.profiles
for select
using (public.has_role('aprendiz'::public.profile_role) and id = auth.uid());

revoke all on function public.current_org_id() from public;
revoke all on function public.current_local_id() from public;
revoke all on function public.has_role(public.profile_role) from public;
revoke all on function public.is_superadmin() from public;

grant execute on function public.current_org_id() to authenticated;
grant execute on function public.current_local_id() to authenticated;
grant execute on function public.has_role(public.profile_role) to authenticated;
grant execute on function public.is_superadmin() to authenticated;
