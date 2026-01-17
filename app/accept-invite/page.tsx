'use client';

import { useRouter, useSearchParams } from 'next/navigation';
import { useMemo, useState } from 'react';
import { createBrowserClient } from '@supabase/ssr';

const supabase = createBrowserClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL ?? '',
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? '',
);

const errorMessages: Record<string, string> = {
  invite_invalid: 'La invitacion no es valida.',
  invite_expired: 'La invitacion expiro. Pedile a tu admin que cree una nueva.',
  invite_used: 'La invitacion ya fue usada.',
  invite_revoked: 'La invitacion fue revocada.',
  email_mismatch: 'El email no coincide con la invitacion.',
  weak_password: 'La contrasena es demasiado debil.',
  auth_required: 'Necesitas iniciar sesion para aceptar la invitacion.',
};

export default function AcceptInvitePage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = useMemo(() => searchParams.get('token') ?? '', [searchParams]);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'error'>('idle');
  const [message, setMessage] = useState('');

  const onSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setStatus('loading');
    setMessage('');

    const signUpResult = await supabase.auth.signUp({ email, password });
    if (signUpResult.error) {
      const lowerMessage = signUpResult.error.message.toLowerCase();
      if (
        lowerMessage.includes('already') ||
        lowerMessage.includes('registered')
      ) {
        const signInResult = await supabase.auth.signInWithPassword({
          email,
          password,
        });
        if (signInResult.error) {
          setStatus('error');
          setMessage(signInResult.error.message);
          return;
        }
      } else {
        setStatus('error');
        setMessage(signUpResult.error.message);
        return;
      }
    }

    const { error } = await supabase.rpc('accept_invite', {
      token_plain: token,
    });
    if (error) {
      setStatus('error');
      setMessage(errorMessages[error.message] ?? error.message);
      return;
    }

    router.push('/');
  };

  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center gap-6 p-6">
      <h1 className="text-2xl font-semibold">Aceptar invitacion</h1>
      <form className="flex flex-col gap-4" onSubmit={onSubmit}>
        <label className="flex flex-col gap-2 text-sm">
          Email
          <input
            type="email"
            required
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            className="rounded border px-3 py-2"
          />
        </label>
        <label className="flex flex-col gap-2 text-sm">
          Contrasena
          <input
            type="password"
            required
            minLength={8}
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            className="rounded border px-3 py-2"
          />
        </label>
        <button
          type="submit"
          className="rounded bg-black px-4 py-2 text-white"
          disabled={!token || status === 'loading'}
        >
          {status === 'loading'
            ? 'Procesando...'
            : 'Crear cuenta y aceptar invitacion'}
        </button>
      </form>
      {message ? <p className="text-sm text-red-600">{message}</p> : null}
    </div>
  );
}
