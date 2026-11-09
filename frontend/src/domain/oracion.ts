import { z } from "zod";

export const oracionSchema = z.object({
  slug: z.string(),
  titulo: z.string(),
  texto: z.string(),
});

export type Oracion = z.infer<typeof oracionSchema>;

export function parseOraciones(data: unknown): Oracion[] {
  return z.array(oracionSchema).parse(data);
}
