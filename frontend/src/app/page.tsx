import Link from "next/link";

export default function Home() {
  return (
    <main className="mx-auto max-w-2xl p-6">
      <h1 className="text-2xl font-bold">Devoto Católico</h1>
      <Link href="/oraciones" className="mt-4 inline-block underline">
        Ver oraciones
      </Link>
    </main>
  );
}
