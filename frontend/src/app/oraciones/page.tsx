import { OracionesLista } from "@/components/Oraciones/OracionesLista";
import { fetchOraciones } from "@/lib/oraciones";

export const dynamic = "force-dynamic";

export default async function OracionesPage() {
  const oraciones = await fetchOraciones();
  return (
    <main className="mx-auto max-w-2xl p-6">
      <h1 className="mb-6 text-2xl font-bold">Oraciones</h1>
      <OracionesLista oraciones={oraciones} />
    </main>
  );
}
