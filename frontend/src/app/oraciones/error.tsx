"use client";

export default function ErrorState({ reset }: { error: Error; reset: () => void }) {
  return (
    <main className="mx-auto max-w-2xl p-6">
      <p role="alert">No pudimos cargar las oraciones.</p>
      <button type="button" onClick={reset} className="mt-4 rounded border px-3 py-1">
        Reintentar
      </button>
    </main>
  );
}
