from collections.abc import AsyncIterator

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import StaticPool

from app.db.session import Base, get_session
from app.main import app
from app.modules.oraciones.models import Oracion


@pytest.fixture
async def client() -> AsyncIterator[AsyncClient]:
    engine = create_async_engine(
        "sqlite+aiosqlite://", poolclass=StaticPool, connect_args={"check_same_thread": False}
    )
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    factory = async_sessionmaker(engine, expire_on_commit=False)
    async with factory() as s:
        s.add(Oracion(slug="padre-nuestro", titulo="Padre Nuestro", texto="Padre nuestro..."))
        await s.commit()

    async def override() -> AsyncIterator[AsyncSession]:
        async with factory() as session:
            yield session

    app.dependency_overrides[get_session] = override
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://t") as c:
        yield c
    app.dependency_overrides.clear()
    await engine.dispose()


async def test_listar(client: AsyncClient) -> None:
    r = await client.get("/api/v1/public/oraciones")
    assert r.status_code == 200
    assert [o["slug"] for o in r.json()] == ["padre-nuestro"]


async def test_obtener_inexistente_404(client: AsyncClient) -> None:
    r = await client.get("/api/v1/public/oraciones/nada")
    assert r.status_code == 404


async def test_health(client: AsyncClient) -> None:
    assert (await client.get("/health")).json() == {"status": "ok"}
