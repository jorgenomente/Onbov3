drop function if exists public.accept_invite(text, text);

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
  token_hash text;
begin
  select role, status, org_id
    into actor_role, actor_status, actor_org_id
  from public.profiles
  where id = auth.uid();

  if actor_role is null then
    raise exception 'actor_profile_missing';
  end if;

  if actor_status = 'archived' then
    raise exception 'actor_archived';
  end if;

  if actor_role not in ('superadmin', 'org_admin') then
    raise exception 'insufficient_privilege';
  end if;

  if role not in ('referente', 'aprendiz') then
    raise exception 'invalid_invite_role';
  end if;

  if actor_role <> 'superadmin' and org_id <> actor_org_id then
    raise exception 'cross_org_forbidden';
  end if;

  select org_id
    into local_org_id
  from public.locales
  where id = local_id;

  if local_org_id is null then
    raise exception 'local_not_found';
  end if;

  if local_org_id <> org_id then
    raise exception 'local_org_mismatch';
  end if;

  if exists (
    select 1
    from auth.users
    where lower(email) = lower(create_invite.email)
  ) then
    raise exception 'email_already_registered';
  end if;

  token_plain := encode(gen_random_bytes(32), 'hex');
  token_hash := encode(digest(token_plain, 'sha256'), 'hex');

  insert into public.invites (
    email,
    role,
    org_id,
    local_id,
    token_hash,
    created_by
  )
  values (
    lower(create_invite.email),
    role,
    org_id,
    local_id,
    token_hash,
    auth.uid()
  )
  returning id, invites.expires_at into invite_id, expires_at;

  insert into public.audit_logs (
    actor_id,
    org_id,
    local_id,
    entity_type,
    entity_id,
    action,
    metadata
  )
  values
  (
    auth.uid(),
    org_id,
    local_id,
    'invite',
    invite_id,
    'invite_created',
    jsonb_build_object('email', lower(create_invite.email), 'role', role)
  ),
  (
    auth.uid(),
    org_id,
    local_id,
    'invite',
    invite_id,
    'invite_sent',
    jsonb_build_object('email', lower(create_invite.email), 'role', role)
  );

  return next;
end;
$$;

create or replace function public.accept_invite(token_plain text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  token_hash text;
  invite_id uuid;
  invite_email text;
  invite_role public.profile_role;
  invite_org_id uuid;
  invite_local_id uuid;
  invite_expires_at timestamptz;
  invite_used_at timestamptz;
  invite_revoked_at timestamptz;
  profile_status public.profile_status;
begin
  if auth.uid() is null then
    raise exception 'auth_required';
  end if;

  if token_plain is null or length(token_plain) < 32 then
    raise exception 'invalid_token';
  end if;

  token_hash := encode(digest(token_plain, 'sha256'), 'hex');

  select id,
         email,
         role,
         org_id,
         local_id,
         expires_at,
         used_at,
         revoked_at
    into invite_id,
         invite_email,
         invite_role,
         invite_org_id,
         invite_local_id,
         invite_expires_at,
         invite_used_at,
         invite_revoked_at
  from public.invites
  where public.invites.token_hash = token_hash
  for update;

  if invite_id is null then
    raise exception 'invite_invalid';
  end if;

  if invite_revoked_at is not null then
    raise exception 'invite_revoked';
  end if;

  if invite_used_at is not null then
    raise exception 'invite_used';
  end if;

  if invite_expires_at < now() then
    insert into public.audit_logs (
      actor_id,
      org_id,
      local_id,
      entity_type,
      entity_id,
      action,
      metadata
    )
    values (
      auth.uid(),
      invite_org_id,
      invite_local_id,
      'invite',
      invite_id,
      'invite_expired',
      jsonb_build_object('email', invite_email)
    );

    raise exception 'invite_expired';
  end if;

  if lower(auth.email()) <> lower(invite_email) then
    raise exception 'email_mismatch';
  end if;

  select status
    into profile_status
  from public.profiles
  where id = auth.uid();

  if profile_status = 'archived' then
    raise exception 'actor_archived';
  end if;

  if profile_status is null then
    insert into public.profiles (
      id,
      email,
      role,
      org_id,
      local_id,
      status,
      created_at
    )
    values (
      auth.uid(),
      lower(invite_email),
      invite_role,
      invite_org_id,
      invite_local_id,
      'active',
      now()
    );
  elsif profile_status = 'pending' then
    update public.profiles
    set status = 'active'
    where id = auth.uid();
  end if;

  update public.invites
  set used_at = now()
  where id = invite_id;

  insert into public.audit_logs (
    actor_id,
    org_id,
    local_id,
    entity_type,
    entity_id,
    action,
    metadata
  )
  values (
    auth.uid(),
    invite_org_id,
    invite_local_id,
    'invite',
    invite_id,
    'invite_accepted',
    jsonb_build_object('email', invite_email, 'role', invite_role)
  );
end;
$$;

revoke all on function public.accept_invite(text) from public;
revoke all on function public.accept_invite(text) from anon, authenticated;
grant execute on function public.accept_invite(text) to authenticated;
