export default function AccountDisabledPage() {
  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center gap-6 p-6">
      <h1 className="text-2xl font-semibold">Cuenta deshabilitada</h1>
      <p className="text-muted-foreground text-sm">
        Tu cuenta fue archivada. Contacta a tu admin para reactivarla.
      </p>
      <a
        className="rounded bg-black px-4 py-2 text-center text-white"
        href="mailto:admin@onbo.io"
      >
        Contactar admin
      </a>
    </div>
  );
}
