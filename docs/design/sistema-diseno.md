# Sistema de diseño — App de oraciones, novenas y rosarios

Versión: 2.0 · Estado: alineado con el diseño en Claude Design ("Diseño app de oraciones")
Documento relacionado: `arquitectura.md` (v2.0)

**Qué cambia respecto a la v1:**
- Los valores salen de lo que efectivamente se diseñó en el lienzo, no de una propuesta.
- El área pública es una web adaptable.
- El panel sigue el flujo privado → solicitud → revisión → compartir.
- Se suman los componentes, patrones y pantallas que existen hoy, con los contrastes medidos y las correcciones necesarias.

---

## Índice

1. Principios
2. Tokens de color
3. Tipografía
4. Espaciado, tamaños, radios y elevación
5. Layout y comportamiento adaptable
6. Iconografía y movimiento
7. Accesibilidad
8. Componentes
9. Patrones
10. Voz y textos de interfaz
11. Inventario de pantallas
12. Implementación técnica
13. Pendientes y decisiones abiertas

---

## 1. Principios

| Principio | Qué implica en el diseño |
|---|---|
| **La lectura es el producto** | Serif de lectura grande (18-28 px), interlineado 1,8, máximo 65 caracteres por línea. Nada compite con el texto de una oración |
| **Recogimiento, no decoración** | Paleta cálida y sobria, sin ilustraciones religiosas, degradados ni sombras marcadas. La identidad la dan la tipografía y el burdeos |
| **Accesible para todas las edades** | Objetivos táctiles de 44 px o más, tamaño de letra ajustable, modo oscuro real y estados que nunca dependen solo del color |
| **Web adaptable** | Un mismo diseño fluido de 360 a 1440 px; nada de versiones separadas para móvil y escritorio |
| **Público contemplativo, panel productivo** | Mismos tokens; el área pública respira más, el panel es más denso y usa tablas |
| **Lo que no está aprobado no se ve** | La interfaz siempre deja claro el estado de cada contenido y quién puede verlo |

---

## 2. Tokens de color

El código usa siempre el nombre del token, nunca el hexadecimal. Los contrastes están medidos con la fórmula WCAG 2.1.

### 2.1 Modo claro

| Token | Valor | Uso | Contraste |
|---|---|---|---|
| `--bg` | `#FAF7F2` | Fondo de página (papel cálido) | — |
| `--surface` | `#FFFFFF` | Tarjetas, formularios, tablas | — |
| `--surface-muted` | `#F2EDE4` | Ítem de menú activo, bloques de apoyo, tarjetas "continuar" | — |
| `--text` | `#2B2622` | Texto principal | 14,0:1 sobre `--bg` |
| `--text-muted` | `#6B6258` | Texto secundario, ayudas, metadatos | 5,6:1 sobre `--bg`; 5,1:1 sobre `--surface-muted` |
| `--placeholder` | `#776D62` | Texto de ejemplo en campos | 4,7:1 sobre `--bg` *(corregido, ver 2.5)* |
| `--border` | `#E3DACB` | Bordes de tarjetas y separadores (decorativos) | — |
| `--border-input` | `#948977` | Borde de campos y controles | 3,4:1 sobre `--surface` *(corregido, ver 2.5)* |
| `--divider` | `#EFE8DC` | Separadores de filas de tabla | — |
| `--primary` | `#7A2E3A` | Acción principal, enlaces, marca (burdeos) | 8,6:1 sobre `--bg` |
| `--primary-hover` | `#63232E` | Hover y presionado | — |
| `--on-primary` | `#FFFFFF` | Texto sobre primario | 9,2:1 |
| `--primary-tint` | `#F4E4E7` | Halo del paso actual, insignia de admin | — |
| `--accent` | `#B08A3E` | Solo decorativo (dorado apagado) | 3,0:1: **no usar para texto** |
| `--accent-text` | `#7A5A1E` | Variante del acento para texto (rosario en claro) | 5,9:1 |
| `--focus` | `#1F5FBF` | Anillo de foco, icono informativo | 5,7:1 |

### 2.2 Modo oscuro

Se usa en el lector y en el rosario, pensado para rezar de noche. No se usa negro ni blanco puros.

| Token | Valor | Contraste |
|---|---|---|
| `--bg` | `#171412` | — |
| `--surface` | `#211C19` | — |
| `--surface-muted` | `#2A2420` | — |
| `--text` | `#EDE6DB` | 14,8:1 |
| `--text-muted` | `#A89E91` | 7,0:1 |
| `--border` | `#3A322C` | — |
| `--border-input` | `#7A6F63` | 3,4:1 sobre `--surface` |
| `--primary` | `#D9919B` | 7,4:1 |
| `--on-primary` | `#2B1216` | 7,1:1 sobre primario |
| `--accent` | `#D2AE66` | 8,7:1 (en oscuro sí sirve como texto) |
| `--focus` | `#7FB0FF` | 8,3:1 |
| `--bead-idle` | `#4A4039` | Cuentas del rosario sin rezar (decorativo) |

### 2.3 Estados de contenido

Siempre se muestran como insignia con punto + texto. El punto refuerza; el texto es el que comunica.

| Estado | Fondo | Texto | Punto | Contraste |
|---|---|---|---|---|
| Privado | `#EFEAE2` | `#4A443E` | `#6B6258` | 8,0:1 |
| En revisión | `#FBEFD9` | `#6B4104` | `#A8680A` | 7,7:1 |
| Publicado | `#E3F0E5` | `#24532F` | `#2F6B3F` | 7,6:1 |
| Publicado · cambios en revisión | `#E3F0E5` | `#24532F` | `#A8680A` | 7,6:1 |
| Rechazado | `#FCEBEA` | `#8C1D16` | `#B3261E` | 7,9:1 |
| Archivado | `#E6E9EC` | `#3E454C` | `#59616B` | 8,0:1 |

### 2.4 Roles y retroalimentación

| Token / uso | Fondo | Texto / borde | Contraste |
|---|---|---|---|
| Rol Administrador | `#F4E4E7` | `#63232E` | 9,4:1 |
| Rol Revisor | `#FBEFD9` | `#6B4104` | 7,7:1 |
| Rol Usuario | `#EFEAE2` | `#4A443E` | 8,0:1 |
| Aviso (límites, duplicados, correo sin verificar) | `#FBEFD9` | texto `#5E3904`, borde `#EBCF9A` | 8,9:1 |
| Error (resumen de formulario) | `#FCEBEA` | texto `#8C1D16`, borde `#F0B9B5` | 7,9:1 |
| Error de campo | `#FFFFFF` | borde 2 px y mensaje `#B3261E` | 6,5:1 |
| Éxito | `#E3F0E5` | `#24532F` | 7,6:1 |
| Botón aprobar | `#2F6B3F` | `#FFFFFF` | 6,4:1 |
| Botón peligro (archivar) | `#B3261E` | `#FFFFFF` | 6,5:1 |
| Diferencias: agregado (`<ins>`) | `#DDEFE1` | `#1E4A28`, subrayado | 8,5:1 |
| Diferencias: eliminado (`<del>`) | `#F9DEDC` | `#7A1A14`, tachado | 8,3:1 |

### 2.5 Correcciones respecto al lienzo

Al medir, dos valores del diseño actual no cumplen WCAG AA. Hay que corregirlos al implementar, y conviene actualizarlos también en el lienzo:

| Elemento | En el lienzo | Contraste | Corrección | Contraste corregido |
|---|---|---|---|---|
| Texto de ejemplo en campos | `#857B70` | 4,2:1 | `#776D62` | 4,7:1 sobre `--bg`, 5,1:1 sobre `--surface` |
| Borde de campos y controles | `#D6CBB8` | 1,6:1 (WCAG 1.4.11 pide 3:1) | `#948977` | 3,4:1 sobre `--surface` |

Los bordes de tarjetas (`#E3DACB`) pueden seguir claros, porque son decorativos y no delimitan un control.

---

## 3. Tipografía

| Rol | Fuente | Pesos | Uso |
|---|---|---|---|
| Lectura y títulos | **Source Serif 4** | 400, 600 | Textos de oraciones, títulos de página y de tarjetas |
| Interfaz | **Inter** | 400, 600 | Navegación, botones, formularios, tablas, metadatos |

Se cargan con `next/font` (autoalojadas, subconjunto latino, `display: swap`). El lienzo usa Google Fonts solo para el prototipo.

### 3.1 Escala

| Token | Tamaño | Interlineado | Fuente | Uso |
|---|---|---|---|---|
| `display` | `clamp(32px, 5vw, 52px)` | 1,15 | Serif 600 | Titular de inicio |
| `h1-public` | `clamp(30px, 4vw, 40px)` | 1,2 | Serif 600 | Título de página pública |
| `h1-panel` | 30 px | 1,2 | Serif 600 | Título de página del panel |
| `h2` | 22-26 px | 1,25 | Serif 600 | Secciones, tarjetas destacadas |
| `h3` | 17-21 px | 1,25 | Serif 600 / Inter 600 | Títulos de tarjeta (serif) o de bloque de panel (Inter) |
| `body` | 16 px | 1,6 | Inter 400 | Texto de interfaz |
| `body-sm` | 15 px | 1,5 | Inter 400 | Tablas, listas del panel, botones |
| `caption` | 13-14 px | 1,5 | Inter 400 | Ayudas, metadatos, mensajes de error |
| `overline` | 12-13 px, mayúsculas, espaciado 0,04em | 1,4 | Inter 600 | Tipo de contenido, "Día 3 de 9", "En curso" |
| `reading` | 18 / 21 / 24 / 28 px | 1,8 | Serif 400 | Cuerpo de oraciones (4 tamaños elegibles) |

**Reglas**
- Mínimo 12 px y solo para `overline`; el texto que se lee nunca baja de 13 px.
- Ancho máximo de lectura: `65ch`.
- El tamaño de lectura elegido se guarda en `localStorage` (preferencia local, sin cuenta).

---

## 4. Espaciado, tamaños, radios y elevación

### 4.1 Espaciado
Base de 4 px. Escala usada: `4, 6, 8, 10, 12, 16, 20, 24, 28, 32, 48, 64`.

- Entre secciones de página: 24-48 px.
- Dentro de tarjetas: 16-28 px (`clamp(20px, 3vw, 28px)`).
- Entre campo y etiqueta: 6 px; entre campos: 16-20 px.

### 4.2 Alturas de controles

| Control | Alto |
|---|---|
| Botón y campo estándar, chip de filtro, ítem de menú | 44 px (mínimo táctil) |
| Botón principal de formulario o diálogo | 48 px |
| Botón de acción principal pública (buscar, crear cuenta, ingresar) | 52-56 px |
| Navegación del rosario (Anterior / Siguiente) | 56 px |
| Botones compactos dentro de listas (− / + de repeticiones, "Agregar") | 36 px, con 44 px de área por fila |

### 4.3 Radios

| Token | Valor | Uso |
|---|---|---|
| `radius-sm` | 6 px | Campos de texto, selects |
| `radius-md` | 8 px | Ítems de menú, botones compactos |
| `radius-lg` | 10 px | Botones, avisos, tarjetas pequeñas |
| `radius-xl` | 12 px | Tarjetas y paneles |
| `radius-full` | 999 px | Chips de filtro, insignias |

### 4.4 Elevación
Sin sombras en el MVP: la separación se logra con bordes de 1 px y el contraste entre `--bg` y `--surface`. Una sombra suave solo si en el futuro aparecen menús flotantes.

---

## 5. Layout y comportamiento adaptable

El sistema es fluido y casi no necesita media queries: usa `flex-wrap`, `clamp()` y grillas `auto-fit`.

### 5.1 Contenedores

| Contexto | Ancho máximo | Relleno lateral |
|---|---|---|
| Páginas públicas | 1120 px | `clamp(16px, 4vw, 40px)` |
| Lectura, rosario | 720 px | `clamp(16px, 4vw, 24px)` |
| Cuenta (ingresar, registro, recuperar) | 440-480 px | 16 px |
| Panel (contenido) | fluido | `clamp(16px, 3vw, 40px)` |

### 5.2 Patrones adaptables

| Patrón | Implementación | En móvil |
|---|---|---|
| Cabecera pública | Fila con `flex-wrap`: marca, menú, Buscar, Ingresar | El menú baja a una segunda línea |
| Panel con menú lateral | Fila `flex-wrap`: menú `flex: 1 1 248px`, contenido `flex: 999 1 560px; min-width: 0` | El menú queda arriba, a lo ancho; nunca `position: sticky` ni `100vh` |
| Grillas de tarjetas | `repeat(auto-fit, minmax(min(100%, 240-320px), 1fr))` | Una columna |
| Dos columnas (editor + barra lateral, novena) | `flex-wrap` con `flex: 999 1 460px` / `flex: 1 1 280px` | La barra lateral pasa debajo |
| Tablas | Dentro de una caja con `overflow-x: auto` y `min-width` de 760-860 px | Se desplazan horizontalmente dentro de su caja, la página no |
| Barras de acciones | `flex-wrap` | Los botones se apilan |

**Puntos de verificación:** 360, 390, 768, 1024, 1280 y 1440 px.

---

## 6. Iconografía y movimiento

- **Iconos:** trazo de 1,5 px, extremos redondeados, 18-24 px (en código, Lucide). Solo funcionales: buscar, volver, cerrar, editar, subir/bajar, menú, tema, más acciones.
- **Iconos decorativos** con `aria-hidden="true"`; **botones solo con icono** con `aria-label` descriptivo ("Subir Ave María", "Más acciones para Salve").
- **Sin iconografía religiosa** decorativa en la interfaz.
- **Movimiento:** transiciones de 150-200 ms, solo `opacity` y `transform`; respetar `prefers-reduced-motion`. Sin carruseles ni animaciones de entrada.

---

## 7. Accesibilidad

Requisitos del MVP (no deseables):

| Requisito | Cómo se cumple en el diseño |
|---|---|
| Contraste AA | Tokens medidos (sección 2), con las dos correcciones de 2.5 |
| Objetivos táctiles ≥ 44 px | Botones, chips, enlaces de lista y menú |
| Foco visible | Anillo de 2-3 px con `--focus` y separación de 2 px |
| Nunca solo color | Estados con texto; diferencias con `<ins>`/`<del>` y leyenda; días rezados con tachado y etiqueta "rezado" |
| Semántica | Un `h1` por página, `nav` con `aria-label`, `aria-current="page"`, listas reales para secuencias y versiones, tablas con `th scope` |
| Formularios | `label` asociado, ayuda con `aria-describedby`, `aria-invalid` en error, resumen con `role="alert"`, el error se limpia al editar |
| Anuncios | `aria-live="polite"` en progreso del rosario, reordenamiento de secuencias, "enlace copiado" y conteo de resultados |
| Sin arrastrar obligatorio | Reordenar con botones subir/bajar; arrastrar es una mejora opcional |
| Confirmaciones | `role="alertdialog"` en acciones destructivas o irreversibles |
| Zoom | Texto ampliable al 200 % sin pérdida; tamaño de lectura propio |
| Modo oscuro | Real (tokens propios), activable en lector y rosario; respeta `prefers-color-scheme` |

Meta: Lighthouse accesibilidad ≥ 95 y revisión manual con lector de pantalla en los flujos críticos (buscar y rezar; registrarse, crear y solicitar; revisar).

---

## 8. Componentes

Base: shadcn/ui (Radix) sobre Tailwind, personalizado con los tokens. Los nombres de esta tabla son los que se usan en código.

### 8.1 Base

| Componente | Variantes | Notas |
|---|---|---|
| `Button` | `primary`, `secondary` (borde), `ghost` (texto primario), `danger`, `approve`, `dark` (confirmaciones) | Tamaños 44 / 48 / 52-56 px; estado `disabled` con opacidad 0,45 y cursor normal |
| `LinkButton` | Igual que `Button` | Para navegar: es un `<a>`, nunca un botón que redirige |
| `IconButton` | 36 / 44 px | `aria-label` obligatorio |
| `TextField`, `TextArea`, `Select` | normal, error, solo lectura | Incluyen etiqueta, ayuda y error |
| `PasswordField` | Con botón Mostrar/Ocultar (`aria-pressed`) | |
| `Checkbox`, `RadioGroup` | | Dentro de `fieldset` + `legend`; filas de 44 px |
| `FilterChips` | Píldoras con conteo ("Privadas · 1") | Botones con `aria-pressed` |
| `Badge` | `status`, `role`, `count` | Punto + texto |
| `Alert` | `info`, `warning`, `error`, `success` | `role="status"` o `role="alert"` según el caso |
| `Card` | `default`, `muted`, `highlight` (burdeos) | Enlace completo cuando toda la tarjeta navega |
| `Table` | | Dentro de `ScrollBox`; filas con acción "Más acciones" |
| `Breadcrumb` | | `nav aria-label="Ruta"` |
| `ProgressSegments` | Segmentos de límite ("2 de 3 solicitudes") | `role="img"` con etiqueta |
| `InlineConfirm` | | Confirmación dentro del flujo (`role="alertdialog"`), sin modal flotante |
| `EmptyState` | | Título, explicación, acciones |
| `Skeleton` | | *Pendiente de diseñar* |

### 8.2 Compartidos de layout

| Componente | Props | Uso |
|---|---|---|
| `PublicHeader` | `current` (inicio, oraciones, novenas, rosarios, ninguno), `dark` | Todas las páginas públicas y de cuenta |
| `PanelNav` | `current`, `role` (usuario, revisor, admin) | Grupo "Mi espacio" siempre; "Moderación" para revisor y admin; "Usuarios" solo admin |
| `PanelLayout` | — | Menú lateral + contenido con el patrón de 5.2 |

### 8.3 Área pública

| Componente | Descripción |
|---|---|
| `SearchForm` | Campo grande con etiqueta visible y botón "Buscar" |
| `ResultCard` | Tipo (overline), título serif y extracto |
| `ContinueCard` | "Continúa donde quedaste": progreso local de una novena |
| `PrayerReader` | Ruta, metadatos (fuente, autor, "Revisado"), controles de lectura, texto y "Ver también" |
| `ReadingControls` | A− / A+ con texto, modo oscuro (`aria-pressed`) |
| `SequenceStepper` | Cuentas de progreso, "Paso 3 de 12", título, texto y navegación Anterior/Siguiente |
| `BeadProgress` | Cuentas grandes (Padre Nuestro, Gloria) y pequeñas; actual con halo dorado |
| `NovenaDayPicker` | Grilla de 5 columnas con 9 días; seleccionado, rezado (tachado) y pendiente |
| `ReportLink` | "Reportar un problema con este contenido" |

### 8.4 Panel

| Componente | Descripción |
|---|---|
| `StatusBadge` | Estados de 2.3 |
| `RequestLimit` | Segmentos y texto "Tienes 2 de 3 solicitudes en revisión" |
| `PublishFlow` | Pasos Privado → En revisión → Publicado con el actual resaltado |
| `HistoryList` | Eventos del contenido |
| `RequestPublishPanel` | Límite, aviso de duplicado con dos opciones, explicación, visibilidad y confirmación de derechos |
| `DuplicateWarning` | Contenido parecido, porcentaje y enlace "Verla" |
| `VisibilityChoice` | "En el buscador" / "Solo con enlace" |
| `SharePanel` | Visibilidad, enlace con Copiar, Regenerar con confirmación |
| `VersionList` | Versión en revisión y versión publicada |
| `SequenceBuilder` | Lista ordenada con repeticiones (− × N +), subir, bajar y quitar, y buscador para agregar |
| `NovenaStructureEditor` | Apertura, 9 días y cierre con selects y requisitos en vivo |
| `RequirementsChecklist` | ✓ / ! con texto ("Días · 6 de 9 (faltan 7, 8, 9)") |
| `ReviewQueue` | Lista priorizada con tipo, autor y estado resuelto |
| `DiffView` | Texto con `<ins>`/`<del>` y leyenda |
| `RejectForm` | Motivo obligatorio + comentario opcional |
| `ReportsSummary` | Reportes abiertos con acceso a revisarlos |
| `UserTable` | Rol, estado, aprobadas/rechazadas, registro |
| `ModerationSettings` | Límites y umbrales editables |

---

## 9. Patrones

### 9.1 Formularios y validación
1. Validar al enviar, no mientras se escribe.
2. Si hay errores: resumen arriba (`role="alert"`, "Revisa los campos marcados") + borde de 2 px y mensaje bajo cada campo.
3. El error de un campo se limpia en cuanto se edita.
4. La ayuda en reposo explica para qué sirve el campo; en error dice qué hacer.

### 9.2 Flujo de publicación (el patrón central)
- **Estado visible siempre:** insignia junto al título y en listados.
- **Solicitar:** primero exige campos y fuente; luego abre `RequestPublishPanel` dentro de la página (borde primario de 2 px), no un modal flotante.
- **Duplicado:** la opción recomendada es usar lo publicado; insistir pide una explicación.
- **Publicado con cambios:** aviso fijo "El público ve la versión 1…".
- **Compartir:** la visibilidad se puede cambiar sin nueva revisión; regenerar el enlace pide confirmación.

### 9.3 Confirmaciones
- Solo para lo destructivo o lo que rompe algo ya compartido: archivar, regenerar enlace, rechazar.
- Se resuelven en línea (`InlineConfirm`) con el verbo de la acción en el botón ("Archivar", "Generar nuevo"), nunca "Aceptar".
- Lo que se puede deshacer no pide confirmación (restaurar, cambiar la visibilidad).

### 9.4 Estados de pantalla
Todo listado define: con datos, vacío (con acción sugerida), sin resultados de búsqueda, cargando y error con reintento. Hoy están diseñados el vacío (dashboard, filtros sin contenido) y los de datos; faltan cargando y error (ver 13).

### 9.5 Progreso y límites
- **Rosario:** cuentas + texto "Paso n de N" con `aria-live`.
- **Novena:** días rezados guardados en el dispositivo; el texto "3 de 9 días rezados" acompaña siempre a la grilla.
- **Límites:** segmentos + texto; el texto nunca se omite.

### 9.6 Navegación por rol
El usuario solo ve "Mi espacio". El revisor suma "Moderación" con la cola y su conteo; el admin además "Usuarios". Una ruta sin permiso muestra la pantalla "sin permiso" (pendiente), nunca un error genérico.

### 9.7 Moderación
- La cola se ordena por prioridad: cambios a lo publicado, secuencias con contenido aprobado, contenido nuevo, posibles duplicados.
- Cada solicitud muestra su tipo con color y texto, el autor, la antigüedad y la fuente.
- Las ediciones se revisan siempre como diferencias, no como texto completo.
- Rechazar exige un motivo, que el autor verá.

---

## 10. Voz y textos de interfaz

**Tono:** cercano, respetuoso y claro. Se usa **tú** en toda la interfaz (decisión tomada en el diseño; confirmar antes del desarrollo).

**Reglas**
- Botones con verbo y objeto cuando hace falta: "Solicitar publicación", "Usar la publicada", "Generar nuevo".
- Los errores dicen qué pasó y qué hacer: "Indica de dónde viene el texto para poder publicarlo".
- Los textos de oraciones se muestran exactamente como se aprobaron; la interfaz nunca los resume ni los corrige.
- No usar jerga técnica con el usuario: "enlace", no "token"; "versión", no "revisión 2".
- Los mensajes de cuenta no revelan si un correo existe.

**Glosario**

| Usar | Evitar | Notas |
|---|---|---|
| Privado | Borrador | Estado de algo no publicado |
| Solicitar publicación | Enviar a revisión, Publicar | El usuario no publica: solicita |
| En revisión | Pendiente | |
| Publicado | Aprobado | "Aprobar" es la acción del revisor |
| Rechazado (con motivo) | Denegado | |
| Archivar / Restaurar | Eliminar | Archivar es reversible |
| En el buscador / Solo con enlace | Público / No listado | |
| Fuente | Referencia, cita | |
| Cola de revisión | Pendientes de moderación | |
| Rezado (día de novena) | Completado | |

---

## 11. Inventario de pantallas

Diseñadas en el lienzo "Diseño app de oraciones" (Claude Design). Las tareas corresponden al plan de la arquitectura v2.0.

### 11.1 Área pública

| Artboard | Ruta | Componentes principales | Tarea |
|---|---|---|---|
| Inicio | `/` | `PublicHeader`, `SearchForm`, `ContinueCard`, tarjetas de secciones | E7-T1 |
| Oraciones · búsqueda | `/oraciones` | `SearchForm`, `FilterChips`, `ResultCard`, `EmptyState` | E7-T2 |
| Lectura de oración | `/oraciones/[slug]` y `/c/[token]` | `PrayerReader`, `ReadingControls`, `ReportLink` | E7-T3, E7-T7 |
| Novenas | `/novenas` | `ContinueCard`, tarjetas | E7-T4 |
| Novena por día | `/novenas/[slug]` | `NovenaDayPicker`, apertura y cierre | E7-T6 |
| Rosarios y coronillas | `/rosarios` | Tarjeta destacada "Hoy", tarjetas | E7-T4 |
| Rosario paso a paso | `/rosarios/[slug]` | `SequenceStepper`, `BeadProgress` | E7-T5 |

### 11.2 Cuenta

| Artboard | Ruta | Notas | Tarea |
|---|---|---|---|
| Crear cuenta | `/registro` | Validación, términos, captcha, estado "Revisa tu correo" | E8-T1 |
| Ingresar | `/ingresar` | Variante "sesión expirada" | E8-T1, E8-T2 |
| Recuperar contraseña | `/recuperar` | Respuesta neutra | E8-T1 |

### 11.3 Panel

| Artboard | Ruta | Rol | Tarea |
|---|---|---|---|
| Inicio (primer ingreso) | `/panel` | usuario | E8-T3 |
| Mis oraciones | `/panel/oraciones` | usuario | E8-T4 |
| Editar y solicitar publicación | `/panel/oraciones/[id]` | usuario | E8-T5, E8-T8 |
| Publicado: compartir y versiones | `/panel/oraciones/[id]` (publicado) | usuario | E8-T9 |
| Mis secuencias | `/panel/secuencias` | usuario | E8-T4 |
| Constructor de secuencias | `/panel/secuencias/[id]` | usuario | E8-T6 |
| Mis novenas | `/panel/novenas` | usuario | E8-T4 |
| Editor de novena | `/panel/novenas/[id]` | usuario | E8-T7 |
| Cola de revisión | `/panel/revision` | revisor, admin | E8-T10 |
| Usuarios | `/panel/usuarios` | admin | E8-T11 |

### 11.4 Fundamentos y componentes
`Fundamentos del sistema` (paleta, tipografía, botones, insignias, campos), `Componente · Cabecera pública` y `Componente · Menú del panel`.

---

## 12. Implementación técnica

### 12.1 Tokens como variables CSS

```css
/* app/globals.css */
:root {
  --bg: #FAF7F2;
  --surface: #FFFFFF;
  --surface-muted: #F2EDE4;
  --text: #2B2622;
  --text-muted: #6B6258;
  --placeholder: #776D62;
  --border: #E3DACB;
  --border-input: #948977;
  --divider: #EFE8DC;
  --primary: #7A2E3A;
  --primary-hover: #63232E;
  --on-primary: #FFFFFF;
  --primary-tint: #F4E4E7;
  --accent: #B08A3E;
  --accent-text: #7A5A1E;
  --focus: #1F5FBF;
  --reading-size: 21px;
}

.dark {
  --bg: #171412;
  --surface: #211C19;
  --surface-muted: #2A2420;
  --text: #EDE6DB;
  --text-muted: #A89E91;
  --border: #3A322C;
  --border-input: #7A6F63;
  --primary: #D9919B;
  --on-primary: #2B1216;
  --accent: #D2AE66;
  --accent-text: #D2AE66;
  --focus: #7FB0FF;
}

.reading {
  font-family: var(--font-serif);
  font-size: var(--reading-size);
  line-height: 1.8;
  max-width: 65ch;
}

:focus-visible {
  outline: 3px solid var(--focus);
  outline-offset: 2px;
}
```

### 12.2 Tailwind

```ts
// tailwind.config.ts (extracto)
theme: {
  extend: {
    colors: {
      bg: 'var(--bg)',
      surface: { DEFAULT: 'var(--surface)', muted: 'var(--surface-muted)' },
      text: { DEFAULT: 'var(--text)', muted: 'var(--text-muted)' },
      border: { DEFAULT: 'var(--border)', input: 'var(--border-input)' },
      primary: { DEFAULT: 'var(--primary)', hover: 'var(--primary-hover)', fg: 'var(--on-primary)' },
      focus: 'var(--focus)',
    },
    fontFamily: { serif: ['var(--font-serif)'], sans: ['var(--font-sans)'] },
    borderRadius: { sm: '6px', md: '8px', lg: '10px', xl: '12px' },
  },
}
```

Los colores de estado (2.3) y de rol (2.4) viven en un único mapa en TypeScript (`statusStyles`, `roleStyles`), consumido por `StatusBadge` y `Badge`, para no repetir clases por pantalla.

### 12.3 Reglas de código de UI
- `components/ui/` para la base (shadcn personalizado) y `components/dominio/` para los compuestos.
- Ningún componente de dominio define colores literales; todo viene de tokens.
- El estado mostrado (2.3) se calcula en el backend y llega en la API; la interfaz no lo deriva por su cuenta.
- Cada componente con estados (vacío, error, cargando) los recibe por props; no se improvisan en cada pantalla.
- Storybook no entra en el MVP: una página interna `/dev/ui` con los componentes alcanza. El lienzo de Claude Design es la referencia visual.

---

## 13. Pendientes y decisiones abiertas

**Pantallas por diseñar**
1. Fin del rosario (cierre y "siguiente misterio").
2. 404 y "ya no disponible" (contenido archivado o enlace regenerado).
3. "Sin permiso" (403).
4. Términos de uso y política de privacidad.
5. Estados de carga (skeletons) y de error con reintento, definidos una vez en Fundamentos.
6. Búsqueda sin resultados para un texto ("no encontramos nada para…").

**Correcciones en el lienzo**
- Aplicar `#776D62` al texto de ejemplo y `#948977` a los bordes de campos (2.5).

**Decisiones abiertas**
1. Nombre, logotipo y color final de marca (hoy "[Nombre]" y la paleta provisional).
2. Confirmar el uso de **tú**.
3. Imágenes de santos o advocaciones: si se usan, resolver derechos antes de diseñar con ellas.
4. Si en el futuro hay lectores con cuenta, decidir si las preferencias de lectura y el progreso de novenas se sincronizan.
