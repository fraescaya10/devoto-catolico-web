# Guía para agentes: implementar la app desde el diseño

Esta carpeta contiene todo lo necesario para construir la app de oraciones, novenas y rosarios a partir del diseño hecho en Claude Design. Léela completa antes de escribir código.

> **Cómo enlazarla:** agrega en el `CLAUDE.md` (o `AGENTS.md`) de la raíz del repositorio la línea
> `Antes de trabajar en la interfaz o en el flujo de contenido, lee docs/design/AGENTS.md.`

---

## 1. Qué hay aquí y en qué orden leerlo

| Orden | Archivo | Para qué |
|---|---|---|
| 1 | `AGENTS.md` | Este archivo: cómo interpretar todo y reglas de implementación |
| 2 | `arquitectura.md` | Producto, flujo de publicación, permisos, modelo de datos, API y plan de tareas (E0-E9) |
| 3 | `sistema-diseno.md` | Tokens, tipografía, layout adaptable, componentes, patrones, textos e inventario de pantallas |
| 4 | `tokens.json` | Los mismos tokens en formato W3C, para generar CSS y Tailwind |
| 5 | `screens/` | Una pantalla por archivo: referencia exacta de estructura, valores, textos y comportamiento |
| 6 | `screenshots/` | Capturas de escritorio y móvil para comparar visualmente (las agrega la persona; ver su README) |

**Jerarquía cuando algo no coincide:**
1. `arquitectura.md` manda en comportamiento, permisos y datos.
2. `sistema-diseno.md` y `tokens.json` mandan en lo visual.
3. `screens/` es la referencia de cómo se ve y se comporta cada pantalla.
4. `screenshots/` solo sirve para verificar.

Si encuentras una contradicción real, no la resuelvas en silencio: señálala.

---

## 2. Cómo leer los archivos de `screens/`

Son exportaciones del lienzo de Claude Design en su formato propio. **No son código de producción y no se pueden ejecutar fuera de Claude Design**: dependen de un `support.js` que no está incluido. Léelos como especificación.

| Sintaxis en el archivo | Significado | Equivalente en React |
|---|---|---|
| `<x-dc>…</x-dc>` | Raíz del contenido de la pantalla | El JSX de la página |
| `<helmet>` | Fuentes y estilos base de la página | `layout.tsx` / `next/font` / `globals.css` |
| `{{nombre}}` | Valor calculado en `renderVals()` del script al final del archivo | Una variable o prop |
| `<sc-for list="{{items}}" as="x">` | Repetición | `items.map(x => …)` |
| `<sc-if value="{{cond}}">` | Renderizado condicional | `{cond && …}` |
| `onClick="{{accion}}"`, `onChange="{{…}}"` | Manejador definido en `renderVals()` | Handler del componente |
| `this.state` / `this.setState` en el script | Estado de la maqueta para mostrar interacciones | `useState`, o estado del servidor con TanStack Query |
| `<dc-import name="PublicHeader" current="…">` | Componente compartido | `<PublicHeader current="…" />` (ver `screens/componentes/cabecera-publica.html`) |
| `<dc-import name="PanelNav" current="…" role="…">` | Menú lateral del panel según rol | `<PanelNav current="…" role="…" />` (ver `screens/componentes/menu-panel.html`) |
| `data-props='{…}'` | Ajustes del lienzo (por ejemplo `dark`, `sesionExpirada`) | Normalmente una prop o un estado; `$preview` se ignora |
| `style="…"` en línea | Valores exactos del diseño | **Traducir a tokens y clases de Tailwind**; nunca copiar el estilo en línea |

**Contenido de ejemplo:**
- Los textos entre corchetes (`[Nombre]`, `[Usuario 4]`, `[dominio]`, `[Texto del día 3…]`) son marcadores, no texto final.
- Los datos de las tablas son ficticios: en la app vienen de la API.
- Las oraciones tradicionales (Padre Nuestro, Ave María, Gloria, San Miguel, Ángel de la Guarda, Salve) son contenido semilla aceptable.
- Los enlaces ya apuntan a las rutas reales de la app (`/oraciones/…`, `/panel/…`). `ID-PRIVADA`, `ID-PUBLICADA` e `ID` representan un identificador.

---

## 3. Reglas de implementación

1. **Stack:** Next.js (App Router) + TypeScript + Tailwind + shadcn/ui en el frontend; FastAPI + PostgreSQL en el backend (ver `arquitectura.md`).
2. **Tokens:** genera `globals.css` y `tailwind.config.ts` desde `tokens.json` (la sección 12 de `sistema-diseno.md` tiene el resultado esperado). **Ningún hexadecimal** en los componentes.
3. **Componentes:** usa los nombres de la sección 8 de `sistema-diseno.md` (`StatusBadge`, `SequenceBuilder`, `RequestPublishPanel`, etc.). Los compartidos (`PublicHeader`, `PanelNav`, `PanelLayout`) se construyen primero.
4. **Estados de contenido:** los colores y etiquetas salen de un único mapa (`statusStyles`) alimentado por `tokens.json`. El estado mostrado viene calculado del backend; la interfaz no lo deriva.
5. **Adaptable:** reproduce los patrones de la sección 5 de `sistema-diseno.md` (`flex-wrap`, `clamp()`, grillas `auto-fit`, tablas en caja con scroll). Verifica a 360, 390, 768, 1024, 1280 y 1440 px.
6. **Accesibilidad:** los requisitos de la sección 7 son obligatorios. Mantén lo que ya está en las pantallas: etiquetas, `aria-invalid`, `aria-live`, `aria-pressed`, `aria-current`, `role="alertdialog"`, objetivos táctiles de 44 px y reordenar sin arrastrar.
7. **Textos:** español con **tú**. Usa el glosario de la sección 10 de `sistema-diseno.md` ("Solicitar publicación", "Privado"; nunca "Enviar a revisión" ni "Borrador"). Copia los textos de interfaz de las pantallas tal cual.
8. **Interfaz pública:** se renderiza en el servidor (SSR/ISR) para SEO. El panel es renderizado en el cliente.
9. **Nada sin aprobar se expone:** ninguna pantalla pública debe poder mostrar una versión que no esté aprobada (ver `arquitectura.md`, sección 5).
10. **Principios de código:** SOLID, KISS, DRY y YAGNI. No construyas pantallas ni abstracciones que no estén en el plan de la fase actual.

### Correcciones obligatorias respecto al lienzo

| Elemento | En las pantallas | Usar |
|---|---|---|
| Texto de ejemplo (placeholder) | `#857B70` | token `placeholder` (`#776D62`) |
| Borde de campos y controles | `#D6CBB8` | token `border-input` (`#948977`) |

Los valores del lienzo no cumplen WCAG AA; `tokens.json` ya trae los corregidos.

---

## 4. Mapa de pantallas

| Archivo | Ruta | Rol | Componentes clave | Interacciones que muestra | Tarea |
|---|---|---|---|---|---|
| `screens/publico/inicio.html` | `/` | público | `PublicHeader`, `SearchForm`, `ContinueCard` | Navegación | E7-T1 |
| `screens/publico/oraciones.html` | `/oraciones` | público | `SearchForm`, `FilterChips`, `ResultCard`, `EmptyState` | Filtros por tipo, estado vacío | E7-T2 |
| `screens/publico/lectura.html` | `/oraciones/[slug]`, `/c/[token]` | público | `PrayerReader`, `ReadingControls`, `ReportLink` | Tamaño de letra, modo oscuro | E7-T3, E7-T7 |
| `screens/publico/novenas.html` | `/novenas` | público | `ContinueCard`, tarjetas | — | E7-T4 |
| `screens/publico/novena.html` | `/novenas/[slug]` | público | `NovenaDayPicker` | Elegir día, marcar rezado | E7-T6 |
| `screens/publico/rosarios.html` | `/rosarios` | público | Tarjeta "Hoy", tarjetas | — | E7-T4 |
| `screens/publico/rosario.html` | `/rosarios/[slug]` | público | `SequenceStepper`, `BeadProgress` | Anterior/siguiente, modo oscuro | E7-T5 |
| `screens/cuenta/registro.html` | `/registro` | público | Formulario, captcha | Validación, "Revisa tu correo" | E8-T1 |
| `screens/cuenta/ingresar.html` | `/ingresar` | público | `PasswordField` | Mostrar contraseña, sesión expirada (`sesionExpirada`) | E8-T1, E8-T2 |
| `screens/cuenta/recuperar.html` | `/recuperar` | público | Formulario | Respuesta neutra | E8-T1 |
| `screens/panel/inicio.html` | `/panel` | usuario | `PanelNav`, `EmptyState` | Reenviar verificación | E8-T3 |
| `screens/panel/oraciones.html` | `/panel/oraciones` | usuario | `RequestLimit`, `FilterChips`, `StatusBadge` | — | E8-T4 |
| `screens/panel/oracion-editar.html` | `/panel/oraciones/[id]` (privada) | usuario | `PublishFlow`, `RequestPublishPanel`, `DuplicateWarning`, `VisibilityChoice` | Validación de fuente, duplicado con dos caminos, envío | E8-T5, E8-T8 |
| `screens/panel/oracion-publicada.html` | `/panel/oraciones/[id]` (publicada) | usuario | `SharePanel`, `VersionList`, `InlineConfirm` | Visibilidad, copiar y regenerar enlace, archivar y restaurar | E8-T9 |
| `screens/panel/secuencias.html` | `/panel/secuencias` | usuario | `Table`, `StatusBadge` | — | E8-T4 |
| `screens/panel/secuencia-editar.html` | `/panel/secuencias/[id]` | usuario | `SequenceBuilder` | Subir/bajar, repeticiones, quitar, agregar, anuncios | E8-T6 |
| `screens/panel/novenas.html` | `/panel/novenas` | usuario | `Table`, barra de días | — | E8-T4 |
| `screens/panel/novena-editar.html` | `/panel/novenas/[id]` | usuario | `NovenaStructureEditor`, `RequirementsChecklist` | Requisitos en vivo, botón habilitado al completar | E8-T7 |
| `screens/panel/revision.html` | `/panel/revision` | revisor, admin | `ReviewQueue`, `DiffView`, `RejectForm`, `ReportsSummary` | Aprobar, rechazar con motivo obligatorio | E8-T10 |
| `screens/panel/usuarios.html` | `/panel/usuarios` | admin | `UserTable`, `ModerationSettings` | — | E8-T11 |
| `screens/componentes/cabecera-publica.html` | — | — | `PublicHeader` (`current`, `dark`) | — | E7-T1 |
| `screens/componentes/menu-panel.html` | — | — | `PanelNav` (`current`, `role`) | Menú según rol | E8-T2 |
| `screens/fundamentos.html` | `/dev/ui` (interna) | — | Paleta, tipografía, botones, insignias, campos | — | — |

---

## 5. Orden de construcción sugerido

1. **Fase 0** de `arquitectura.md`: entorno, CI y esqueletos.
2. **Fundaciones de UI:** tokens → `globals.css` y Tailwind, fuentes con `next/font`, componentes base (8.1), `/dev/ui` comparada contra `screens/fundamentos.html`.
3. **Layouts:** `PublicHeader`, `PanelNav` y `PanelLayout`.
4. **Backend del MVP** (E1-E6) en el orden del plan; cada pantalla se conecta cuando su API exista.
5. **Área pública** (E7), empezando por búsqueda y lectura.
6. **Cuenta y panel** (E8): cuenta → inicio → listados → editores → solicitar → publicado → revisión → usuarios.
7. **Calidad** (E9): E2E de los flujos críticos y revisión de accesibilidad.

Cada pantalla termina cuando:
- coincide con su archivo de `screens/` y con su captura;
- funciona en los anchos de verificación;
- cumple la definición de "hecho" de `arquitectura.md`.

---

## 6. Lo que no está diseñado (no lo inventes)

Estas pantallas faltan. Si una tarea las necesita, **pregunta antes** o implementa una versión mínima con los componentes existentes y avisa:

1. Fin del rosario (cierre y "siguiente misterio").
2. 404 y "ya no disponible" (contenido archivado o enlace regenerado).
3. "Sin permiso" (403).
4. Términos de uso y política de privacidad (el texto legal lo provee la persona).
5. Estados de carga (skeletons) y de error con reintento.
6. Búsqueda sin resultados para un texto.

**Decisiones abiertas** (no las tomes tú): nombre y logotipo (hoy `[Nombre]`), paleta final de marca, uso de imágenes de santos y la traducción bíblica de la Fase 3.
