# send-invite-email

Edge Function para enviar invitaciones por email via Resend. No aplica permisos; solo llama `create_invite`.

## Env vars requeridas

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `RESEND_API_KEY`
- `RESEND_FROM`
- `APP_URL`
- `INVITE_CORS_ORIGINS` (comma-separated)

## Ejemplo curl

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
