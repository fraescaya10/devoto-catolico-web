# Regla: cada target es SILENCIOSO si pasa y solo imprime errores si falla.
# Monorepo: backend/ (FastAPI, uv) y frontend/ (Next.js, npm).

.PHONY: setup check check-fast lint typecheck complexity arch security security-full test lint-file dev up down reset audit-gate dast perf pentest

# Instala dependencias del proyecto y herramientas de check con versión exacta. Lo usa CI.
setup:
	@cd backend && uv sync --frozen -q
	@cd frontend && npm ci --loglevel error
	@# gitleaks y trivy: versión fijada y checksum verificado en .github/workflows/ci.yml; localmente vía brew.
	@command -v semgrep >/dev/null || uv tool install -q semgrep==1.180.0

check: lint typecheck complexity arch security test
	@echo OK

# Verificación rápida por paso (agente verify, task Fase 2). El check completo corre en el pre-commit y al cerrar.
check-fast: lint typecheck test
	@echo OK

lint:
	@cd backend && uv run ruff check -q . && uv run ruff format -q --check .
	@cd frontend && npx eslint --quiet . && npx prettier -c --log-level warn .

typecheck:
	@cd backend && uv run mypy --strict --no-error-summary app tests
	@cd frontend && npx tsc --noEmit --pretty false

# Incluido en lint: ruff (C901, PLR) y eslint (complexity, max-lines-per-function, sonarjs).
complexity:
	@true

arch:
	@cd backend && out=$$(uv run lint-imports --no-cache 2>&1) || { echo "$$out"; exit 1; }
	@cd frontend && npx depcruise --config .dependency-cruiser.cjs src --output-type err

security:
	@cd backend && uv run bandit -q -r app -ll
	@cd backend && out=$$(uv run pip-audit --strict 2>&1) || { echo "$$out"; exit 1; }
	@cd frontend && npm audit --audit-level=high --omit=dev >/dev/null && npm audit signatures >/dev/null
	@gitleaks detect --no-banner --log-level error

# Lo lento (semgrep, trivy). Corre en CI y en /audit.
security-full: security
	@semgrep scan -q --error --metrics=off --config p/owasp-top-ten --config p/python --config p/typescript backend/app frontend/src
	@trivy fs -q --exit-code 1 --severity HIGH,CRITICAL --scanners vuln,secret,misconfig --skip-dirs frontend/node_modules --skip-dirs backend/.venv --skip-dirs frontend/.next .

test:
	@cd backend && uv run pytest -q -x --tb=short -p no:warnings
	@cd frontend && npx vitest run --silent --reporter=dot

# Usado por el hook PostToolUse. FILE=ruta (relativa a la raíz)
lint-file:
	@case "$(FILE)" in \
	  backend/*.py) cd backend && uv run ruff check -q --fix "$${FILE#backend/}" && uv run ruff format -q "$${FILE#backend/}" ;; \
	  frontend/*) cd frontend && npx eslint --quiet "$${FILE#frontend/}" && npx prettier -w --log-level error "$${FILE#frontend/}" ;; \
	esac

dev:
	@echo "Backend:  cd backend && uv run uvicorn app.main:app --reload"
	@echo "Frontend: cd frontend && npm run dev"
	@echo "Todo en contenedores: make up"

# Gate de despliegue (no forma parte de check). Corre en CI antes del deploy, sin agente.
# Lee el último tag anotado `audit-*` del historial (lo crea /audit; viaja con `git push` si push.followTags=true).
# Falla si: no hay auditoría, quedó desactualizada, o tiene hallazgos Crítica/Alta abiertos.
# CI necesita historial y tags completos (fetch-depth: 0 / GIT_DEPTH: 0).
AUDIT_MAX_COMMITS ?= 30
audit-gate:
	@t=$$(git describe --match 'audit-*' --abbrev=0 2>/dev/null) || { echo "Sin auditoría en el historial. Ejecuta /audit localmente y luego git push."; exit 1; }; \
	n=$$(git rev-list --count $$t..HEAD); \
	[ "$$n" -le $(AUDIT_MAX_COMMITS) ] || { echo "Auditoría $$t desactualizada: $$n commits después (máx. $(AUDIT_MAX_COMMITS)). Ejecuta /audit."; exit 1; }; \
	msg=$$(git tag -l --format='%(contents)' "$$t"); \
	echo "$$msg" | grep -qE '(^| )criticas=0 altas=0( |$$)' || { echo "$$t tiene hallazgos Crítica/Alta abiertos: $$msg"; exit 1; }

# Entorno local (Docker Compose). Silencioso si arranca; si falla, muestra el servicio caído y sus logs.
up:
	@docker compose up -d --wait --quiet-pull >/dev/null 2>&1 || { docker compose ps; for s in $$(docker compose ps -a --status exited --status restarting --format '{{.Service}}'); do echo "--- $$s"; docker compose logs --tail 20 $$s; done; exit 1; }

down:
	@docker compose down >/dev/null 2>&1

# Destructivo: borra la base local. El agente nunca lo ejecuta sin petición explícita.
reset:
	@docker compose down -v

# DAST opcional (OWASP ZAP baseline). Desactivado: bootstrap lo completa solo si se pide.
dast:
	@# <BOOTSTRAP opcional: levantar la app (docker compose up -d --wait) y correr zap-baseline.py contra ella, imagen ZAP por digest>
	@true

# Corrida completa de pentest (la escribe la skill pentest; pesada, no forma parte de check).
# Los tests de regresión de tests/security/ ya corren en `make check`; esto re-ejecuta el escaneo dinámico.
# Falla cerrado: sin SCOPE.md firmado no corre, y nunca contra un destino fuera de alcance.
pentest:
	@test -f .tasks/pentest/SCOPE.md || { echo "Sin alcance firmado. Ejecuta /pentest para crear .tasks/pentest/SCOPE.md."; exit 1; }
	@# <PENTEST: suite dinámica contra el destino autorizado en SCOPE.md (schemathesis sobre el OpenAPI, ZAP full scan, k6); imprime solo fallos>
	@true

# Performance medida (no forma parte de check; la skill perf rellena pruebas y umbrales).
# Mide contra la app LEVANTADA por compose, nunca contra producción. k6 corre dentro de la red de compose (perfil `perf`).
# PERF_FACTOR multiplica los umbrales: 1 en local, 2 en CI (máquinas compartidas, más lentas y variables).
PERF_FACTOR ?= 1
perf:
	@# Falla cerrado: sin scripts no hay medición, y eso nunca debe pasar como verde (ni en local ni en CI).
	@ls perf/k6/*.js >/dev/null 2>&1 || { echo "No hay pruebas de performance en perf/k6/. Ejecuta /perf, o commitea perf/ si ya existen."; exit 1; }
	@# <PERF: make up; seed de volumen (perf/seed); por cada perf/k6/*.js: `PERF_FACTOR=$(PERF_FACTOR) docker compose --profile perf run --rm -T k6 run -q /scripts/<archivo>` imprimiendo solo los que fallan; presupuesto Lighthouse/bundle si hay frontend>
	@true
