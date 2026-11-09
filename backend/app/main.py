from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.db.session import Base, engine
from app.modules.oraciones import models as _models  # noqa: F401  (registra tablas)
from app.modules.oraciones.router import router as oraciones_router


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncIterator[None]:
    # Solo desarrollo: en producción el esquema lo gestiona Alembic.
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield


app = FastAPI(title="Devoto Católico API", lifespan=lifespan)
app.include_router(oraciones_router, prefix="/api/v1")


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
