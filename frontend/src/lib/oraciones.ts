import { parseOraciones, type Oracion } from "@/domain/oracion";

const API_URL = process.env.API_URL ?? "http://127.0.0.1:8000";

export async function fetchOraciones(): Promise<Oracion[]> {
  const res = await fetch(`${API_URL}/api/v1/public/oraciones`, { next: { revalidate: 60 } });
  if (!res.ok) throw new Error(`API respondió ${res.status}`);
  return parseOraciones(await res.json());
}
