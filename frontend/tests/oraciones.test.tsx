import { render, screen } from "@testing-library/react";
import axe from "axe-core";
import { describe, expect, it } from "vitest";

import { OracionesLista } from "@/components/Oraciones/OracionesLista";
import { parseOraciones } from "@/domain/oracion";

const data = [{ slug: "padre-nuestro", titulo: "Padre Nuestro", texto: "Padre nuestro..." }];

async function violations(container: HTMLElement) {
  const r = await axe.run(container, { runOnly: ["wcag2a", "wcag2aa"] });
  return r.violations;
}

describe("OracionesLista", () => {
  it("muestra cada oración", () => {
    render(<OracionesLista oraciones={data} />);
    expect(screen.getByRole("heading", { name: "Padre Nuestro" })).toBeInTheDocument();
  });

  it("muestra estado vacío", () => {
    render(<OracionesLista oraciones={[]} />);
    expect(screen.getByRole("status")).toHaveTextContent("Todavía no hay oraciones");
  });

  it("no tiene violaciones WCAG A/AA", async () => {
    const { container } = render(<OracionesLista oraciones={data} />);
    expect(await violations(container)).toEqual([]);
  });

  it("rechaza datos con forma inválida", () => {
    expect(() => parseOraciones([{ slug: 1 }])).toThrow();
  });
});
