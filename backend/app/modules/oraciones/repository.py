from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.oraciones.models import Oracion


async def get_by_slug(session: AsyncSession, slug: str) -> Oracion | None:
    result = await session.execute(select(Oracion).where(Oracion.slug == slug))
    return result.scalar_one_or_none()


async def list_all(session: AsyncSession) -> list[Oracion]:
    result = await session.execute(select(Oracion).order_by(Oracion.titulo))
    return list(result.scalars())
