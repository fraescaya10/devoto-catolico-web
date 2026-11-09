# Arquitectura y modelo de datos — App de oraciones, novenas y rosarios (CMS católico)

Versión del documento: 2.0 · Estado: borrador para validar

Este documento reúne la arquitectura y el modelo de datos. Documento complementario: `sistema-diseno.md` (UI).

**Cambios de la versión 2.0:** registro abierto; cada persona tiene un espacio privado y solicita publicar. Un revisor aprueba lo que llega al buscador y a los enlaces compartidos. Todo el contenido publicable (oraciones, secuencias y novenas) pasa por el mismo flujo con versionado, y se suman herramientas para que la moderación escale.

---

## Índice

1. Visión y alcance
2. Decisiones de arquitectura (ADR resumido)
3. Stack
4. Arquitectura lógica
5. Flujo de contenido y moderación
6. Modelo de datos
7. Estructura de repositorio
8. Contratos de API (resumen)
9. Seguridad, privacidad y abuso
10. Plan por fases
11. Estrategia de pruebas
12. Despliegue y operación
13. Riesgos
14. Definición de "hecho"

---

## 1. Visión y alcance

**Producto:** aplicación web pública y adaptable a cualquier dispositivo para buscar y rezar oraciones, novenas y rosarios. Cualquier persona puede registrarse y crear su propio contenido en un espacio privado: oraciones, secuencias (rosarios, coronillas) y novenas. Cuando quiere compartirlo, solicita su publicación; un revisor lo aprueba y desde entonces aparece en el buscador o se puede compartir por enlace.

**Evolución prevista:** CMS católico con más tipos de contenido (lecturas bíblicas, milagros, biografías), moderación comunitaria, multi-idioma, dashboards y un chatbot con RAG.

### Dentro del MVP (Fases 0 y 1)
- Búsqueda pública y lectura de oraciones, secuencias y novenas publicadas.
- Registro abierto con verificación de correo, login y recuperación de contraseña.
- Espacio privado por usuario: crear y editar oraciones, secuencias y novenas.
- Solicitud de publicación con requisitos, límites y detección de duplicados.
- Revisión con motivos predefinidos, vista de diferencias entre versiones y versionado.
- Compartir por enlace el contenido aprobado, con opción de no aparecer en el buscador.
- Reportes básicos sobre contenido publicado, suspensión de cuentas y gestión de roles.
- Términos de uso, política de privacidad y borrado de cuenta.
- SEO para el contenido público.

### Fuera del MVP (se difiere a propósito)
- Niveles de confianza y revisores comunitarios (Fase 2).
- Tipos `lectura_biblica`, `milagro`, `biografia` (Fase 3).
- Multi-idioma activo (Fase 4; el esquema ya lo contempla).
- Dashboards de métricas (Fase 5).
- Chatbot con RAG y pre-revisión con IA (Fase 6).

> Nota honesta: el registro abierto convierte el MVP en un producto con contenido de usuarios. Eso suma autenticación completa, versionado y moderación, y es la razón principal de que el MVP pase de unas 145-195 h a unas 200-275 h.

---

## 2. Decisiones de arquitectura (ADR resumido)

| # | Decisión | Motivo | Costo aceptado |
|---|---|---|---|
| ADR-1 | Monolito modular en FastAPI (no microservicios) | Un solo equipo, un solo despliegue; los módulos permiten separar luego | Disciplina para no acoplar módulos |
| ADR-2 | PostgreSQL como única base de datos | FTS nativo, `pg_trgm` (búsqueda y duplicados), `pgvector` para RAG; sin sincronizar sistemas | Una búsqueda a escala extrema pediría otro motor (no es el caso) |
| ADR-3 | Herencia por tabla base (`contenido`) + tablas hijas por tipo | FK reales desde secuencias y novenas; extensible a nuevos tipos | Un JOIN extra al leer |
| ADR-4 | Next.js App Router: SSR/ISR para lo público, CSR para el panel | SEO en contenido público; el panel no lo necesita | Dos modos de render en una app |
| ADR-5 | API separada en `/public`, `/me` (usuario) y `/moderacion` (revisor/admin) | Permisos y cache distintos por superficie | Algo de duplicación de DTOs |
| ADR-6 | Rol único por usuario: `usuario` (por defecto), `revisor`, `admin` | 3 roles fijos; YAGNI sobre RBAC granular | Migrar a tabla de roles si aparece el caso |
| ADR-7 | JWT corto + refresh en cookie httpOnly con rotación | Evita tokens en localStorage | Manejo de refresh en el cliente |
| ADR-8 | Revalidación on-demand (ISR) al aprobar | Lectura pública rápida sin consultar la BD en cada visita | Endpoint de revalidación protegido |
| ADR-9 | Sin LangChain/LlamaIndex para el RAG | KISS: pgvector + llamada directa al LLM | Más código propio si el flujo se complica |
| ADR-10 | **Versionado:** los datos tipados viven por versión (`contenido_version` + tablas hijas por versión) | Editar algo publicado no cambia lo visible hasta que se aprueba; evita "aprobar y cambiar" | Más tablas y consultas más elaboradas |
| ADR-11 | **Todo lo publicable es `contenido`:** oración, secuencia y novena son tipos | Un solo flujo de publicación, versionado y permisos (DRY) | Las secuencias y novenas también pasan por versionado |
| ADR-12 | Correo transaccional mediante un proveedor externo (Amazon SES o cualquier SMTP) | La verificación y la recuperación son obligatorias con registro abierto | Configurar SPF/DKIM/DMARC y vigilar la entregabilidad |
| ADR-13 | La IA solo filtra y resume; nunca aprueba | Un error doctrinal publicado es el riesgo principal del producto | Siempre hace falta un revisor humano |

**Pendiente de validar por ti:** FastAPI vs Django. Con registro abierto, Django aporta aún más (auth, verificación y recuperación casi listos). Sigue siendo la opción más rápida para el MVP; esta arquitectura asume FastAPI.

---

## 3. Stack

| Capa | Tecnología |
|---|---|
| Frontend | Next.js (App Router), TypeScript, Tailwind CSS, shadcn/ui |
| Estado/datos cliente | TanStack Query (panel), React Hook Form + Zod |
| Backend | Python 3.12, FastAPI, Pydantic v2, SQLAlchemy 2.x (async), Alembic |
| Base de datos | PostgreSQL 16 (`unaccent`, `pg_trgm`; `pgvector` en Fase 6) |
| Auth | JWT (access 15 min) + refresh httpOnly rotativo, argon2 |
| Correo | Proveedor transaccional (SES o SMTP) con plantillas propias |
| Anti-abuso | Captcha respetuoso con la privacidad (Cloudflare Turnstile o hCaptcha), rate limiting |
| Tareas en segundo plano | `BackgroundTasks` de FastAPI para correos; una cola real solo si el volumen lo exige |
| Diferencias de texto | `difflib` (Python) en el backend, renderizado en el panel |
| Tests | pytest + httpx, Vitest + Testing Library, Playwright |
| Calidad | Ruff, mypy, ESLint, Prettier, pre-commit |
| Infra | Docker Compose, proxy inverso (Caddy/Nginx), GitHub Actions |

---

## 4. Arquitectura lógica

```
                    ┌───────────────────────────────┐
  Visitante ──────▶ │ Next.js público (SSR/ISR)     │──┐ /api/v1/public/*
                    └───────────────────────────────┘  │
  Usuario ────────▶ ┌───────────────────────────────┐  │ /api/v1/auth/*
  Revisor/Admin     │ Next.js panel (CSR)           │──┤ /api/v1/me/*
                    └───────────────────────────────┘  │ /api/v1/moderacion/*
                                                       ▼
                                          ┌───────────────────────┐     ┌──────────────┐
                                          │ FastAPI (monolito     │────▶│ Proveedor de │
                                          │ modular)              │     │ correo       │
                                          └──────────┬────────────┘     └──────────────┘
                                                     ▼
                                          ┌───────────────────────┐
                                          │ PostgreSQL            │
                                          └───────────────────────┘
```

### Capas del backend (por módulo)
`router` (HTTP, delgado) → `service` (reglas de negocio) → `repository` (acceso a datos) → `models` (SQLAlchemy). Los `schemas` (Pydantic) son DTOs, nunca modelos de BD.

**Aplicación de principios**
- **SRP:** el router no tiene lógica; el service no conoce HTTP; el repository no conoce reglas.
- **DIP:** los services reciben repositorios por inyección (`Depends`), lo que permite tests con repositorios falsos.
- **DRY:** un solo servicio de publicación (`publicacion`) para todos los tipos; paginación, errores y permisos compartidos.
- **OCP:** un tipo nuevo de contenido implementa una interfaz pequeña (validar, indexar, renderizar) sin tocar el flujo de publicación.
- **YAGNI/KISS:** sin colas, caches externos ni eventos hasta que un requisito real lo pida.

---

## 5. Flujo de contenido y moderación

### 5.1 Estados

Cada contenido tiene versiones. El estado que ve el usuario se **deriva** de sus versiones; no se guarda aparte.

| Estado visible | Condición | Qué ve el público |
|---|---|---|
| **Privado** | Sin versión aprobada; la última versión está en borrador | Nada |
| **En revisión** | Sin versión aprobada; la última versión está en revisión | Nada |
| **Rechazado** | Sin versión aprobada; la última versión fue rechazada | Nada |
| **Publicado** | Tiene versión aprobada y no hay cambios pendientes | La versión aprobada |
| **Publicado · cambios en borrador** | Versión aprobada + versión nueva en borrador | La versión aprobada |
| **Publicado · cambios en revisión** | Versión aprobada + versión nueva en revisión | La versión aprobada |
| **Archivado** | El autor lo retiró (`archivado_at`) | Nada; los enlaces responden "ya no disponible" |

### 5.2 Visibilidad al publicar (la elige el autor)

- `listado`: aparece en el buscador y se comparte por su dirección (`/oraciones/{slug}`).
- `solo_enlace`: no aparece en el buscador ni en el sitemap y lleva `noindex`; se comparte por una dirección con token (`/c/{token}`). El autor puede regenerar el token para invalidar los enlaces anteriores.

La aprobación es la misma en ambos casos. **Nada se comparte sin aprobación.**

### 5.3 Reglas de negocio

| Regla | Detalle |
|---|---|
| Edición | El autor edita siempre su última versión en borrador; si no existe, se crea una copia de la aprobada |
| Correo sin verificar | Se puede ingresar y crear contenido privado; para solicitar publicación hace falta el correo verificado |
| Solicitar | Requiere los campos obligatorios completos (incluida la `fuente`) y confirmar que se tiene derecho a publicar el texto |
| Límite de solicitudes | Máximo 3 versiones en revisión por usuario; 1 si la cuenta tiene menos de 7 días (configurable) |
| Duplicados | Al solicitar se busca contenido publicado similar (`pg_trgm` sobre título y texto). Si la similitud supera un umbral, se avisa y el autor elige: usar el existente o justificar la diferencia |
| Secuencias y novenas | Solo pueden incluir contenido propio o contenido publicado de otros. Para aprobarlas, todo lo que incluyen debe estar aprobado; el contenido propio no aprobado se revisa en la misma solicitud |
| Autorrevisión | Un revisor no puede aprobar su propio contenido. El admin sí puede, y queda registrado (necesario mientras haya un solo administrador) |
| Rechazo | Requiere un motivo predefinido; el comentario es opcional |
| Prioridad en la cola | 1) cambios menores a contenido publicado, 2) secuencias y novenas que solo usan contenido aprobado, 3) contenido nuevo, 4) solicitudes marcadas como posible duplicado; dentro de cada grupo, la más antigua primero |
| Suspensión | Un usuario suspendido no puede iniciar sesión; su contenido publicado se oculta hasta que un admin decida |
| Reportes | Cualquier visitante reporta contenido publicado; con 3 reportes abiertos, el contenido se oculta hasta que un revisor lo resuelva (umbral configurable) |

### 5.4 Matriz de permisos

| Acción | usuario | revisor | admin |
|---|---|---|---|
| Crear, editar y archivar contenido propio | ✓ | ✓ | ✓ |
| Solicitar publicación y elegir visibilidad | ✓ | ✓ | ✓ |
| Compartir y regenerar el enlace de su contenido aprobado | ✓ | ✓ | ✓ |
| Ver la cola de revisión, aprobar y rechazar (no lo propio) | | ✓ | ✓ |
| Resolver reportes | | ✓ | ✓ |
| Aprobar su propio contenido | | | ✓ (registrado) |
| Cambiar roles, suspender y reactivar cuentas | | | ✓ |
| Configurar límites y umbrales | | | ✓ |

La matriz se implementa en un único módulo de autorización de la capa de servicio.

---

## 6. Modelo de datos

### 6.1 Decisiones del modelo

- `contenido` es la tabla base de todo lo publicable: oración (`recurso_catolico`), `secuencia` y `novena` en el MVP; `lectura_biblica`, `milagro` y `biografia` en la Fase 3.
- Los datos tipados viven **por versión**: cada tabla hija usa como PK el `version_id`. Así la versión aprobada y el borrador conviven sin pisarse.
- Las referencias entre contenidos (ítems de secuencia, días de novena) apuntan a `contenido.id`, no a una versión: al mostrar se usa la versión aprobada vigente de cada referencia.
- El índice de búsqueda solo considera versiones aprobadas de contenido `listado`, no archivado y de autores no suspendidos.
- `slug` único por `(locale, slug)`; `token_compartir` único; `fuente` obligatoria para solicitar publicación.

### 6.2 Usuarios y cuenta

#### `usuario`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| email | citext, unique | |
| password_hash | varchar | argon2 |
| nombre_visible | varchar | se muestra como autor |
| rol | enum | `usuario` (default), `revisor`, `admin` |
| estado | enum | `pendiente_verificacion`, `activo`, `suspendido` |
| email_verificado_at | timestamp, nullable | |
| terminos_aceptados_at | timestamp | versión de términos aceptada en `terminos_version` |
| terminos_version | varchar | |
| suspendido_motivo | text, nullable | |
| created_at / updated_at | timestamp | |

#### `token_usuario`
Tokens de un solo uso para verificar el correo y recuperar la contraseña.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| usuario_id | FK → usuario.id | |
| tipo | enum | `verificacion`, `recuperacion` |
| token_hash | varchar | se guarda solo el hash |
| expira_at | timestamp | 24 h verificación, 1 h recuperación |
| usado_at | timestamp, nullable | |

#### `sesion`
Refresh tokens con rotación; permite cerrar sesión en todos los dispositivos.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| usuario_id | FK → usuario.id | |
| refresh_hash | varchar | |
| expira_at / revocada_at | timestamp | |
| creada_at / user_agent | timestamp / varchar | |

### 6.3 Contenido y versiones

#### `contenido`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| tipo | enum | `recurso_catolico`, `secuencia`, `novena` (más tipos en Fase 3) |
| autor_id | FK → usuario.id | |
| locale | varchar | default `es` |
| translation_group_id | uuid, nullable | agrupa traducciones (Fase 4) |
| slug | varchar, nullable | se asigna al aprobar por primera vez |
| visibilidad | enum, nullable | `listado`, `solo_enlace`; la elige el autor al solicitar |
| token_compartir | varchar, unique, nullable | para `solo_enlace`; regenerable |
| version_aprobada_id | FK → contenido_version.id, nullable | la que ve el público |
| archivado_at | timestamp, nullable | |
| oculto_por_reportes | boolean | default false |
| created_at / updated_at | timestamp | |

**Restricciones:** único `(locale, slug)` cuando `slug` no es nulo; único `token_compartir`.

#### `contenido_version`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| contenido_id | FK → contenido.id | |
| numero | int | 1, 2, 3… |
| estado | enum | `borrador`, `en_revision`, `aprobada`, `rechazada`, `reemplazada` |
| fuente | text, nullable | obligatoria al pasar a `en_revision` |
| justificacion_duplicado | text, nullable | si el autor insistió ante un aviso de duplicado |
| similitud_max | numeric, nullable | similitud con el publicado más parecido, calculada al solicitar |
| creada_por | FK → usuario.id | |
| enviada_at | timestamp, nullable | |
| revisada_por | FK → usuario.id, nullable | |
| revisada_at | timestamp, nullable | |
| motivo_rechazo | enum, nullable | `duplicado`, `falta_fuente`, `error_doctrinal`, `no_es_contenido_catolico`, `derechos_de_autor`, `calidad_texto`, `otro` |
| comentario_revision | text, nullable | |
| created_at | timestamp | |

**Restricciones:** único `(contenido_id, numero)`; índice único parcial que permite **una sola** versión en `borrador` o `en_revision` por contenido; `CHECK` de que `motivo_rechazo` no sea nulo cuando `estado = 'rechazada'`.

**Al aprobar** (en una transacción): la versión pasa a `aprobada`, la anterior aprobada pasa a `reemplazada`, se actualiza `contenido.version_aprobada_id`, se genera el `slug` si falta y se dispara la revalidación pública.

#### `contenido_evento`
Bitácora de todo lo que pasa con un contenido; alimenta el historial del panel.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| contenido_id | FK → contenido.id | |
| version_id | FK → contenido_version.id, nullable | |
| usuario_id | FK → usuario.id, nullable | nulo si fue el sistema (ocultado por reportes) |
| tipo | enum | `creado`, `solicitado`, `aprobado`, `rechazado`, `archivado`, `restaurado`, `enlace_regenerado`, `ocultado`, `visibilidad_cambiada` |
| detalle | text, nullable | |
| created_at | timestamp | |

### 6.4 Tipos de contenido (por versión)

#### `recurso_catolico`
| Campo | Tipo | Notas |
|---|---|---|
| version_id | uuid (PK, FK → contenido_version.id) | |
| titulo | varchar | |
| texto | text | |
| tipo_recurso | enum | `oracion`, `jaculatoria`, `cantico`, `relato`, `parabola` |
| search_vector | tsvector, generada | `spanish` + `immutable_unaccent` sobre título y texto; índice GIN |

Índice `pg_trgm` sobre `titulo` y `texto` para la detección de duplicados.

#### `secuencia`
| Campo | Tipo | Notas |
|---|---|---|
| version_id | uuid (PK, FK → contenido_version.id) | |
| nombre | varchar | |
| descripcion | text, nullable | |

#### `secuencia_item`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| secuencia_version_id | FK → secuencia.version_id | |
| id_contenido | FK → contenido.id | referencia lógica: se muestra su versión aprobada |
| orden | int | posición |
| repeticiones | int, NOT NULL, default 1 | "Ave María × 10" es un solo ítem |

**Restricciones:** único `(secuencia_version_id, orden)` `DEFERRABLE INITIALLY DEFERRED`; `CHECK (repeticiones >= 1)`. El visor público expande las repeticiones en pasos ("Ave María · 3 de 10") sin crear filas.

#### `novena`
| Campo | Tipo | Notas |
|---|---|---|
| version_id | uuid (PK, FK → contenido_version.id) | |
| titulo | varchar | |
| apertura_id | FK → contenido.id (tipo `secuencia`), nullable | |
| cierre_id | FK → contenido.id (tipo `secuencia`), nullable | |

#### `dia_novena`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| novena_version_id | FK → novena.version_id | |
| nro_dia | int | |
| secuencia_id | FK → contenido.id (tipo `secuencia`) | |

**Restricciones:** único `(novena_version_id, nro_dia)`; `CHECK (nro_dia BETWEEN 1 AND 9)`. Se puede guardar incompleta; para solicitar la publicación, el servicio exige apertura, 9 días y cierre.

### 6.5 Moderación

#### `reporte`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| contenido_id | FK → contenido.id | |
| reportado_por | FK → usuario.id, nullable | se permite reportar sin cuenta (con captcha y límite por IP) |
| motivo | enum | `error_doctrinal`, `ofensivo`, `spam`, `derechos_de_autor`, `otro` |
| detalle | text, nullable | |
| estado | enum | `abierto`, `resuelto`, `descartado` |
| resuelto_por / resuelto_at | FK usuario / timestamp, nullable | |
| created_at | timestamp | |

#### `configuracion`
Clave-valor editable por el admin: `max_solicitudes_pendientes` (3), `max_solicitudes_cuenta_nueva` (1), `dias_cuenta_nueva` (7), `umbral_duplicado` (0.6), `reportes_para_ocultar` (3).

### 6.6 Fases posteriores (referencia)

- **Fase 2:** `usuario.nivel_confianza` (calculado por aprobaciones y rechazos recientes) y una vista materializada con métricas de la cola.
- **Fase 3:** `lectura_biblica`, `milagro`, `biografia` como tipos por versión, con el mismo patrón; las relaciones de biografía (`biografia_milagro`, `biografia_oracion`) apuntan a `contenido.id`.
- **Fase 6:** `content_chunks` (`pgvector`) generado solo desde versiones aprobadas; `prerevision_ia` con la clasificación y el resumen por versión.

---

## 7. Estructura de repositorio

```
oraciones/
├── backend/
│   ├── app/
│   │   ├── core/              # config, seguridad, errores, logging
│   │   ├── db/                # sesión, base declarativa
│   │   ├── shared/            # paginación, permisos, utilidades
│   │   └── modules/
│   │       ├── auth/          # registro, verificación, login, recuperación, sesiones
│   │       ├── usuarios/      # perfil, roles, suspensión, borrado de cuenta
│   │       ├── correo/        # plantillas y envío
│   │       ├── contenido/     # contenido, versiones, eventos
│   │       ├── tipos/         # recurso_catolico, secuencia, novena (interfaz común)
│   │       ├── publicacion/   # solicitudes, límites, duplicados, aprobación
│   │       ├── moderacion/    # cola, diferencias, reportes
│   │       ├── compartir/     # visibilidad y tokens
│   │       └── busqueda/
│   ├── alembic/
│   └── tests/
├── frontend/
│   ├── app/
│   │   ├── (publico)/         # inicio, búsqueda, lectura, novenas, rosarios, /c/[token]
│   │   ├── (cuenta)/          # ingresar, registro, verificar, recuperar
│   │   └── (panel)/           # inicio, mis contenidos, editores, revisión, usuarios
│   ├── components/            # ui/ (base), dominio/ (compuestos)
│   ├── lib/
│   └── tests/
├── docker-compose.yml
└── docs/
```

---

## 8. Contratos de API (resumen)

**Público (sin auth, cacheable)**
- `GET /public/buscar?q=&tipo=&page=` — solo versiones aprobadas de contenido `listado`.
- `GET /public/contenido/{slug}` · `GET /public/c/{token}` (solo enlace).
- `GET /public/novenas` · `GET /public/rosarios`.
- `POST /public/contenido/{id}/reportes` — con captcha y límite por IP.

**Cuenta**
- `POST /auth/registro` (captcha) · `POST /auth/verificar` · `POST /auth/reenviar-verificacion`
- `POST /auth/login` · `POST /auth/refresh` · `POST /auth/logout` · `POST /auth/logout-todo`
- `POST /auth/recuperar` · `POST /auth/restablecer`
- `DELETE /me/cuenta` — borra la cuenta; el contenido publicado se anonimiza o se archiva según la política.

**Usuario (`/me`)**
- `GET /me/resumen` — datos del dashboard.
- `CRUD /me/contenidos` (filtros por tipo y estado) · `PUT /me/contenidos/{id}/borrador`
- `POST /me/contenidos/{id}/verificar-duplicados` — previsualiza similitudes antes de solicitar.
- `POST /me/contenidos/{id}/solicitar` (visibilidad, fuente, justificación si hay duplicado).
- `POST /me/contenidos/{id}/archivar` · `POST /me/contenidos/{id}/enlace/regenerar`
- `GET /me/contenidos/{id}/versiones` · `GET /me/contenidos/{id}/eventos`
- `PUT /me/secuencias/{id}/items` (orden y repeticiones) · `PUT /me/novenas/{id}/estructura`

**Moderación (revisor/admin)**
- `GET /moderacion/cola?prioridad=&tipo=` · `GET /moderacion/versiones/{id}` (con diferencias contra la aprobada)
- `POST /moderacion/versiones/{id}/aprobar` · `POST /moderacion/versiones/{id}/rechazar` (motivo obligatorio)
- `GET /moderacion/reportes` · `POST /moderacion/reportes/{id}/resolver`
- `GET/PATCH /moderacion/usuarios` (rol, suspensión; solo admin) · `GET/PUT /moderacion/configuracion` (solo admin)

Convención: errores `{code, message, details}`; versionado en la URL (`/api/v1`).

---

## 9. Seguridad, privacidad y abuso

- **Contraseñas:** argon2, mínimo 10 caracteres, comprobación contra contraseñas filtradas comunes.
- **Tokens:** refresh en cookie `httpOnly`, `Secure`, `SameSite=Lax`, con rotación; los tokens de correo se guardan hasheados y son de un solo uso.
- **Enumeración de cuentas:** registro y recuperación responden igual exista o no el correo.
- **Límites:** por IP y por cuenta en login, registro, recuperación, reportes y solicitudes.
- **Captcha** en registro, recuperación y reportes anónimos.
- **Autorización** en la capa de servicio con la matriz de 5.4; los endpoints `/me` filtran siempre por `autor_id`.
- **Contenido:** se trata como texto plano; si se admite formato, Markdown restringido y sanitizado al renderizar.
- **`solo_enlace`:** token aleatorio de 128 bits, `noindex`, fuera del sitemap, regenerable.
- **Privacidad (Ley Orgánica de Protección de Datos Personales de Ecuador):** política de privacidad, consentimiento registrado (`terminos_aceptados_at`), borrado de cuenta, datos mínimos (sin teléfono ni dirección), registros sin contraseñas ni tokens.
- **Derechos de autor:** el usuario declara en los términos que tiene derecho a publicar lo que sube; el campo `fuente` es obligatorio para solicitar; el motivo de rechazo `derechos_de_autor` y el reporte equivalente permiten retirar contenido.
- **Correo:** SPF, DKIM y DMARC configurados antes de abrir el registro.

---

## 10. Plan por fases

Horas para una sola persona con experiencia en el stack. Incluyen pruebas básicas de cada tarea, no el colchón.

**Total MVP (Fase 0 + Fase 1): 202-275 h**, antes del margen. Con un 20-30 % de colchón: **240-360 h**.

| Fase | Contenido | Horas |
|---|---|---|
| 0 | Fundaciones | 8-12 |
| 1 | MVP (E1-E9) | 194-263 |
| 2 | Moderación escalable (confianza, revisores comunitarios, métricas de cola) | 16-24 |
| 3 | Tipos de contenido adicionales | 35-50 |
| 4 | Multi-idioma | 20-30 |
| 5 | Dashboards y analítica | 20-30 |
| 6 | RAG, chatbot y pre-revisión con IA | 50-74 |

---

### FASE 0 — Fundaciones (8-12 h)

**Epic E0 · Entorno y tooling**

| ID | Tarea | Horas |
|---|---|---|
| E0-T1 | Monorepo, convenciones de ramas y commits | 1 |
| E0-T2 | `docker-compose` con Postgres 16 y un servidor de correo de pruebas (Mailpit) | 1-2 |
| E0-T3 | Esqueleto FastAPI (config por entorno, logging, errores comunes, `/health`) | 2-3 |
| E0-T4 | Esqueleto Next.js + Tailwind + shadcn/ui + cliente API tipado | 2-3 |
| E0-T5 | Linters, formateo, pre-commit, mypy/ESLint | 1-2 |
| E0-T6 | CI (lint + tests) en cada PR | 1 |

---

### FASE 1 — MVP (194-263 h)

**Epic E1 · Base de datos y migraciones (16-22 h)**

| ID | Tarea | Horas |
|---|---|---|
| E1-T1 | Alembic y sesión async de SQLAlchemy | 2 |
| E1-T2 | Extensiones `unaccent`, `pg_trgm`, `citext` y función `immutable_unaccent` | 1-2 |
| E1-T3 | Migración: `usuario`, `token_usuario`, `sesion`, `configuracion` | 3-4 |
| E1-T4 | Migración: `contenido`, `contenido_version` (con índice único parcial), `contenido_evento` | 3-4 |
| E1-T5 | Migración: `recurso_catolico` con `search_vector` + GIN e índices trigram | 2-3 |
| E1-T6 | Migración: `secuencia`, `secuencia_item` (orden diferible, repeticiones), `novena`, `dia_novena` | 3-4 |
| E1-T7 | Migración: `reporte`; datos semilla de desarrollo | 2-3 |

*Nota técnica:* `unaccent` no es inmutable en PostgreSQL; se envuelve en una función propia `IMMUTABLE` (E1-T2) para poder usarla en columnas generadas e índices.

**Epic E2 · Cuentas y autenticación (24-32 h)**

| ID | Tarea | Horas |
|---|---|---|
| E2-T1 | Módulo de correo: proveedor, plantillas (verificación, recuperación, aprobado, rechazado) y envío en segundo plano | 4-5 |
| E2-T2 | Registro con captcha, aceptación de términos y envío de verificación | 3-4 |
| E2-T3 | Verificación de correo y reenvío con límite | 2-3 |
| E2-T4 | Login, refresh rotativo, logout y logout en todos los dispositivos | 4-5 |
| E2-T5 | Recuperar y restablecer contraseña | 3-4 |
| E2-T6 | Autorización por rol y estado (`require_role`, bloqueo de suspendidos) | 2-3 |
| E2-T7 | Rate limiting y respuestas que no revelan si existe la cuenta | 2-3 |
| E2-T8 | Borrado de cuenta y comando para crear el primer admin | 2 |
| E2-T9 | Tests de flujos de cuenta y casos de abuso | 2-3 |

**Epic E3 · Contenido y versionado (22-30 h)**

| ID | Tarea | Horas |
|---|---|---|
| E3-T1 | Interfaz común de tipos (validar, copiar versión, renderizar, indexar) | 3-4 |
| E3-T2 | CRUD de contenido propio con su versión en borrador | 4-5 |
| E3-T3 | Crear un borrador nuevo desde la versión aprobada al editar algo publicado | 3-4 |
| E3-T4 | Estado derivado y filtros del listado ("Publicado · cambios en revisión", etc.) | 2-3 |
| E3-T5 | Tipo `recurso_catolico` completo | 3-4 |
| E3-T6 | Archivar y restaurar; bitácora `contenido_evento` | 2-3 |
| E3-T7 | Generación de `slug` al aprobar por primera vez | 1-2 |
| E3-T8 | Tests de versionado (no se pisa la aprobada; una sola versión abierta) | 4-5 |

**Epic E4 · Secuencias y novenas (16-22 h)**

| ID | Tarea | Horas |
|---|---|---|
| E4-T1 | Tipo `secuencia`: ítems con orden y repeticiones; reemplazo atómico de la lista | 4-5 |
| E4-T2 | Regla de referencias: solo contenido propio o publicado de otros | 2-3 |
| E4-T3 | Tipo `novena`: apertura, días y cierre; se puede guardar incompleta | 4-5 |
| E4-T4 | Validación para solicitar: novena completa y referencias aprobadas o incluidas en la solicitud | 3-4 |
| E4-T5 | Tests de orden, repeticiones y validación de novenas | 3-5 |

**Epic E5 · Publicación y moderación (22-30 h)**

| ID | Tarea | Horas |
|---|---|---|
| E5-T1 | Solicitar publicación: requisitos, términos, visibilidad y límites de solicitudes | 3-4 |
| E5-T2 | Detección de duplicados con `pg_trgm` (endpoint de previsualización y cálculo al solicitar) | 3-4 |
| E5-T3 | Cola priorizada según 5.3 | 3-4 |
| E5-T4 | Diferencias entre la versión enviada y la aprobada (`difflib`) | 3-4 |
| E5-T5 | Aprobar y rechazar con motivo; sin autorrevisión; aprobación transaccional y revalidación | 4-5 |
| E5-T6 | Compartir: visibilidad, token y regeneración | 2-3 |
| E5-T7 | Reportes con umbral de ocultamiento y resolución | 2-3 |
| E5-T8 | Notificaciones por correo de aprobación y rechazo | 1-2 |
| E5-T9 | Tests de permisos, límites, duplicados y transiciones | 1-1 |

**Epic E6 · Búsqueda y API pública (10-13 h)**

| ID | Tarea | Horas |
|---|---|---|
| E6-T1 | Búsqueda FTS con ranking + fallback trigram, solo sobre lo aprobado y listado | 3-4 |
| E6-T2 | Filtros, paginación y orden | 2 |
| E6-T3 | Endpoints públicos por slug y por token, con la versión aprobada vigente de cada referencia | 2-3 |
| E6-T4 | Cabeceras de cache, revalidación protegida, `noindex` en `solo_enlace` | 1-2 |
| E6-T5 | Tests: acentos, typos leves, nunca exponer borradores ni contenido oculto | 2 |

**Epic E7 · Frontend público (22-30 h)**

| ID | Tarea | Horas |
|---|---|---|
| E7-T1 | Layout público adaptable, cabecera con "Ingresar", tema claro/oscuro | 3-4 |
| E7-T2 | Búsqueda con filtros, estados vacíos y sin resultados | 4-5 |
| E7-T3 | Lectura (SSR/ISR, metadatos, JSON-LD) con botón "Reportar un problema" | 3-4 |
| E7-T4 | Listados de novenas y rosarios | 2-3 |
| E7-T5 | Visor de secuencia paso a paso con repeticiones expandidas y pantalla de cierre | 4-6 |
| E7-T6 | Visor de novena con progreso local | 3-4 |
| E7-T7 | Página por enlace (`/c/[token]`), 404 y "ya no disponible" | 2-3 |
| E7-T8 | `sitemap.xml`, `robots.txt`, términos y privacidad | 1-1 |

**Epic E8 · Frontend del panel (44-58 h)**

| ID | Tarea | Horas |
|---|---|---|
| E8-T1 | Pantallas de cuenta: ingresar, registro, verificar, recuperar y restablecer | 6-8 |
| E8-T2 | Shell del panel con menú por rol, sesión expirada y "sin permiso" | 3-4 |
| E8-T3 | Dashboard del usuario con estado vacío y guía de primeros pasos | 3-4 |
| E8-T4 | Mis contenidos: listado con estados derivados, visibilidad y filtros | 3-4 |
| E8-T5 | Editor de oración con flujo y historial | 4-5 |
| E8-T6 | Constructor de secuencias (botones subir/bajar, repeticiones, anuncios accesibles) | 6-8 |
| E8-T7 | Editor de novenas con requisitos en vivo | 4-5 |
| E8-T8 | Solicitar publicación: requisitos, visibilidad y aviso de duplicado | 3-4 |
| E8-T9 | Contenido publicado: compartir, regenerar enlace, versiones y cambios pendientes | 3-4 |
| E8-T10 | Cola de revisión: prioridad, diferencias, motivos y reportes | 6-8 |
| E8-T11 | Usuarios (admin): roles, suspensión, configuración de límites | 3-4 |

*Riesgo principal de desvío del MVP:* el constructor de secuencias (E8-T6), la cola con diferencias (E8-T10) y el versionado (E3).

**Epic E9 · Calidad, legal y despliegue (18-26 h)**

| ID | Tarea | Horas |
|---|---|---|
| E9-T1 | E2E de flujos críticos: registro → crear → solicitar → aprobar → compartir; buscar y rezar | 6-8 |
| E9-T2 | Accesibilidad y rendimiento (Lighthouse, teclado, lector de pantalla) | 3-4 |
| E9-T3 | Dockerfiles de producción, proxy con HTTPS, secretos | 3-4 |
| E9-T4 | Correo en producción: dominio, SPF/DKIM/DMARC, prueba de entregabilidad | 2-3 |
| E9-T5 | Backups con prueba de restauración | 2-3 |
| E9-T6 | Términos de uso y política de privacidad (redacción; conviene validarlos con un abogado) | 1-2 |
| E9-T7 | Contenido semilla publicado por el admin | 1-2 |

**Criterio de salida de la Fase 1:**
- una persona se registra, verifica su correo, crea una novena y solicita publicarla;
- un revisor la aprueba viendo las diferencias, y el autor la comparte por enlace o aparece en el buscador;
- editar lo publicado no cambia lo visible hasta una nueva aprobación;
- el sitio corre con HTTPS, correo autenticado y backups verificados.

---

### FASE 2 — Moderación escalable (16-24 h)

**Epic E10 · Confianza y revisores comunitarios**

| ID | Tarea | Horas |
|---|---|---|
| E10-T1 | Cálculo de nivel de confianza (aprobaciones, rechazos recientes, reportes) | 3-4 |
| E10-T2 | Colaboradores de confianza: sus cambios menores a contenido ya aprobado se publican sin cola; el contenido nuevo sigue pasando por revisión | 4-6 |
| E10-T3 | Promoción de colaboradores a revisores, con candidatos sugeridos por el sistema | 2-3 |
| E10-T4 | Métricas de cola: tamaño, tiempo medio de revisión, solicitudes por motivo | 4-6 |
| E10-T5 | Muestreo posterior: un revisor revisa al azar un porcentaje de lo publicado sin cola | 3-5 |

*Cuándo activarla:* cuando el tiempo medio de revisión supere unos días o la cola pase de unas decenas de solicitudes de forma sostenida.

---

### FASE 3 — Tipos de contenido adicionales (35-50 h)

**Epic E11 · Lecturas bíblicas, milagros y biografías**

| ID | Tarea | Horas |
|---|---|---|
| E11-T1 | Migraciones por versión de `lectura_biblica`, `milagro`, `biografia` y relaciones | 4-6 |
| E11-T2 | Implementación de la interfaz de tipo para cada uno (reutiliza publicación y moderación) | 8-12 |
| E11-T3 | Búsqueda multi-tipo con filtro | 3-4 |
| E11-T4 | Editores del panel por tipo | 10-14 |
| E11-T5 | Páginas públicas por tipo (biografía con milagros y oraciones relacionadas) | 8-10 |
| E11-T6 | Ítems de estos tipos en secuencias | 2-4 |

*Advertencia:* las traducciones de la Biblia tienen derechos de autor; antes de esta fase hay que decidir qué traducción se usa y con qué licencia.

---

### FASE 4 — Multi-idioma (20-30 h)

**Epic E12 · Localización**

| ID | Tarea | Horas |
|---|---|---|
| E12-T1 | Activar `locale` y `translation_group_id` en servicios y API | 4-6 |
| E12-T2 | Búsqueda con configuración FTS por idioma | 3-4 |
| E12-T3 | Rutas por idioma, `hreflang` y selector | 5-7 |
| E12-T4 | Crear traducciones desde el panel; cada traducción pasa por revisión | 6-9 |
| E12-T5 | Textos de interfaz | 2-4 |

---

### FASE 5 — Dashboards y analítica (20-30 h)

**Epic E13 · Métricas**

| ID | Tarea | Horas |
|---|---|---|
| E13-T1 | Definir métricas (producción, revisión, lecturas por contenido) | 2-3 |
| E13-T2 | Consultas agregadas y endpoints | 5-8 |
| E13-T3 | Eventos públicos de búsqueda y lectura, sin datos personales | 5-8 |
| E13-T4 | Dashboard del panel; para el autor, lecturas de su contenido publicado | 8-11 |

*Alternativa barata:* Metabase sobre vistas de solo lectura para los reportes internos.

---

### FASE 6 — RAG, chatbot y pre-revisión con IA (50-74 h)

**Epic E14 · Indexación semántica (14-20 h)**

| ID | Tarea | Horas |
|---|---|---|
| E14-T1 | `pgvector` y `content_chunks` (solo versiones aprobadas) | 3-4 |
| E14-T2 | Chunking por unidad natural (una oración, un paso, un versículo) | 4-6 |
| E14-T3 | Reindexación al aprobar o archivar | 5-7 |
| E14-T4 | Backfill del contenido existente | 2-3 |

**Epic E15 · Chatbot (26-38 h)**

| ID | Tarea | Horas |
|---|---|---|
| E15-T1 | Recuperación por similitud con filtros de idioma y visibilidad | 5-7 |
| E15-T2 | Prompt con límites: responder solo con contenido recuperado y citar las fuentes del sitio | 3-5 |
| E15-T3 | Endpoint con streaming (SSE) | 4-6 |
| E15-T4 | UI de chat con streaming y enlaces a las fuentes | 8-12 |
| E15-T5 | Evaluación con preguntas de prueba y revisión humana | 4-6 |
| E15-T6 | Límites de uso y control de costos | 2-2 |

**Epic E16 · Pre-revisión con IA (10-16 h)**

| ID | Tarea | Horas |
|---|---|---|
| E16-T1 | Clasificar cada solicitud: spam u ofensivo, posible duplicado, falta de fuente, señales doctrinales | 4-6 |
| E16-T2 | Resumen para el revisor y etiquetas visibles en la cola | 3-5 |
| E16-T3 | Rechazo automático solo de spam evidente, con revisión humana por muestreo | 3-5 |

*Riesgo específico:* en un contexto religioso, una respuesta inventada o doctrinalmente incorrecta es grave. El chatbot responde solo con contenido recuperado y declina cuando no lo tiene; la IA de moderación nunca aprueba (ADR-13).

---

## 11. Estrategia de pruebas

| Nivel | Qué cubre | Herramienta |
|---|---|---|
| Unitarias | Versionado, estado derivado, matriz de permisos, límites, duplicados, validación de novenas | pytest, repositorios falsos |
| Integración | Endpoints con BD real y correo de prueba (Mailpit) | pytest + httpx |
| Componentes | Formularios, constructor y visores | Vitest + Testing Library |
| E2E | Registro → publicación → compartir; búsqueda y lectura | Playwright |

Prioridad de cobertura: que nunca se exponga una versión no aprobada, la autorización, el versionado, los límites y la búsqueda con acentos. No se persigue un porcentaje global.

---

## 12. Despliegue y operación

- **MVP:** un servidor con Docker Compose (frontend, backend, Postgres, proxy con HTTPS) y un proveedor de correo externo. Kubernetes sería sobreingeniería ahora.
- **Backups:** `pg_dump` diario a almacenamiento externo, con una restauración de prueba documentada.
- **Observabilidad mínima:** logs estructurados, `/health`, alertas de caída y de rebote de correos; Sentry o equivalente si el presupuesto lo permite.
- **Migraciones:** en el despliegue, siempre compatibles hacia atrás.
- **Operación de moderación:** revisar a diario el tamaño de la cola y los reportes abiertos; es la señal para activar la Fase 2.

---

## 13. Riesgos

| Riesgo | Prob. | Impacto | Mitigación |
|---|---|---|---|
| La cola de revisión crece más rápido de lo que se revisa | Media | Alto | Duplicados, límites y prioridad desde el MVP; Fase 2 (confianza y revisores comunitarios); IA como filtro en la Fase 6 |
| Spam y cuentas falsas | Alta | Medio | Verificación de correo, captcha, límites, suspensión; nada se publica sin revisión |
| Contenido con derechos de autor | Media | Alto | `fuente` obligatoria, declaración en los términos, motivo de rechazo y reporte específicos |
| Errores doctrinales publicados | Baja | Alto | Revisión humana obligatoria; reportes con ocultamiento automático |
| Cumplimiento de la LOPDP | Media | Alto | Datos mínimos, consentimiento, borrado de cuenta, política de privacidad validada |
| Correos que caen en spam | Media | Medio | SPF/DKIM/DMARC, proveedor con buena reputación, monitoreo de rebotes |
| Complejidad del versionado | Media | Medio | Un único servicio de publicación y tests dedicados (E3-T8) |
| Constructor de secuencias más complejo de lo previsto | Media | Medio | Botones subir/bajar primero; arrastrar como mejora |
| Respuestas incorrectas del chatbot | Media | Alto | Respuestas ancladas en contenido, evaluación humana, opción de desactivar |
| Costo de LLM y embeddings | Media | Medio | Límites de uso y cache |

---

## 14. Definición de "hecho"

Una tarea está terminada cuando: cumple su criterio de aceptación, tiene tests de lo que decide comportamiento, pasa lint y tipos, está revisada, y su migración (si la hay) sube y baja sin pérdida.
