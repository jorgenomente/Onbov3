# L0.3 — Auth Gates + Invitaciones

## Deploy Edge Function

Local:

```bash
supabase functions serve send-invite-email
```

Cloud:

```bash
supabase functions deploy send-invite-email
```

## Env vars requeridas

- `RESEND_API_KEY`
- `RESEND_FROM`
- `APP_URL`
- `INVITE_CORS_ORIGINS`

## Smoke checks

1. Org Admin llama Edge -> email enviado -> invite creado -> audit logs

```bash
curl -X POST "$SUPABASE_URL/functions/v1/send-invite-email" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "role": "aprendiz",
    "org_id": "00000000-0000-0000-0000-000000000000",
    "local_id": "00000000-0000-0000-0000-000000000000"
  }'
```

2. Abrir link -> signup -> `accept_invite` -> profile activo -> invite `used_at` seteado

3. Token reusado -> error `invite_used`

4. Usuario archived -> acceso bloqueado + audit `login_blocked_archived`

## SQL verification

```sql
select id, used_at, revoked_at, expires_at from public.invites;
select actor_id, entity_type, action from public.audit_logs order by id desc limit 5;
```
