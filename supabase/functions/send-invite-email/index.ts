import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.48.1';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const resendApiKey = Deno.env.get('RESEND_API_KEY') ?? '';
const resendFrom = Deno.env.get('RESEND_FROM') ?? '';
const appUrl = Deno.env.get('APP_URL') ?? '';
const corsOrigins = Deno.env.get('INVITE_CORS_ORIGINS') ?? '';

const allowedOrigins = corsOrigins
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

if (
  !supabaseUrl ||
  !supabaseAnonKey ||
  !resendApiKey ||
  !resendFrom ||
  !appUrl
) {
  throw new Error('Missing required environment variables');
}

const corsHeaders = (origin: string | null) => ({
  'Access-Control-Allow-Origin': origin ?? '',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Max-Age': '86400',
  Vary: 'Origin',
});

const isAllowedOrigin = (origin: string | null) => {
  if (!origin) return true;
  if (allowedOrigins.length === 0) return true;
  return allowedOrigins.includes(origin);
};

Deno.serve(async (req) => {
  const origin = req.headers.get('origin');

  if (!isAllowedOrigin(origin)) {
    return new Response('Origin not allowed', { status: 403 });
  }

  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }

  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', {
      status: 405,
      headers: corsHeaders(origin),
    });
  }

  const authHeader = req.headers.get('authorization');
  if (!authHeader) {
    return new Response('Unauthorized', {
      status: 401,
      headers: corsHeaders(origin),
    });
  }

  const body = await req.json().catch(() => null);
  const email = body?.email;
  const role = body?.role;
  const orgId = body?.org_id;
  const localId = body?.local_id;

  if (!email || !role || !orgId || !localId) {
    return new Response('Invalid payload', {
      status: 400,
      headers: corsHeaders(origin),
    });
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data, error } = await supabase.rpc('create_invite', {
    email,
    role,
    org_id: orgId,
    local_id: localId,
  });

  if (error || !data || data.length === 0) {
    return new Response(
      JSON.stringify({ error: error?.message ?? 'invite_failed' }),
      {
        status: 400,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      },
    );
  }

  const invite = data[0];
  const acceptUrl = new URL('/accept-invite', appUrl);
  acceptUrl.searchParams.set('token', invite.token_plain);

  const emailPayload = {
    from: resendFrom,
    to: email,
    subject: 'Invitacion a ONBO',
    html: `<p>Tu invitacion esta lista. Crea tu cuenta aqui:</p><p><a href="${acceptUrl.toString()}">Aceptar invitacion</a></p>`,
  };

  const sendRes = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${resendApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(emailPayload),
  });

  if (!sendRes.ok) {
    return new Response(JSON.stringify({ error: 'email_send_failed' }), {
      status: 502,
      headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
    });
  }

  return new Response(
    JSON.stringify({
      invite_id: invite.invite_id,
      expires_at: invite.expires_at,
    }),
    {
      headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
    },
  );
});
