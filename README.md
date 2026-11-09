# Devoto Católico

Aplicación web para buscar y rezar oraciones, novenas y rosarios. Cualquier persona puede registrarse, crear su propio contenido en un espacio privado y solicitar su publicación; un revisor aprueba lo que llega al buscador público.

El producto, la arquitectura y el diseño están en [`docs/design/`](docs/design/) (empieza por `AGENTS.md`).

## Stack

| Capa | Tecnología |
|---|---|
| Backend | Python 3.12, FastAPI, SQLAlchemy 2.x (async), PostgreSQL 16, gestionado con [uv](https://docs.astral.sh/uv/) |
| Frontend | Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS 4, zod |
| Calidad | ruff, mypy, import-linter, ESLint, Prettier, dependency-cruiser, pytest, vitest, axe-core |
| Seguridad | bandit, pip-audit, npm audit, gitleaks, semgrep, trivy |
| Infra | Docker Compose, GitHub Actions |

## Estructura

```
backend/    API FastAPI. Módulos en app/modules/<mod>/ (router → service → repository → models)
frontend/   Next.js. src/app (rutas) → components → lib (API) → domain (tipos y zod)
docs/       Arquitectura y diseño
compose.yaml  Entorno local: db + api + web
Makefile    Punto de entrada para verificar, levantar y limpiar
```

Referencias de estilo: módulo `backend/app/modules/oraciones/` y pantalla `frontend/src/app/oraciones/`.

## Requisitos

Python 3.12 con uv, Node 24, Docker, y (para `make check`) gitleaks, semgrep y trivy.

## Puesta en marcha

```sh
make setup        # instala dependencias de backend y frontend (lockfiles en modo frozen)
```

Entorno completo en contenedores:

```sh
cp .env.example .env   # valores locales de ejemplo
make up                # db + api + web; API en :8000, web en :3000 (solo 127.0.0.1)
make down
make reset             # borra la base local (destructivo)
```

Sin Docker:

```sh
cd backend  && uv run uvicorn app.main:app --reload   # usa SQLite local por defecto
cd frontend && npm run dev
```

## Comandos

| Comando | Qué hace |
|---|---|
| `make check` | Lint, tipos, arquitectura, seguridad y tests. Silencioso si pasa; termina en `OK` |
| `make check-fast` | Lint, tipos y tests |
| `make security-full` | Añade semgrep y trivy (corre en CI) |
| `make lint-file FILE=ruta` | Lint y formato de un archivo |

El hook `pre-commit` ejecuta `make check`. La CI (`.github/workflows/ci.yml`) es la fuente de verdad.

## Notas

- Los tests del backend usan SQLite en memoria; lo específico de PostgreSQL (`unaccent`, `pg_trgm`) requiere pruebas contra la base de `compose.yaml`.
- El esquema se crea con `create_all` solo en desarrollo; Alembic está pendiente de configurar.
- Los releases se publican con un tag `v*` y pasan por `make audit-gate` (requiere una auditoría `audit-*` reciente).

## Licencia

Ver [`LICENSE`](LICENSE).
