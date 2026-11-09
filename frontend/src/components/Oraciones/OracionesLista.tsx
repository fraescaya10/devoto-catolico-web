import type { Oracion } from "@/domain/oracion";

export function OracionesLista({ oraciones }: { oraciones: Oracion[] }) {
  if (oraciones.length === 0) {
    return <p role="status">Todavía no hay oraciones publicadas.</p>;
  }
  return (
    <ul className="space-y-4">
      {oraciones.map((o) => (
        <li key={o.slug}>
          <h2 className="text-lg font-semibold">{o.titulo}</h2>
          <p className="text-zinc-700">{o.texto}</p>
        </li>
      ))}
    </ul>
  );
}
